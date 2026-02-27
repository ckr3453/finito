import 'dart:async';

abstract class FcmService {
  Future<String?> getToken({String? vapidKey});

  Stream<String> get onTokenRefresh;

  Future<bool> requestPermission();

  Future<void> saveTokenToFirestore(String userId);

  Future<void> deleteTokenFromFirestore(String userId);

  StreamSubscription<String>? listenForTokenRefresh(String userId);

  Future<void> setupMessageHandlers({
    required void Function(String? taskId) onNotificationTap,
  });
}
