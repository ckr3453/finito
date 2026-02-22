import 'package:todo_app/data/repositories/local_task_repository.dart';
import 'package:todo_app/domain/entities/entities.dart';
import 'package:todo_app/domain/enums/enums.dart';
import 'package:todo_app/domain/repositories/task_repository.dart';
import 'package:todo_app/services/task_sync_service.dart';

class SyncedTaskRepository implements TaskRepository {
  final LocalTaskRepository _local;
  final TaskSyncService _syncService;

  SyncedTaskRepository({
    required LocalTaskRepository local,
    required TaskSyncService syncService,
  }) : _local = local,
       _syncService = syncService;

  TaskSyncService get syncService => _syncService;

  @override
  Stream<List<TaskEntity>> watchAllTasks() {
    return _local.watchAllTasks();
  }

  @override
  Stream<List<TaskEntity>> watchTasksFiltered({
    TaskStatus? status,
    Priority? priority,
    String? categoryId,
    String? searchQuery,
  }) {
    return _local.watchTasksFiltered(
      status: status,
      priority: priority,
      categoryId: categoryId,
      searchQuery: searchQuery,
    );
  }

  @override
  Future<TaskEntity?> getTaskById(String id) {
    return _local.getTaskById(id);
  }

  @override
  Future<void> createTask(TaskEntity task) {
    return _local.createTask(task);
  }

  @override
  Future<void> updateTask(TaskEntity task) {
    return _local.updateTask(task);
  }

  @override
  Future<void> upsertTask(TaskEntity task) {
    return _local.upsertTask(task);
  }

  @override
  Future<void> deleteTask(String id) {
    return _local.deleteTask(id);
  }

  @override
  Future<void> setTagsForTask(String taskId, List<String> tagIds) {
    return _local.setTagsForTask(taskId, tagIds);
  }

  @override
  Future<List<TagEntity>> getTagsForTask(String taskId) {
    return _local.getTagsForTask(taskId);
  }

  @override
  Future<List<TaskEntity>> getUnsyncedTasks() {
    return _local.getUnsyncedTasks();
  }

  @override
  Future<void> markSynced(String id) {
    return _local.markSynced(id);
  }
}
