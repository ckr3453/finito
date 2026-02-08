import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [TaskItems, TaskTags, Tags])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  // CRUD
  Future<List<TaskItem>> getAllTasks() => select(taskItems).get();

  Stream<List<TaskItem>> watchAllTasks() => select(taskItems).watch();

  Stream<List<TaskItem>> watchTasksByStatus(int status) {
    return (select(taskItems)..where((t) => t.status.equals(status))).watch();
  }

  Future<TaskItem?> getTaskById(String id) {
    return (select(taskItems)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertTask(TaskItemsCompanion task) {
    return into(taskItems).insert(task);
  }

  Future<bool> updateTask(TaskItemsCompanion task) {
    return update(taskItems).replace(task);
  }

  Future<int> deleteTask(String id) {
    return (delete(taskItems)..where((t) => t.id.equals(id))).go();
  }

  // Tag relations
  Future<void> setTagsForTask(String taskId, List<String> tagIds) async {
    await (delete(taskTags)..where((t) => t.taskId.equals(taskId))).go();
    for (final tagId in tagIds) {
      await into(taskTags).insert(TaskTagsCompanion.insert(
        taskId: taskId,
        tagId: tagId,
      ));
    }
  }

  Future<List<Tag>> getTagsForTask(String taskId) {
    final query = select(tags).join([
      innerJoin(taskTags, taskTags.tagId.equalsExp(tags.id)),
    ])
      ..where(taskTags.taskId.equals(taskId));
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
    if (status != null) query.where((t) => t.status.equals(status));
    if (priority != null) query.where((t) => t.priority.equals(priority));
    if (categoryId != null) {
      query.where((t) => t.categoryId.equals(categoryId));
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where(
        (t) => t.title.contains(searchQuery) | t.description.contains(searchQuery),
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
    return (update(taskItems)..where((t) => t.id.equals(id)))
        .write(const TaskItemsCompanion(isSynced: Value(true)));
  }
}
