import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:todo_app/data/database/app_database.dart';
import 'package:todo_app/data/repositories/local_task_repository.dart';
import 'package:todo_app/domain/entities/task_entity.dart';
import 'package:todo_app/domain/enums/enums.dart';
import 'package:todo_app/services/notification/local_notification_client.dart';
import 'package:todo_app/services/notification/notification_service_impl.dart';

class MockLocalNotificationClient extends Mock
    implements LocalNotificationClient {}

void main() {
  late AppDatabase db;
  late LocalTaskRepository repo;
  late MockLocalNotificationClient mockClient;
  late NotificationServiceImpl notifService;

  setUpAll(() {
    tz.initializeTimeZones();
    registerFallbackValue(tz.TZDateTime.now(tz.local));
  });

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = LocalTaskRepository(db);
    mockClient = MockLocalNotificationClient();
    notifService = NotificationServiceImpl(client: mockClient);

    when(
      () => mockClient.initialize(
        onDidReceiveNotificationResponse: any(
          named: 'onDidReceiveNotificationResponse',
        ),
      ),
    ).thenAnswer((_) async {});
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
    when(() => mockClient.cancel(any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await db.close();
  });

  TaskEntity makeTask({
    required String id,
    required String title,
    DateTime? reminderTime,
    TaskStatus status = TaskStatus.pending,
  }) {
    final now = DateTime.now();
    return TaskEntity(
      id: id,
      title: title,
      status: status,
      reminderTime: reminderTime,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('E2E: Task CRUD → Notification 스케줄링 흐름', () {
    test('태스크 생성 후 리마인더가 스케줄된다', () async {
      final futureTime = DateTime.now().add(const Duration(hours: 2));
      final task = makeTask(
        id: 'task-1',
        title: '회의 준비',
        reminderTime: futureTime,
      );

      await repo.createTask(task);
      await notifService.scheduleReminder(task);

      verify(
        () => mockClient.zonedSchedule(
          id: 'task-1'.hashCode,
          title: '회의 준비',
          body: '리마인더: 회의 준비',
          scheduledDate: any(named: 'scheduledDate'),
          channelId: 'task_reminders',
          channelName: '할 일 리마인더',
          channelDescription: '할 일 리마인더 알림',
          payload: 'task-1',
        ),
      ).called(1);
    });

    test('태스크 완료 시 리마인더가 취소된다', () async {
      final futureTime = DateTime.now().add(const Duration(hours: 2));
      final task = makeTask(
        id: 'task-2',
        title: '보고서 작성',
        reminderTime: futureTime,
      );

      await repo.createTask(task);
      await notifService.scheduleReminder(task);

      // Complete the task
      final completed = task.copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repo.updateTask(completed);
      await notifService.cancelReminder(task.id);

      verify(() => mockClient.cancel('task-2'.hashCode)).called(1);
    });

    test('rescheduleAll은 DB의 미래 리마인더만 스케줄한다', () async {
      final futureTime = DateTime.now().add(const Duration(hours: 3));
      final pastTime = DateTime.now().subtract(const Duration(hours: 1));

      final task1 = makeTask(
        id: 'task-a',
        title: '미래 태스크',
        reminderTime: futureTime,
      );
      final task2 = makeTask(
        id: 'task-b',
        title: '과거 태스크',
        reminderTime: pastTime,
      );
      final task3 = makeTask(
        id: 'task-c',
        title: '완료 태스크',
        reminderTime: futureTime,
        status: TaskStatus.completed,
      );
      final task4 = makeTask(id: 'task-d', title: '리마인더 없음');

      await repo.createTask(task1);
      await repo.createTask(task2);
      await repo.createTask(task3);
      await repo.createTask(task4);

      final allTasks = await repo.watchAllTasks().first;
      await notifService.rescheduleAll(allTasks);

      verify(() => mockClient.cancelAll()).called(1);
      // Only task-a should be scheduled (future + pending)
      verify(
        () => mockClient.zonedSchedule(
          id: 'task-a'.hashCode,
          title: '미래 태스크',
          body: '리마인더: 미래 태스크',
          scheduledDate: any(named: 'scheduledDate'),
          channelId: 'task_reminders',
          channelName: '할 일 리마인더',
          channelDescription: '할 일 리마인더 알림',
          payload: 'task-a',
        ),
      ).called(1);
    });

    test('리마인더 시간 수정 시 기존 알림 취소 후 새로 스케줄', () async {
      final time1 = DateTime.now().add(const Duration(hours: 1));
      final time2 = DateTime.now().add(const Duration(hours: 5));
      final task = makeTask(
        id: 'task-edit',
        title: '수정 태스크',
        reminderTime: time1,
      );

      await repo.createTask(task);
      await notifService.scheduleReminder(task);

      // Update reminder time
      final updated = task.copyWith(
        reminderTime: time2,
        updatedAt: DateTime.now(),
      );
      await repo.updateTask(updated);
      await notifService.cancelReminder(task.id);
      await notifService.scheduleReminder(updated);

      // Cancel was called for the old reminder
      verify(() => mockClient.cancel('task-edit'.hashCode)).called(1);
      // Schedule was called twice (original + updated)
      verify(
        () => mockClient.zonedSchedule(
          id: 'task-edit'.hashCode,
          title: '수정 태스크',
          body: '리마인더: 수정 태스크',
          scheduledDate: any(named: 'scheduledDate'),
          channelId: 'task_reminders',
          channelName: '할 일 리마인더',
          channelDescription: '할 일 리마인더 알림',
          payload: 'task-edit',
        ),
      ).called(2);
    });

    test('reminderTime 필드가 DB에 올바르게 저장/조회된다', () async {
      final reminderTime = DateTime(2026, 3, 15, 14, 30);
      final task = makeTask(
        id: 'task-db',
        title: 'DB 테스트',
        reminderTime: reminderTime,
      );

      await repo.createTask(task);
      final fetched = await repo.getTaskById('task-db');

      expect(fetched, isNotNull);
      expect(fetched!.reminderTime, isNotNull);
      expect(fetched.reminderTime!.year, 2026);
      expect(fetched.reminderTime!.month, 3);
      expect(fetched.reminderTime!.day, 15);
      expect(fetched.reminderTime!.hour, 14);
      expect(fetched.reminderTime!.minute, 30);
    });

    test('reminderTime이 null인 태스크도 정상 저장/조회', () async {
      final task = makeTask(id: 'task-null', title: '리마인더 없는 태스크');

      await repo.createTask(task);
      final fetched = await repo.getTaskById('task-null');

      expect(fetched, isNotNull);
      expect(fetched!.reminderTime, isNull);
    });
  });
}
