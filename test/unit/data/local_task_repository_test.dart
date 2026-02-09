import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/data/database/app_database.dart';
import 'package:todo_app/data/repositories/local_task_repository.dart';
import 'package:todo_app/domain/entities/entities.dart';
import 'package:todo_app/domain/enums/enums.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late LocalTaskRepository repo;
  final now = DateTime.now();

  setUp(() {
    db = createTestDatabase();
    repo = LocalTaskRepository(db);
  });

  tearDown(() => db.close());

  TaskEntity makeTask({
    String id = 'task-1',
    String title = 'Test Task',
    TaskStatus status = TaskStatus.pending,
    Priority priority = Priority.medium,
    String? categoryId,
    List<String> tagIds = const [],
    bool isSynced = false,
  }) {
    return TaskEntity(
      id: id,
      title: title,
      status: status,
      priority: priority,
      categoryId: categoryId,
      tagIds: tagIds,
      createdAt: now,
      updatedAt: now,
      isSynced: isSynced,
    );
  }

  Future<void> insertTags(List<String> tagIds) async {
    for (final tagId in tagIds) {
      await db.tagDao.insertTag(
        TagsCompanion.insert(
          id: tagId,
          name: 'Tag $tagId',
          colorValue: 0xFFEF5350,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  group('createTask and getTaskById', () {
    test('round-trips task with correct enum values', () async {
      await repo.createTask(
        makeTask(status: TaskStatus.completed, priority: Priority.high),
      );

      final result = await repo.getTaskById('task-1');

      expect(result, isNotNull);
      expect(result!.id, 'task-1');
      expect(result.title, 'Test Task');
      expect(result.status, TaskStatus.completed);
      expect(result.priority, Priority.high);
    });

    test('creates task with tags', () async {
      await insertTags(['tag-1', 'tag-2']);
      await repo.createTask(makeTask(tagIds: ['tag-1', 'tag-2']));

      final result = await repo.getTaskById('task-1');

      expect(result, isNotNull);
      expect(result!.tagIds, unorderedEquals(['tag-1', 'tag-2']));
    });

    test('returns null for nonexistent id', () async {
      final result = await repo.getTaskById('nonexistent');
      expect(result, isNull);
    });
  });

  group('updateTask', () {
    test('updates task fields and tags', () async {
      await insertTags(['tag-1', 'tag-2', 'tag-3']);
      await repo.createTask(makeTask(tagIds: ['tag-1', 'tag-2']));

      final updated = makeTask(
        title: 'Updated',
        status: TaskStatus.completed,
        priority: Priority.low,
        tagIds: ['tag-3'],
      );
      await repo.updateTask(updated);

      final result = await repo.getTaskById('task-1');
      expect(result!.title, 'Updated');
      expect(result.status, TaskStatus.completed);
      expect(result.priority, Priority.low);
      expect(result.tagIds, ['tag-3']);
    });
  });

  group('deleteTask', () {
    test('soft-deletes task so getTaskById returns null', () async {
      await repo.createTask(makeTask());
      await repo.deleteTask('task-1');

      final result = await repo.getTaskById('task-1');
      expect(result, isNull);
    });
  });

  group('deletedAt mapping', () {
    test('round-trips deletedAt through entity → companion → entity', () async {
      final deletedTime = DateTime(2026, 1, 15, 10, 30);
      final task = TaskEntity(
        id: 'del-task',
        title: 'Deleted Task',
        createdAt: now,
        updatedAt: now,
        deletedAt: deletedTime,
      );
      await repo.createTask(task);

      // Read raw from DB to verify deletedAt was persisted
      final raw = await (db.select(db.taskItems)
            ..where((t) => t.id.equals('del-task')))
          .getSingleOrNull();
      expect(raw, isNotNull);
      expect(raw!.deletedAt, isNotNull);
      // DateTime precision: compare to second
      expect(
        raw.deletedAt!.difference(deletedTime).inSeconds.abs(),
        lessThan(2),
      );
    });
  });

  group('upsertTask', () {
    test('inserts a new task via repository', () async {
      final task = makeTask(id: 'upsert-new', title: 'Upserted New');
      await repo.upsertTask(task);

      final result = await repo.getTaskById('upsert-new');
      expect(result, isNotNull);
      expect(result!.title, 'Upserted New');
    });

    test('updates existing task on conflict via repository', () async {
      await repo.createTask(makeTask(id: 'upsert-exist', title: 'Original'));
      final updated = makeTask(id: 'upsert-exist', title: 'Upserted Updated');
      await repo.upsertTask(updated);

      final result = await repo.getTaskById('upsert-exist');
      expect(result, isNotNull);
      expect(result!.title, 'Upserted Updated');
    });
  });

  group('watchTasksFiltered', () {
    test('passes enum filters correctly', () async {
      await repo.createTask(
        makeTask(
          id: 'pending-high',
          status: TaskStatus.pending,
          priority: Priority.high,
        ),
      );
      await repo.createTask(
        makeTask(
          id: 'completed-low',
          status: TaskStatus.completed,
          priority: Priority.low,
        ),
      );

      final stream = repo.watchTasksFiltered(
        status: TaskStatus.pending,
        priority: Priority.high,
      );
      final result = await stream.first;

      expect(result, hasLength(1));
      expect(result.first.id, 'pending-high');
      expect(result.first.status, TaskStatus.pending);
      expect(result.first.priority, Priority.high);
    });

    test('returns all when no filters', () async {
      await repo.createTask(makeTask(id: 'a'));
      await repo.createTask(makeTask(id: 'b'));

      final result = await repo.watchAllTasks().first;
      expect(result, hasLength(2));
    });
  });

  group('setTagsForTask and getTagsForTask', () {
    test('sets and retrieves tags via repository', () async {
      await insertTags(['tag-1', 'tag-2']);
      await repo.createTask(makeTask());

      await repo.setTagsForTask('task-1', ['tag-1', 'tag-2']);
      final tags = await repo.getTagsForTask('task-1');

      expect(tags, hasLength(2));
      expect(tags.map((t) => t.id).toSet(), {'tag-1', 'tag-2'});
      // Verify returned as TagEntity
      expect(tags.first, isA<TagEntity>());
    });
  });

  group('Sync support', () {
    test('getUnsyncedTasks returns only unsynced', () async {
      await repo.createTask(makeTask(id: 'synced', isSynced: true));
      await repo.createTask(makeTask(id: 'unsynced', isSynced: false));

      final unsynced = await repo.getUnsyncedTasks();
      expect(unsynced, hasLength(1));
      expect(unsynced.first.id, 'unsynced');
      expect(unsynced.first.status, isA<TaskStatus>()); // enum conversion
    });

    test('markSynced updates sync flag', () async {
      await repo.createTask(makeTask(id: 'task-1', isSynced: false));
      await repo.markSynced('task-1');

      final unsynced = await repo.getUnsyncedTasks();
      expect(unsynced, isEmpty);
    });
  });
}
