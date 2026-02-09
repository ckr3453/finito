import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/domain/entities/entities.dart';
import 'package:todo_app/presentation/providers/repository_providers.dart';
import 'package:todo_app/presentation/providers/filter_providers.dart';

part 'task_providers.g.dart';

@riverpod
Stream<List<TaskEntity>> taskList(Ref ref) {
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
Future<TaskEntity?> taskDetail(Ref ref, String taskId) {
  return ref.watch(taskRepositoryProvider).getTaskById(taskId);
}

@riverpod
Future<List<TagEntity>> taskTags(Ref ref, String taskId) {
  return ref.watch(taskRepositoryProvider).getTagsForTask(taskId);
}
