import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/data/datasources/remote/firestore_paths.dart';

class UserProfile {
  final String uid;
  final String? email;
  final String? displayName;
  final bool approved;
  final bool isAdmin;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    this.email,
    this.displayName,
    required this.approved,
    required this.isAdmin,
    required this.createdAt,
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      approved: data['approved'] as bool? ?? false,
      isAdmin: data['isAdmin'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class UserService {
  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _firestore.doc(FirestorePaths.userDoc(uid)).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserProfile.fromFirestore(doc.data()!, uid);
  }

  Future<void> ensureUserProfile({
    required String uid,
    String? email,
    String? displayName,
  }) async {
    final docRef = _firestore.doc(FirestorePaths.userDoc(uid));
    final doc = await docRef.get();
    if (!doc.exists) {
      // First user becomes admin; all users are auto-approved
      final usersSnapshot = await _firestore
          .collection(FirestorePaths.usersCol)
          .limit(1)
          .get();
      final isFirstUser = usersSnapshot.docs.isEmpty;

      await docRef.set({
        'email': email,
        'displayName': displayName,
        'approved': true,
        'isAdmin': isFirstUser,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Update email/displayName if changed
      await docRef.update({'email': email, 'displayName': displayName});
    }
  }

  Stream<List<UserProfile>> watchAllUsers() {
    return _firestore
        .collection(FirestorePaths.usersCol)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserProfile.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> approveUser(String uid) {
    return _firestore.doc(FirestorePaths.userDoc(uid)).update({
      'approved': true,
    });
  }

  Future<void> rejectUser(String uid) {
    return _firestore.doc(FirestorePaths.userDoc(uid)).update({
      'approved': false,
    });
  }

  Future<void> toggleAdmin(String uid, bool isAdmin) {
    return _firestore.doc(FirestorePaths.userDoc(uid)).update({
      'isAdmin': isAdmin,
    });
  }

  /// Delete all Firestore data for a user (profile + tasks).
  Future<void> deleteUserData(String uid) async {
    final batch = _firestore.batch();

    // Delete all tasks
    final tasks = await _firestore
        .collection(FirestorePaths.tasksCol(uid))
        .get();
    for (final doc in tasks.docs) {
      batch.delete(doc.reference);
    }

    // Delete user profile
    batch.delete(_firestore.doc(FirestorePaths.userDoc(uid)));

    await batch.commit();
  }
}
