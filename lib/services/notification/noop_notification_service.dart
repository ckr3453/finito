import 'package:todo_app/domain/entities/task_entity.dart';
import 'package:todo_app/services/notification/notification_service.dart';

class NoopNotificationService implements NotificationService {
  @override
  Future<void> initialize({
    required void Function(String? payload) onNotificationTap,
  }) async {}

  @override
  Future<void> scheduleReminder(TaskEntity task) async {}

  @override
  Future<void> cancelReminder(String taskId) async {}

  @override
  Future<void> rescheduleAll(List<TaskEntity> tasks) async {}

  @override
  Future<bool> requestPermission() async => false;
}

NotificationService createPlatformNotificationService() =>
    NoopNotificationService();
