import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/data/datasources/remote/firestore_paths.dart';
import 'package:todo_app/services/user_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late UserService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = UserService(firestore: fakeFirestore);
  });

  group('UserProfile.fromFirestore', () {
    test('parses all fields correctly', () {
      final now = DateTime(2026, 1, 15);
      final data = {
        'email': 'test@example.com',
        'displayName': 'Test User',
        'approved': true,
        'isAdmin': true,
        'createdAt': Timestamp.fromDate(now),
      };

      final profile = UserProfile.fromFirestore(data, 'uid-1');

      expect(profile.uid, 'uid-1');
      expect(profile.email, 'test@example.com');
      expect(profile.displayName, 'Test User');
      expect(profile.approved, true);
      expect(profile.isAdmin, true);
      expect(profile.createdAt, now);
    });

    test('handles null and missing fields with defaults', () {
      final data = <String, dynamic>{};

      final profile = UserProfile.fromFirestore(data, 'uid-2');

      expect(profile.uid, 'uid-2');
      expect(profile.email, isNull);
      expect(profile.displayName, isNull);
      expect(profile.approved, false);
      expect(profile.isAdmin, false);
      expect(profile.createdAt, isA<DateTime>());
    });
  });

  group('getUserProfile', () {
    test('returns null for non-existent user', () async {
      final result = await service.getUserProfile('non-existent');

      expect(result, isNull);
    });

    test('returns UserProfile for existing user', () async {
      await fakeFirestore.doc(FirestorePaths.userDoc('uid-1')).set({
        'email': 'test@example.com',
        'displayName': 'Test',
        'approved': true,
        'isAdmin': false,
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });

      final result = await service.getUserProfile('uid-1');

      expect(result, isNotNull);
      expect(result!.uid, 'uid-1');
      expect(result.email, 'test@example.com');
      expect(result.approved, true);
    });
  });

  group('ensureUserProfile', () {
    test('first user gets admin and approved', () async {
      await service.ensureUserProfile(
        uid: 'first-user',
        email: 'first@example.com',
        displayName: 'First',
      );

      final doc = await fakeFirestore
          .doc(FirestorePaths.userDoc('first-user'))
          .get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['approved'], true);
      expect(doc.data()!['isAdmin'], true);
      expect(doc.data()!['email'], 'first@example.com');
    });

    test('second user does NOT get admin or approved', () async {
      // Create first user
      await service.ensureUserProfile(
        uid: 'first-user',
        email: 'first@example.com',
      );

      // Create second user
      await service.ensureUserProfile(
        uid: 'second-user',
        email: 'second@example.com',
      );

      final doc = await fakeFirestore
          .doc(FirestorePaths.userDoc('second-user'))
          .get();
      expect(doc.data()!['approved'], false);
      expect(doc.data()!['isAdmin'], false);
    });

    test('existing user updates email and displayName', () async {
      await service.ensureUserProfile(
        uid: 'user-1',
        email: 'old@example.com',
        displayName: 'Old Name',
      );

      await service.ensureUserProfile(
        uid: 'user-1',
        email: 'new@example.com',
        displayName: 'New Name',
      );

      final doc = await fakeFirestore
          .doc(FirestorePaths.userDoc('user-1'))
          .get();
      expect(doc.data()!['email'], 'new@example.com');
      expect(doc.data()!['displayName'], 'New Name');
    });
  });

  group('watchAllUsers', () {
    test('emits list of users', () async {
      await fakeFirestore.doc(FirestorePaths.userDoc('u1')).set({
        'email': 'a@example.com',
        'approved': true,
        'isAdmin': false,
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });

      final users = await service.watchAllUsers().first;

      expect(users, hasLength(1));
      expect(users[0].uid, 'u1');
    });

    test('emits updated list when user is added', () async {
      final stream = service.watchAllUsers();
      final future = stream.take(2).toList();

      await fakeFirestore.doc(FirestorePaths.userDoc('u1')).set({
        'email': 'a@example.com',
        'approved': true,
        'isAdmin': false,
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });

      final results = await future;
      expect(results[0], isEmpty);
      expect(results[1], hasLength(1));
    });
  });

  group('approveUser', () {
    test('sets approved to true', () async {
      await fakeFirestore.doc(FirestorePaths.userDoc('u1')).set({
        'approved': false,
        'isAdmin': false,
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });

      await service.approveUser('u1');

      final doc = await fakeFirestore.doc(FirestorePaths.userDoc('u1')).get();
      expect(doc.data()!['approved'], true);
    });
  });

  group('rejectUser', () {
    test('sets approved to false', () async {
      await fakeFirestore.doc(FirestorePaths.userDoc('u1')).set({
        'approved': true,
        'isAdmin': false,
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });

      await service.rejectUser('u1');

      final doc = await fakeFirestore.doc(FirestorePaths.userDoc('u1')).get();
      expect(doc.data()!['approved'], false);
    });
  });

  group('toggleAdmin', () {
    test('sets isAdmin to the given value', () async {
      await fakeFirestore.doc(FirestorePaths.userDoc('u1')).set({
        'approved': true,
        'isAdmin': false,
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });

      await service.toggleAdmin('u1', true);

      final doc = await fakeFirestore.doc(FirestorePaths.userDoc('u1')).get();
      expect(doc.data()!['isAdmin'], true);

      await service.toggleAdmin('u1', false);

      final doc2 = await fakeFirestore.doc(FirestorePaths.userDoc('u1')).get();
      expect(doc2.data()!['isAdmin'], false);
    });
  });

  group('deleteUserData', () {
    test('deletes user profile and their tasks', () async {
      // Create user profile
      await fakeFirestore.doc(FirestorePaths.userDoc('u1')).set({
        'email': 'a@example.com',
        'approved': true,
        'isAdmin': false,
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });

      // Create tasks for the user
      await fakeFirestore.doc(FirestorePaths.taskDoc('u1', 't1')).set({
        'title': 'Task 1',
      });
      await fakeFirestore.doc(FirestorePaths.taskDoc('u1', 't2')).set({
        'title': 'Task 2',
      });

      await service.deleteUserData('u1');

      final userDoc = await fakeFirestore
          .doc(FirestorePaths.userDoc('u1'))
          .get();
      expect(userDoc.exists, isFalse);

      final tasks = await fakeFirestore
          .collection(FirestorePaths.tasksCol('u1'))
          .get();
      expect(tasks.docs, isEmpty);
    });
  });
}
