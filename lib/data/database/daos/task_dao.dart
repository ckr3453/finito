import 'package:drift/drift.dart';
import 'package:todo_app/data/database/app_database.dart';
import 'package:todo_app/data/database/tables.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [TaskItems, TaskTags, Tags])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  // CRUD
  Future<List<TaskItem>> getAllTasks() {
    return (select(taskItems)..where((t) => t.deletedAt.isNull())).get();
  }

  Stream<List<TaskItem>> watchAllTasks() {
    return (select(taskItems)..where((t) => t.deletedAt.isNull())).watch();
  }

  Stream<List<TaskItem>> watchTasksByStatus(int status) {
    return (select(
      taskItems,
    )..where((t) => t.deletedAt.isNull() & t.status.equals(status))).watch();
  }

  Future<TaskItem?> getTaskById(String id) {
    return (select(
      taskItems,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
  }

  Future<int> insertTask(TaskItemsCompanion task) {
    return into(taskItems).insert(task);
  }

  Future<bool> updateTask(TaskItemsCompanion task) {
    return update(taskItems).replace(task);
  }

  Future<void> deleteTask(String id) {
    return (update(taskItems)..where((t) => t.id.equals(id))).write(
      TaskItemsCompanion(
        deletedAt: Value(DateTime.now()),
        isSynced: const Value(false),
      ),
    );
  }

  // Upsert
  Future<void> upsertTask(TaskItemsCompanion task) {
    return into(taskItems).insertOnConflictUpdate(task);
  }

  // Purge
  Future<int> purgeDeletedTasks(DateTime before) {
    return (delete(taskItems)..where(
          (t) =>
              t.deletedAt.isNotNull() & t.deletedAt.isSmallerThanValue(before),
        ))
        .go();
  }

  // Tag relations
  Future<void> setTagsForTask(String taskId, List<String> tagIds) async {
    await (delete(taskTags)..where((t) => t.taskId.equals(taskId))).go();
    for (final tagId in tagIds) {
      await into(
        taskTags,
      ).insert(TaskTagsCompanion.insert(taskId: taskId, tagId: tagId));
    }
  }

  Future<List<Tag>> getTagsForTask(String taskId) {
    final query = select(tags).join([
      innerJoin(taskTags, taskTags.tagId.equalsExp(tags.id)),
    ])..where(taskTags.taskId.equals(taskId));
    return query.map((row) => row.readTable(tags)).get();
  }

  // Search & Filter
  Stream<List<TaskItem>> watchTasksFiltered({
    int? status,
    int? priority,
    String? categoryId,
    String? searchQuery,
  }) {
    final query = select(taskItems);
    query.where((t) => t.deletedAt.isNull());
    if (status != null) query.where((t) => t.status.equals(status));
    if (priority != null) query.where((t) => t.priority.equals(priority));
    if (categoryId != null) {
      query.where((t) => t.categoryId.equals(categoryId));
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where(
        (t) =>
            t.title.contains(searchQuery) | t.description.contains(searchQuery),
      );
    }
    query.orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return query.watch();
  }

  // Sync support
  Future<List<TaskItem>> getUnsyncedTasks() {
    return (select(taskItems)..where((t) => t.isSynced.equals(false))).get();
  }

  Future<void> markSynced(String id) {
    return (update(taskItems)..where((t) => t.id.equals(id))).write(
      const TaskItemsCompanion(isSynced: Value(true)),
    );
  }

  Future<void> updateSortOrders(Map<String, int> sortOrders) async {
    await transaction(() async {
      final now = DateTime.now();
      for (final entry in sortOrders.entries) {
        await (update(taskItems)..where((t) => t.id.equals(entry.key))).write(
          TaskItemsCompanion(
            sortOrder: Value(entry.value),
            isSynced: const Value(false),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }
}
