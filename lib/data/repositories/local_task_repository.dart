import 'package:drift/drift.dart';
import 'package:todo_app/data/database/app_database.dart';
import 'package:todo_app/domain/entities/entities.dart';
import 'package:todo_app/domain/enums/enums.dart';
import 'package:todo_app/domain/repositories/task_repository.dart';

class LocalTaskRepository implements TaskRepository {
  final AppDatabase _db;

  LocalTaskRepository(this._db);

  // ---------------------------------------------------------------------------
  // Drift TaskItem -> Domain TaskEntity
  // ---------------------------------------------------------------------------
  TaskEntity _toEntity(TaskItem item, {List<String> tagIds = const []}) {
    return TaskEntity(
      id: item.id,
      title: item.title,
      description: item.description,
      status: TaskStatus.values[item.status],
      priority: Priority.values[item.priority],
      categoryId: item.categoryId,
      tagIds: tagIds,
      dueDate: item.dueDate,
      completedAt: item.completedAt,
      sortOrder: item.sortOrder,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      isSynced: item.isSynced,
    );
  }

  // ---------------------------------------------------------------------------
  // Domain TaskEntity -> Drift TaskItemsCompanion
  // ---------------------------------------------------------------------------
  TaskItemsCompanion _toCompanion(TaskEntity entity) {
    return TaskItemsCompanion(
      id: Value(entity.id),
      title: Value(entity.title),
      description: Value(entity.description),
      status: Value(entity.status.index),
      priority: Value(entity.priority.index),
      categoryId: Value(entity.categoryId),
      dueDate: Value(entity.dueDate),
      completedAt: Value(entity.completedAt),
      sortOrder: Value(entity.sortOrder),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      isSynced: Value(entity.isSynced),
    );
  }

  // ---------------------------------------------------------------------------
  // Drift Tag -> Domain TagEntity
  // ---------------------------------------------------------------------------
  TagEntity _tagToEntity(Tag tag) {
    return TagEntity(
      id: tag.id,
      name: tag.name,
      colorValue: tag.colorValue,
      createdAt: tag.createdAt,
    );
  }

  // ---------------------------------------------------------------------------
  // TaskRepository implementation
  // ---------------------------------------------------------------------------

  @override
  Stream<List<TaskEntity>> watchAllTasks() {
    return _db.taskDao.watchAllTasks().map(
      (items) => items.map((item) => _toEntity(item)).toList(),
    );
  }

  @override
  Stream<List<TaskEntity>> watchTasksFiltered({
    TaskStatus? status,
    Priority? priority,
    String? categoryId,
    String? searchQuery,
  }) {
    return _db.taskDao
        .watchTasksFiltered(
          status: status?.index,
          priority: priority?.index,
          categoryId: categoryId,
          searchQuery: searchQuery,
        )
        .map(
          (items) => items.map((item) => _toEntity(item)).toList(),
        );
  }

  @override
  Future<TaskEntity?> getTaskById(String id) async {
    final item = await _db.taskDao.getTaskById(id);
    if (item == null) return null;

    final tags = await _db.taskDao.getTagsForTask(id);
    final tagIds = tags.map((t) => t.id).toList();
    return _toEntity(item, tagIds: tagIds);
  }

  @override
  Future<void> createTask(TaskEntity task) async {
    await _db.taskDao.insertTask(_toCompanion(task));
    if (task.tagIds.isNotEmpty) {
      await _db.taskDao.setTagsForTask(task.id, task.tagIds);
    }
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    await _db.taskDao.updateTask(_toCompanion(task));
    await _db.taskDao.setTagsForTask(task.id, task.tagIds);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _db.taskDao.deleteTask(id);
  }

  @override
  Future<void> setTagsForTask(String taskId, List<String> tagIds) async {
    await _db.taskDao.setTagsForTask(taskId, tagIds);
  }

  @override
  Future<List<TagEntity>> getTagsForTask(String taskId) async {
    final tags = await _db.taskDao.getTagsForTask(taskId);
    return tags.map(_tagToEntity).toList();
  }

  @override
  Future<List<TaskEntity>> getUnsyncedTasks() async {
    final items = await _db.taskDao.getUnsyncedTasks();
    return items.map((item) => _toEntity(item)).toList();
  }

  @override
  Future<void> markSynced(String id) async {
    await _db.taskDao.markSynced(id);
  }
}
