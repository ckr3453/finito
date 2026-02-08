import 'package:todo_app/domain/entities/entities.dart';
import 'package:todo_app/domain/enums/enums.dart';

abstract class TaskRepository {
  Stream<List<TaskEntity>> watchAllTasks();
  Stream<List<TaskEntity>> watchTasksFiltered({
    TaskStatus? status,
    Priority? priority,
    String? categoryId,
    String? searchQuery,
  });
  Future<TaskEntity?> getTaskById(String id);
  Future<void> createTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String id);
  Future<void> setTagsForTask(String taskId, List<String> tagIds);
  Future<List<TagEntity>> getTagsForTask(String taskId);
  Future<List<TaskEntity>> getUnsyncedTasks();
  Future<void> markSynced(String id);
}
