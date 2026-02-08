import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/data/database/app_database.dart';
import 'package:todo_app/data/database/daos/task_dao.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late TaskDao dao;

  setUp(() {
    db = createTestDatabase();
    dao = db.taskDao;
  });

  tearDown(() => db.close());

  TaskItemsCompanion makeTask({
    String id = 'task-1',
    String title = 'Test Task',
    int status = 0,
    int priority = 1,
    String? categoryId,
    bool isSynced = false,
  }) {
    final now = DateTime.now();
    return TaskItemsCompanion.insert(
      id: id,
      title: title,
      status: status,
      priority: priority,
      categoryId: Value(categoryId),
      createdAt: now,
      updatedAt: now,
      isSynced: Value(isSynced),
    );
  }

  group('CRUD', () {
    test('insert and getById returns the task', () async {
      await dao.insertTask(makeTask());

      final result = await dao.getTaskById('task-1');

      expect(result, isNotNull);
      expect(result!.id, 'task-1');
      expect(result.title, 'Test Task');
      expect(result.status, 0); // pending
      expect(result.priority, 1); // medium
    });

    test('getAllTasks returns all inserted tasks', () async {
      await dao.insertTask(makeTask(id: 'a', title: 'A'));
      await dao.insertTask(makeTask(id: 'b', title: 'B'));

      final all = await dao.getAllTasks();
      expect(all, hasLength(2));
    });

    test('updateTask modifies existing task', () async {
      await dao.insertTask(makeTask());
      final now = DateTime.now();

      await dao.updateTask(
        TaskItemsCompanion(
          id: const Value('task-1'),
          title: const Value('Updated'),
          description: const Value('desc'),
          status: const Value(1), // completed
          priority: const Value(0), // high
          categoryId: const Value(null),
          dueDate: const Value(null),
          completedAt: Value(now),
          sortOrder: const Value(0),
          createdAt: Value(now),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ),
      );

      final result = await dao.getTaskById('task-1');
      expect(result!.title, 'Updated');
      expect(result.status, 1);
    });

    test('deleteTask removes the task', () async {
      await dao.insertTask(makeTask());
      await dao.deleteTask('task-1');

      final result = await dao.getTaskById('task-1');
      expect(result, isNull);
    });

    test('getById returns null for nonexistent id', () async {
      final result = await dao.getTaskById('nonexistent');
      expect(result, isNull);
    });
  });

  group('watchAllTasks stream', () {
    test('emits list containing inserted task', () async {
      // Listen to stream before inserting
      final future = dao.watchAllTasks().firstWhere((list) => list.isNotEmpty);

      await dao.insertTask(makeTask());

      final result = await future;
      expect(result, hasLength(1));
      expect(result.first.id, 'task-1');
    });
  });

  group('watchTasksFiltered', () {
    Future<void> seedTasks() async {
      await dao.insertTask(
        makeTask(
          id: 'pending-high',
          title: 'Urgent work',
          status: 0,
          priority: 0,
        ),
      );
      await dao.insertTask(
        makeTask(
          id: 'completed-medium',
          title: 'Done task',
          status: 1,
          priority: 1,
        ),
      );
      await dao.insertTask(
        makeTask(
          id: 'pending-low',
          title: 'Low priority',
          status: 0,
          priority: 2,
        ),
      );
    }

    test('filters by status only', () async {
      await seedTasks();

      final stream = dao.watchTasksFiltered(status: 0);
      final result = await stream.first;

      expect(result, hasLength(2));
      expect(result.every((t) => t.status == 0), isTrue);
    });

    test('filters by priority only', () async {
      await seedTasks();

      final stream = dao.watchTasksFiltered(priority: 0);
      final result = await stream.first;

      expect(result, hasLength(1));
      expect(result.first.id, 'pending-high');
    });

    test('filters by searchQuery on title', () async {
      await seedTasks();

      final stream = dao.watchTasksFiltered(searchQuery: 'Urgent');
      final result = await stream.first;

      expect(result, hasLength(1));
      expect(result.first.id, 'pending-high');
    });

    test('combined status + priority filter', () async {
      await seedTasks();

      final stream = dao.watchTasksFiltered(status: 0, priority: 2);
      final result = await stream.first;

      expect(result, hasLength(1));
      expect(result.first.id, 'pending-low');
    });

    test('returns empty for no matches', () async {
      await seedTasks();

      final stream = dao.watchTasksFiltered(status: 2); // archived
      final result = await stream.first;

      expect(result, isEmpty);
    });
  });

  group('Tag relations', () {
    setUp(() async {
      await dao.insertTask(makeTask());
      // Insert tags directly into the tags table
      await db
          .into(db.tags)
          .insert(
            TagsCompanion.insert(
              id: 'tag-1',
              name: 'urgent',
              colorValue: 0xFFEF5350,
              createdAt: DateTime.now(),
            ),
          );
      await db
          .into(db.tags)
          .insert(
            TagsCompanion.insert(
              id: 'tag-2',
              name: 'work',
              colorValue: 0xFF42A5F5,
              createdAt: DateTime.now(),
            ),
          );
    });

    test('setTagsForTask and getTagsForTask', () async {
      await dao.setTagsForTask('task-1', ['tag-1', 'tag-2']);

      final tags = await dao.getTagsForTask('task-1');
      expect(tags, hasLength(2));
      expect(tags.map((t) => t.id).toSet(), {'tag-1', 'tag-2'});
    });

    test('setTagsForTask replaces existing tags', () async {
      await dao.setTagsForTask('task-1', ['tag-1', 'tag-2']);
      await dao.setTagsForTask('task-1', ['tag-1']);

      final tags = await dao.getTagsForTask('task-1');
      expect(tags, hasLength(1));
      expect(tags.first.id, 'tag-1');
    });

    test('setTagsForTask with empty list removes all tags', () async {
      await dao.setTagsForTask('task-1', ['tag-1']);
      await dao.setTagsForTask('task-1', []);

      final tags = await dao.getTagsForTask('task-1');
      expect(tags, isEmpty);
    });
  });

  group('Sync support', () {
    test('getUnsyncedTasks returns only unsynced', () async {
      await dao.insertTask(makeTask(id: 'synced', isSynced: true));
      await dao.insertTask(makeTask(id: 'unsynced', isSynced: false));

      final unsynced = await dao.getUnsyncedTasks();
      expect(unsynced, hasLength(1));
      expect(unsynced.first.id, 'unsynced');
    });

    test('markSynced sets isSynced to true', () async {
      await dao.insertTask(makeTask(id: 'task-1', isSynced: false));
      await dao.markSynced('task-1');

      final task = await dao.getTaskById('task-1');
      expect(task!.isSynced, isTrue);
    });
  });
}
