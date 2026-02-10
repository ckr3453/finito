import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:todo_app/domain/entities/task_entity.dart';
import 'package:todo_app/domain/enums/enums.dart';
import 'package:todo_app/services/notification/local_notification_client.dart';
import 'package:todo_app/services/notification/notification_service.dart';
import 'package:todo_app/services/notification/notification_service_impl.dart';

class MockLocalNotificationClient extends Mock
    implements LocalNotificationClient {}

void main() {
  late MockLocalNotificationClient mockClient;
  late NotificationService service;

  setUpAll(() {
    tz.initializeTimeZones();
    registerFallbackValue(tz.TZDateTime.now(tz.local));
  });

  setUp(() {
    mockClient = MockLocalNotificationClient();
    service = NotificationServiceImpl(client: mockClient);

    when(
      () => mockClient.initialize(
        onDidReceiveNotificationResponse: any(
          named: 'onDidReceiveNotificationResponse',
        ),
      ),
    ).thenAnswer((_) async {});
  });

  TaskEntity _makeTask({
    String id = 'task-1',
    String title = 'Test Task',
    DateTime? reminderTime,
  }) {
    final now = DateTime.now();
    return TaskEntity(
      id: id,
      title: title,
      reminderTime: reminderTime,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('NotificationServiceImpl', () {
    group('initialize', () {
      test('should initialize client', () async {
        await service.initialize(onNotificationTap: (_) {});

        verify(
          () => mockClient.initialize(
            onDidReceiveNotificationResponse: any(
              named: 'onDidReceiveNotificationResponse',
            ),
          ),
        ).called(1);
      });
    });

    group('scheduleReminder', () {
      test('should schedule notification for task with reminderTime', () async {
        final futureTime = DateTime.now().add(const Duration(hours: 1));
        final task = _makeTask(reminderTime: futureTime);

        when(
          () => mockClient.zonedSchedule(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            channelId: any(named: 'channelId'),
            channelName: any(named: 'channelName'),
            channelDescription: any(named: 'channelDescription'),
            payload: any(named: 'payload'),
          ),
        ).thenAnswer((_) async {});

        await service.scheduleReminder(task);

        verify(
          () => mockClient.zonedSchedule(
            id: task.id.hashCode,
            title: task.title,
            body: '리마인더: ${task.title}',
            scheduledDate: any(named: 'scheduledDate'),
            channelId: 'task_reminders',
            channelName: '할 일 리마인더',
            channelDescription: '할 일 리마인더 알림',
            payload: task.id,
          ),
        ).called(1);
      });

      test('should not schedule when reminderTime is null', () async {
        final task = _makeTask(reminderTime: null);

        await service.scheduleReminder(task);

        verifyNever(
          () => mockClient.zonedSchedule(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            channelId: any(named: 'channelId'),
            channelName: any(named: 'channelName'),
            channelDescription: any(named: 'channelDescription'),
            payload: any(named: 'payload'),
          ),
        );
      });

      test('should not schedule when reminderTime is in the past', () async {
        final pastTime = DateTime.now().subtract(const Duration(hours: 1));
        final task = _makeTask(reminderTime: pastTime);

        await service.scheduleReminder(task);

        verifyNever(
          () => mockClient.zonedSchedule(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            channelId: any(named: 'channelId'),
            channelName: any(named: 'channelName'),
            channelDescription: any(named: 'channelDescription'),
            payload: any(named: 'payload'),
          ),
        );
      });
    });

    group('cancelReminder', () {
      test('should cancel notification by task id hashcode', () async {
        when(() => mockClient.cancel(any())).thenAnswer((_) async {});

        await service.cancelReminder('task-1');

        verify(() => mockClient.cancel('task-1'.hashCode)).called(1);
      });
    });

    group('rescheduleAll', () {
      test('should cancel all then reschedule future reminders', () async {
        final futureTime = DateTime.now().add(const Duration(hours: 1));
        final pastTime = DateTime.now().subtract(const Duration(hours: 1));

        final tasks = [
          _makeTask(id: 'task-1', title: 'Future', reminderTime: futureTime),
          _makeTask(id: 'task-2', title: 'Past', reminderTime: pastTime),
          _makeTask(id: 'task-3', title: 'No Reminder'),
        ];

        when(() => mockClient.cancelAll()).thenAnswer((_) async {});
        when(
          () => mockClient.zonedSchedule(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            channelId: any(named: 'channelId'),
            channelName: any(named: 'channelName'),
            channelDescription: any(named: 'channelDescription'),
            payload: any(named: 'payload'),
          ),
        ).thenAnswer((_) async {});

        await service.rescheduleAll(tasks);

        verify(() => mockClient.cancelAll()).called(1);
        // Only future task should be scheduled
        verify(
          () => mockClient.zonedSchedule(
            id: 'task-1'.hashCode,
            title: 'Future',
            body: '리마인더: Future',
            scheduledDate: any(named: 'scheduledDate'),
            channelId: 'task_reminders',
            channelName: '할 일 리마인더',
            channelDescription: '할 일 리마인더 알림',
            payload: 'task-1',
          ),
        ).called(1);
      });

      test('should skip completed tasks', () async {
        final futureTime = DateTime.now().add(const Duration(hours: 1));
        final now = DateTime.now();
        final tasks = [
          TaskEntity(
            id: 'task-1',
            title: 'Completed Task',
            status: TaskStatus.completed,
            reminderTime: futureTime,
            createdAt: now,
            updatedAt: now,
          ),
        ];

        when(() => mockClient.cancelAll()).thenAnswer((_) async {});

        await service.rescheduleAll(tasks);

        verify(() => mockClient.cancelAll()).called(1);
        verifyNever(
          () => mockClient.zonedSchedule(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            channelId: any(named: 'channelId'),
            channelName: any(named: 'channelName'),
            channelDescription: any(named: 'channelDescription'),
            payload: any(named: 'payload'),
          ),
        );
      });
    });

    group('requestPermission', () {
      test('should delegate to client', () async {
        when(
          () => mockClient.requestPermission(),
        ).thenAnswer((_) async => true);

        final result = await service.requestPermission();

        expect(result, isTrue);
        verify(() => mockClient.requestPermission()).called(1);
      });
    });
  });
}
