import 'package:todo_app/domain/entities/task_entity.dart';

abstract class NotificationService {
  Future<void> initialize({
    required void Function(String? payload) onNotificationTap,
  });

  Future<void> scheduleReminder(TaskEntity task);

  Future<void> cancelReminder(String taskId);

  Future<void> rescheduleAll(List<TaskEntity> tasks);

  Future<bool> requestPermission();
}
