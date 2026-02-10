import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

abstract class LocalNotificationClient {
  Future<void> initialize({
    required void Function(NotificationResponse)
    onDidReceiveNotificationResponse,
  });

  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required String channelId,
    required String channelName,
    required String channelDescription,
    String? payload,
  });

  Future<void> cancel(int id);

  Future<void> cancelAll();

  Future<bool> requestPermission();
}
