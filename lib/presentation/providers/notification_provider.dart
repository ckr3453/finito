import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:todo_app/data/repositories/fcm_token_repository_impl.dart';
import 'package:todo_app/presentation/providers/auth_provider.dart';
import 'package:todo_app/presentation/providers/repository_providers.dart';
import 'package:todo_app/services/notification/fcm_client_impl.dart';
import 'package:todo_app/services/notification/fcm_service.dart';
import 'package:todo_app/services/notification/fcm_service_impl.dart';
import 'package:todo_app/services/notification/noop_fcm_service.dart';
import 'package:todo_app/services/notification/notification_service.dart';
import 'package:todo_app/services/notification/notification_service_factory.dart';

part 'notification_provider.g.dart';

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  tz.initializeTimeZones();
  return createNotificationService();
}

bool get _isFcmSupported =>
    kIsWeb || defaultTargetPlatform == TargetPlatform.android;

@Riverpod(keepAlive: true)
FcmService fcmService(Ref ref) {
  if (!_isFcmSupported) return NoopFcmService();
  return FcmServiceImpl(
    client: FcmClientImpl(),
    tokenRepository: FcmTokenRepositoryImpl(),
  );
}

@Riverpod(keepAlive: true)
Stream<void> reminderAutoReschedule(Ref ref) async* {
  final notifSvc = ref.watch(notificationServiceProvider);
  final repo = ref.watch(taskRepositoryProvider);

  await for (final tasks in repo.watchAllTasks()) {
    try {
      await notifSvc.rescheduleAll(tasks);
    } catch (e) {
      debugPrint('Reminder reschedule error: $e');
    }
    yield null;
  }
}

@Riverpod(keepAlive: true)
Stream<void> fcmTokenAutoSave(Ref ref) async* {
  if (!_isFcmSupported) return;

  final fcmSvc = ref.watch(fcmServiceProvider);
  StreamSubscription<String>? refreshSub;

  ref.onDispose(() => refreshSub?.cancel());

  await for (final user in ref.watch(authStateProvider.stream)) {
    refreshSub?.cancel();

    if (user != null) {
      await fcmSvc.saveTokenToFirestore(user.uid);
      refreshSub = fcmSvc.listenForTokenRefresh(user.uid);
    }

    yield null;
  }
}
