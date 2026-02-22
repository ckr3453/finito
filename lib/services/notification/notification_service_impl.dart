import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:todo_app/domain/entities/task_entity.dart';
import 'package:todo_app/domain/enums/enums.dart';
import 'package:todo_app/services/notification/local_notification_client.dart';
import 'package:todo_app/services/notification/notification_service.dart';

class NotificationServiceImpl implements NotificationService {
  final LocalNotificationClient _client;

  static const _channelId = 'task_reminders';
  static const _channelName = '할 일 리마인더';
  static const _channelDescription = '할 일 리마인더 알림';

  NotificationServiceImpl({required LocalNotificationClient client})
    : _client = client;

  @override
  Future<void> initialize({
    required void Function(String? payload) onNotificationTap,
  }) async {
    await _client.initialize(
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.notificationResponseType ==
            NotificationResponseType.selectedNotification) {
          onNotificationTap(response.payload);
        }
      },
    );
  }

  @override
  Future<void> scheduleReminder(TaskEntity task) async {
    final reminderTime = task.reminderTime;
    if (reminderTime == null) return;
    if (reminderTime.isBefore(DateTime.now())) return;

    final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

    await _client.zonedSchedule(
      id: task.id.hashCode,
      title: task.title,
      body: '리마인더: ${task.title}',
      scheduledDate: scheduledDate,
      channelId: _channelId,
      channelName: _channelName,
      channelDescription: _channelDescription,
      payload: task.id,
    );
  }

  @override
  Future<void> cancelReminder(String taskId) async {
    await _client.cancel(taskId.hashCode);
  }

  @override
  Future<void> rescheduleAll(List<TaskEntity> tasks) async {
    await _client.cancelAll();

    for (final task in tasks) {
      if (task.status == TaskStatus.completed) continue;
      if (task.deletedAt != null) continue;
      await scheduleReminder(task);
    }
  }

  @override
  Future<bool> requestPermission() async {
    return _client.requestPermission();
  }
}
