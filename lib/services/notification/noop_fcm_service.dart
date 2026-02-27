import 'dart:async';

import 'package:todo_app/services/notification/fcm_service.dart';

class NoopFcmService implements FcmService {
  @override
  Future<String?> getToken({String? vapidKey}) async => null;

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> saveTokenToFirestore(String userId) async {}

  @override
  Future<void> deleteTokenFromFirestore(String userId) async {}

  @override
  StreamSubscription<String>? listenForTokenRefresh(String userId) => null;

  @override
  Future<void> setupMessageHandlers({
    required void Function(String? taskId) onNotificationTap,
  }) async {}
}
