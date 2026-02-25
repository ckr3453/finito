import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/domain/entities/task_entity.dart';
import 'package:todo_app/domain/enums/enums.dart';
import 'package:todo_app/services/notification/notification_service.dart';
import 'package:todo_app/services/notification/noop_notification_service.dart';

void main() {
  late NotificationService service;

  setUp(() {
    service = NoopNotificationService();
  });

  TaskEntity makeTask({
    String id = 'task-1',
    String title = 'Test Task',
    TaskStatus status = TaskStatus.pending,
    DateTime? reminderTime,
  }) {
    final now = DateTime(2026, 2, 24);
    return TaskEntity(
      id: id,
      title: title,
      status: status,
      reminderTime: reminderTime,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('NoopNotificationService', () {
    group('initialize', () {
      test('does not throw', () async {
        await expectLater(
          service.initialize(onNotificationTap: (_) {}),
          completes,
        );
      });

      test('does not invoke onNotificationTap callback', () async {
        var tapped = false;

        await service.initialize(
          onNotificationTap: (_) {
            tapped = true;
          },
        );

        expect(tapped, isFalse);
      });
    });

    group('scheduleReminder', () {
      test('does not throw for task without reminderTime', () async {
        final task = makeTask();

        await expectLater(service.scheduleReminder(task), completes);
      });

      test('does not throw for task with reminderTime', () async {
        final task = makeTask(reminderTime: DateTime(2026, 3, 1, 9, 0));

        await expectLater(service.scheduleReminder(task), completes);
      });

      test('does not throw for completed task', () async {
        final task = makeTask(status: TaskStatus.completed);

        await expectLater(service.scheduleReminder(task), completes);
      });
    });

    group('cancelReminder', () {
      test('does not throw for any task id', () async {
        await expectLater(service.cancelReminder('task-1'), completes);
      });

      test('does not throw for empty task id', () async {
        await expectLater(service.cancelReminder(''), completes);
      });
    });

    group('rescheduleAll', () {
      test('does not throw for empty list', () async {
        await expectLater(service.rescheduleAll([]), completes);
      });

      test('does not throw for non-empty list', () async {
        final tasks = [
          makeTask(id: 'task-1'),
          makeTask(id: 'task-2', reminderTime: DateTime(2026, 3, 1)),
        ];

        await expectLater(service.rescheduleAll(tasks), completes);
      });
    });

    group('requestPermission', () {
      test('returns false', () async {
        final result = await service.requestPermission();

        expect(result, isFalse);
      });
    });
  });
}
