import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/data/datasources/remote/firestore_paths.dart';
import 'package:todo_app/domain/repositories/fcm_token_repository.dart';

class FcmTokenRepositoryImpl implements FcmTokenRepository {
  final FirebaseFirestore _firestore;

  FcmTokenRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Deterministic short doc ID from token string (JS-safe 32-bit hash).
  String _tokenHash(String token) {
    final bytes = utf8.encode(token);
    var h1 = 0xdeadbeef;
    var h2 = 0x41c6ce57;
    for (final b in bytes) {
      h1 = ((h1 ^ b) * 2654435761) & 0xFFFFFFFF;
      h2 = ((h2 ^ b) * 1597334677) & 0xFFFFFFFF;
    }
    return '${h1.toRadixString(36)}${h2.toRadixString(36)}';
  }

  @override
  Future<void> saveToken({
    required String userId,
    required String token,
    required String platform,
  }) async {
    final docPath = FirestorePaths.fcmTokenDoc(userId, _tokenHash(token));
    await _firestore.doc(docPath).set({
      'token': token,
      'platform': platform,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteToken({
    required String userId,
    required String token,
  }) async {
    final docPath = FirestorePaths.fcmTokenDoc(userId, _tokenHash(token));
    await _firestore.doc(docPath).delete();
  }

  @override
  Future<void> deleteAllTokens(String userId) async {
    final colPath = FirestorePaths.fcmTokensCol(userId);
    final snapshot = await _firestore.collection(colPath).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
