import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/domain/entities/entities.dart';
import 'repository_providers.dart';
import 'filter_providers.dart';

part 'task_providers.g.dart';

@riverpod
Stream<List<TaskEntity>> taskList(ref) {
  final repo = ref.watch(taskRepositoryProvider);
  final filter = ref.watch(taskFilterProvider);
  return repo.watchTasksFiltered(
    status: filter.status,
    priority: filter.priority,
    categoryId: filter.categoryId,
    searchQuery: filter.searchQuery,
  );
}

@riverpod
Future<TaskEntity?> taskDetail(ref, String taskId) {
  return ref.watch(taskRepositoryProvider).getTaskById(taskId);
}

@riverpod
Future<List<TagEntity>> taskTags(ref, String taskId) {
  return ref.watch(taskRepositoryProvider).getTagsForTask(taskId);
}
