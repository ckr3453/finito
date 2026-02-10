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
  // Group 6: No direct interaction with sync service
  // ============================================================
  group('sync service interaction', () {
    test('write operations do not directly call sync service', () async {
      final task = makeEntity(id: 'task-1');
      when(() => mockLocal.createTask(any())).thenAnswer((_) async {});
      when(() => mockLocal.updateTask(any())).thenAnswer((_) async {});
      when(() => mockLocal.deleteTask(any())).thenAnswer((_) async {});

      await repository.createTask(task);
      await repository.updateTask(task);
      await repository.deleteTask('task-1');

      verifyZeroInteractions(mockSyncService);
    });
  });
}
