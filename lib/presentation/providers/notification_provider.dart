import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:todo_app/presentation/providers/repository_providers.dart';
import 'package:todo_app/services/notification/fcm_client_impl.dart';
import 'package:todo_app/services/notification/fcm_service.dart';
import 'package:todo_app/services/notification/fcm_service_impl.dart';
import 'package:todo_app/services/notification/local_notification_client_impl.dart';
import 'package:todo_app/services/notification/notification_service.dart';
import 'package:todo_app/services/notification/notification_service_impl.dart';

part 'notification_provider.g.dart';

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  tz.initializeTimeZones();
  return NotificationServiceImpl(client: LocalNotificationClientImpl());
}

@Riverpod(keepAlive: true)
FcmService fcmService(Ref ref) {
  return FcmServiceImpl(client: FcmClientImpl());
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
