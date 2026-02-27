import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:todo_app/domain/repositories/fcm_token_repository.dart';
import 'package:todo_app/services/notification/fcm_client.dart';
import 'package:todo_app/services/notification/fcm_service.dart';

class FcmServiceImpl implements FcmService {
  final FcmClient _client;
  final FcmTokenRepository _tokenRepository;

  FcmServiceImpl({
    required FcmClient client,
    required FcmTokenRepository tokenRepository,
  }) : _client = client,
       _tokenRepository = tokenRepository;

  String get _platform {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.windows:
        return 'windows';
      default:
        return 'unknown';
    }
  }

  String? get _vapidKey => kIsWeb
      ? const String.fromEnvironment(
              'FCM_VAPID_KEY',
              defaultValue: '',
            ).isNotEmpty
            ? const String.fromEnvironment('FCM_VAPID_KEY')
            : null
      : null;

  @override
  Future<String?> getToken({String? vapidKey}) =>
      _client.getToken(vapidKey: vapidKey ?? _vapidKey);

  @override
  Stream<String> get onTokenRefresh => _client.onTokenRefresh;

  @override
  Future<bool> requestPermission() => _client.requestPermission();

  @override
  Future<void> saveTokenToFirestore(String userId) async {
    try {
      final token = await getToken();
      if (token == null) return;
      await _tokenRepository.saveToken(
        userId: userId,
        token: token,
        platform: _platform,
      );
    } catch (e) {
      debugPrint('FCM saveTokenToFirestore error: $e');
    }
  }

  @override
  Future<void> deleteTokenFromFirestore(String userId) async {
    try {
      final token = await getToken();
      if (token != null) {
        await _tokenRepository.deleteToken(userId: userId, token: token);
      }
    } catch (e) {
      debugPrint('FCM deleteTokenFromFirestore error: $e');
    }
  }

  @override
  StreamSubscription<String>? listenForTokenRefresh(String userId) {
    return onTokenRefresh.listen((newToken) async {
      try {
        await _tokenRepository.saveToken(
          userId: userId,
          token: newToken,
          platform: _platform,
        );
      } catch (e) {
        debugPrint('FCM token refresh save error: $e');
      }
    });
  }

  @override
  Future<void> setupMessageHandlers({
    required void Function(String? taskId) onNotificationTap,
  }) async {
    // Foreground messages — just log, local notification handles display
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM foreground message: ${message.notification?.title}');
    });

    // Background → notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final taskId = message.data['taskId'] as String?;
      onNotificationTap(taskId);
    });

    // Terminated → notification tap
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final taskId = initialMessage.data['taskId'] as String?;
      onNotificationTap(taskId);
    }
  }
}
