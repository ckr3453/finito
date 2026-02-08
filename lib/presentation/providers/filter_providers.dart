import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:todo_app/domain/enums/enums.dart';

part 'filter_providers.freezed.dart';

@freezed
abstract class TaskFilter with _$TaskFilter {
  const factory TaskFilter({
    TaskStatus? status,
    Priority? priority,
    String? categoryId,
    String? searchQuery,
  }) = _TaskFilter;
}

class TaskFilterNotifier extends StateNotifier<TaskFilter> {
  TaskFilterNotifier() : super(const TaskFilter());

  void setStatus(TaskStatus? status) => state = state.copyWith(status: status);
  void setPriority(Priority? priority) => state = state.copyWith(priority: priority);
  void setCategoryId(String? id) => state = state.copyWith(categoryId: id);
  void setSearchQuery(String? query) => state = state.copyWith(searchQuery: query);
  void clearAll() => state = const TaskFilter();
}

final taskFilterProvider = StateNotifierProvider<TaskFilterNotifier, TaskFilter>(
  (ref) => TaskFilterNotifier(),
);
