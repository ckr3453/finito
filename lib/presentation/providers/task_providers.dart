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
  return repo
      .watchTasksFiltered(
        status: filter.status,
        priority: filter.priority,
        categoryId: filter.categoryId,
        searchQuery: filter.searchQuery,
      )
      .map((tasks) => _sortTasks(tasks, filter.sortBy));
}

List<TaskEntity> _sortTasks(List<TaskEntity> tasks, TaskSortBy sortBy) {
  final sorted = List<TaskEntity>.from(tasks);
  sorted.sort((a, b) {
    int cmp;
    switch (sortBy) {
      case TaskSortBy.dueDate:
        final ad = a.dueDate;
        final bd = b.dueDate;
        if (ad == null && bd == null) {
          cmp = 0;
        } else if (ad == null) {
          cmp = 1;
        } else if (bd == null) {
          cmp = -1;
        } else {
          cmp = ad.compareTo(bd);
        }
      case TaskSortBy.priority:
        cmp = a.priority.index.compareTo(b.priority.index);
      case TaskSortBy.createdAt:
        cmp = b.createdAt.compareTo(a.createdAt);
    }
    if (cmp == 0) {
      cmp = a.title.compareTo(b.title);
    }
    return cmp;
  });
  return sorted;
}

@riverpod
Future<TaskEntity?> taskDetail(Ref ref, String taskId) {
  return ref.watch(taskRepositoryProvider).getTaskById(taskId);
}

@riverpod
Future<List<TagEntity>> taskTags(Ref ref, String taskId) {
  return ref.watch(taskRepositoryProvider).getTagsForTask(taskId);
}
