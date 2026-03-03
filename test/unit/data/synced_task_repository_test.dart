import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/data/repositories/local_task_repository.dart';
import 'package:todo_app/data/repositories/synced_task_repository.dart';
import 'package:todo_app/domain/entities/entities.dart';
import 'package:todo_app/domain/enums/enums.dart';
import 'package:todo_app/services/task_sync_service.dart';

class MockLocalTaskRepository extends Mock implements LocalTaskRepository {}

class MockTaskSyncService extends Mock implements TaskSyncService {}

class FakeTaskEntity extends Fake implements TaskEntity {}

void main() {
  late MockLocalTaskRepository mockLocal;
  late MockTaskSyncService mockSyncService;
  late SyncedTaskRepository repository;

  final now = DateTime(2026, 1, 15, 12, 0, 0);

  setUpAll(() {
    registerFallbackValue(FakeTaskEntity());
  });

  setUp(() {
    mockLocal = MockLocalTaskRepository();
    mockSyncService = MockTaskSyncService();
    repository = SyncedTaskRepository(
      local: mockLocal,
      syncService: mockSyncService,
      ready: Future<void>.value(),
    );
  });

  TaskEntity makeEntity({
    String id = 'task-1',
    String title = 'Test Task',
    DateTime? updatedAt,
    bool isSynced = false,
  }) {
    return TaskEntity(
      id: id,
      title: title,
      createdAt: now,
      updatedAt: updatedAt ?? now,
      isSynced: isSynced,
    );
  }

  TagEntity makeTag({
    String id = 'tag-1',
    String name = 'Test Tag',
    int colorValue = 0xFF0000,
  }) {
    return TagEntity(
      id: id,
      name: name,
      colorValue: colorValue,
      createdAt: now,
    );
  }

  // ============================================================
  // Group 1: Stream reads (watchAllTasks, watchTasksFiltered)
  // ============================================================
  group('stream reads', () {
    test('watchAllTasks delegates to local', () {
      final tasks = [makeEntity(id: 'task-1'), makeEntity(id: 'task-2')];
      when(
        () => mockLocal.watchAllTasks(),
      ).thenAnswer((_) => Stream.value(tasks));

      expect(repository.watchAllTasks(), emits(tasks));
      verify(() => mockLocal.watchAllTasks()).called(1);
    });

    test('watchTasksFiltered delegates to local with all parameters', () {
      final tasks = [makeEntity(id: 'task-1')];
      when(
        () => mockLocal.watchTasksFiltered(
          status: TaskStatus.pending,
          priority: Priority.high,
          categoryId: 'cat-1',
          searchQuery: 'test',
        ),
      ).thenAnswer((_) => Stream.value(tasks));

      expect(
        repository.watchTasksFiltered(
          status: TaskStatus.pending,
          priority: Priority.high,
          categoryId: 'cat-1',
          searchQuery: 'test',
        ),
        emits(tasks),
      );

      verify(
        () => mockLocal.watchTasksFiltered(
          status: TaskStatus.pending,
          priority: Priority.high,
          categoryId: 'cat-1',
          searchQuery: 'test',
        ),
      ).called(1);
    });

    test('watchTasksFiltered delegates with null parameters', () {
      when(
        () => mockLocal.watchTasksFiltered(),
      ).thenAnswer((_) => Stream.value([]));

      expect(repository.watchTasksFiltered(), emits([]));
      verify(() => mockLocal.watchTasksFiltered()).called(1);
    });
  });

  // ============================================================
  // Group 2: Future reads (getTaskById)
  // ============================================================
  group('future reads', () {
    test('getTaskById delegates to local and returns entity', () async {
      final task = makeEntity(id: 'task-1');
      when(() => mockLocal.getTaskById('task-1')).thenAnswer((_) async => task);

      final result = await repository.getTaskById('task-1');

      expect(result, task);
      verify(() => mockLocal.getTaskById('task-1')).called(1);
    });

    test('getTaskById returns null when local returns null', () async {
      when(
        () => mockLocal.getTaskById('missing'),
      ).thenAnswer((_) async => null);

      final result = await repository.getTaskById('missing');

      expect(result, isNull);
      verify(() => mockLocal.getTaskById('missing')).called(1);
    });
  });

  // ============================================================
  // Group 3: Write operations
  // ============================================================
  group('write operations', () {
    setUp(() {
      when(() => mockSyncService.syncNow()).thenAnswer((_) async {});
    });

    test('createTask delegates to local', () async {
      final task = makeEntity(id: 'task-1');
      when(() => mockLocal.createTask(any())).thenAnswer((_) async {});

      await repository.createTask(task);

      verify(() => mockLocal.createTask(task)).called(1);
    });

    test('updateTask delegates to local', () async {
      final task = makeEntity(id: 'task-1', title: 'Updated');
      when(() => mockLocal.updateTask(any())).thenAnswer((_) async {});

      await repository.updateTask(task);

      verify(() => mockLocal.updateTask(task)).called(1);
    });

    test('upsertTask delegates to local', () async {
      final task = makeEntity(id: 'task-1');
      when(() => mockLocal.upsertTask(any())).thenAnswer((_) async {});

      await repository.upsertTask(task);

      verify(() => mockLocal.upsertTask(task)).called(1);
    });

    test('deleteTask delegates to local', () async {
      when(() => mockLocal.deleteTask('task-1')).thenAnswer((_) async {});

      await repository.deleteTask('task-1');

      verify(() => mockLocal.deleteTask('task-1')).called(1);
    });
  });

  // ============================================================
  // Group 4: Tag operations
  // ============================================================
  group('tag operations', () {
    test('setTagsForTask delegates to local', () async {
      when(() => mockSyncService.syncNow()).thenAnswer((_) async {});
      when(
        () => mockLocal.setTagsForTask('task-1', ['tag-1', 'tag-2']),
      ).thenAnswer((_) async {});

      await repository.setTagsForTask('task-1', ['tag-1', 'tag-2']);

      verify(
        () => mockLocal.setTagsForTask('task-1', ['tag-1', 'tag-2']),
      ).called(1);
    });

    test('getTagsForTask delegates to local and returns tags', () async {
      final tags = [makeTag(id: 'tag-1'), makeTag(id: 'tag-2')];
      when(
        () => mockLocal.getTagsForTask('task-1'),
      ).thenAnswer((_) async => tags);

      final result = await repository.getTagsForTask('task-1');

      expect(result, tags);
      verify(() => mockLocal.getTagsForTask('task-1')).called(1);
    });
  });

  // ============================================================
  // Group 5: Sync operations
  // ============================================================
  group('sync operations', () {
    test('getUnsyncedTasks delegates to local', () async {
      final tasks = [
        makeEntity(id: 'task-1', isSynced: false),
        makeEntity(id: 'task-2', isSynced: false),
      ];
      when(() => mockLocal.getUnsyncedTasks()).thenAnswer((_) async => tasks);

      final result = await repository.getUnsyncedTasks();

      expect(result, tasks);
      verify(() => mockLocal.getUnsyncedTasks()).called(1);
    });

    test('markSynced delegates to local', () async {
      when(() => mockLocal.markSynced('task-1')).thenAnswer((_) async {});

      await repository.markSynced('task-1');

      verify(() => mockLocal.markSynced('task-1')).called(1);
    });
  });

  // ============================================================
  // Group 6: Write operations wait for ready
  // ============================================================
  group('write operations wait for ready', () {
    setUp(() {
      when(() => mockSyncService.syncNow()).thenAnswer((_) async {});
    });

    test('createTask waits for ready before delegating to local', () async {
      final completer = Completer<void>();
      final repo = SyncedTaskRepository(
        local: mockLocal,
        syncService: mockSyncService,
        ready: completer.future,
      );
      final task = makeEntity(id: 'task-1');
      when(() => mockLocal.createTask(any())).thenAnswer((_) async {});

      final future = repo.createTask(task);

      // ready가 완료되기 전에는 local에 위임하지 않음
      await Future<void>.delayed(Duration.zero);
      verifyNever(() => mockLocal.createTask(any()));

      completer.complete();
      await future;

      verify(() => mockLocal.createTask(task)).called(1);
    });

    test('updateTask waits for ready before delegating to local', () async {
      final completer = Completer<void>();
      final repo = SyncedTaskRepository(
        local: mockLocal,
        syncService: mockSyncService,
        ready: completer.future,
      );
      final task = makeEntity(id: 'task-1', title: 'Updated');
      when(() => mockLocal.updateTask(any())).thenAnswer((_) async {});

      final future = repo.updateTask(task);

      await Future<void>.delayed(Duration.zero);
      verifyNever(() => mockLocal.updateTask(any()));

      completer.complete();
      await future;

      verify(() => mockLocal.updateTask(task)).called(1);
    });

    test('deleteTask waits for ready before delegating to local', () async {
      final completer = Completer<void>();
      final repo = SyncedTaskRepository(
        local: mockLocal,
        syncService: mockSyncService,
        ready: completer.future,
      );
      when(() => mockLocal.deleteTask(any())).thenAnswer((_) async {});

      final future = repo.deleteTask('task-1');

      await Future<void>.delayed(Duration.zero);
      verifyNever(() => mockLocal.deleteTask(any()));

      completer.complete();
      await future;

      verify(() => mockLocal.deleteTask('task-1')).called(1);
    });

    test('reorderTasks waits for ready before delegating to local', () async {
      final completer = Completer<void>();
      final repo = SyncedTaskRepository(
        local: mockLocal,
        syncService: mockSyncService,
        ready: completer.future,
      );
      when(() => mockLocal.reorderTasks(any())).thenAnswer((_) async {});

      final orders = {'task-1': 0, 'task-2': 1};
      final future = repo.reorderTasks(orders);

      await Future<void>.delayed(Duration.zero);
      verifyNever(() => mockLocal.reorderTasks(any()));

      completer.complete();
      await future;

      verify(() => mockLocal.reorderTasks(orders)).called(1);
    });

    test('read operations do not wait for ready', () async {
      final completer = Completer<void>();
      final repo = SyncedTaskRepository(
        local: mockLocal,
        syncService: mockSyncService,
        ready: completer.future,
      );
      final task = makeEntity(id: 'task-1');
      when(() => mockLocal.getTaskById('task-1')).thenAnswer((_) async => task);
      when(
        () => mockLocal.watchAllTasks(),
      ).thenAnswer((_) => Stream.value([task]));

      // ready가 미완료여도 read는 즉시 동작
      final result = await repo.getTaskById('task-1');
      expect(result, task);

      expect(repo.watchAllTasks(), emits([task]));

      // completer는 아직 완료되지 않음
      completer.complete();
    });
  });

  // ============================================================
  // Group 7: Write operations trigger syncNow
  // ============================================================
  group('write operations trigger syncNow', () {
    test('createTask calls syncNow after local write', () async {
      final task = makeEntity(id: 'task-1');
      when(() => mockLocal.createTask(any())).thenAnswer((_) async {});
      when(() => mockSyncService.syncNow()).thenAnswer((_) async {});

      await repository.createTask(task);

      verifyInOrder([
        () => mockLocal.createTask(task),
        () => mockSyncService.syncNow(),
      ]);
    });

    test('updateTask calls syncNow after local write', () async {
      final task = makeEntity(id: 'task-1', title: 'Updated');
      when(() => mockLocal.updateTask(any())).thenAnswer((_) async {});
      when(() => mockSyncService.syncNow()).thenAnswer((_) async {});

      await repository.updateTask(task);

      verifyInOrder([
        () => mockLocal.updateTask(task),
        () => mockSyncService.syncNow(),
      ]);
    });

    test('deleteTask calls syncNow after local write', () async {
      when(() => mockLocal.deleteTask(any())).thenAnswer((_) async {});
      when(() => mockSyncService.syncNow()).thenAnswer((_) async {});

      await repository.deleteTask('task-1');

      verifyInOrder([
        () => mockLocal.deleteTask('task-1'),
        () => mockSyncService.syncNow(),
      ]);
    });

    test('reorderTasks calls syncNow after local write', () async {
      when(() => mockLocal.reorderTasks(any())).thenAnswer((_) async {});
      when(() => mockSyncService.syncNow()).thenAnswer((_) async {});

      final orders = {'task-1': 0, 'task-2': 1};
      await repository.reorderTasks(orders);

      verifyInOrder([
        () => mockLocal.reorderTasks(orders),
        () => mockSyncService.syncNow(),
      ]);
    });

    test('upsertTask does not call syncNow', () async {
      final task = makeEntity(id: 'task-1');
      when(() => mockLocal.upsertTask(any())).thenAnswer((_) async {});

      await repository.upsertTask(task);

      verifyNever(() => mockSyncService.syncNow());
    });

    test('read operations do not call syncNow', () async {
      final task = makeEntity(id: 'task-1');
      when(() => mockLocal.getTaskById(any())).thenAnswer((_) async => task);
      when(() => mockLocal.getUnsyncedTasks()).thenAnswer((_) async => [task]);

      await repository.getTaskById('task-1');
      await repository.getUnsyncedTasks();

      verifyNever(() => mockSyncService.syncNow());
    });
  });
}
