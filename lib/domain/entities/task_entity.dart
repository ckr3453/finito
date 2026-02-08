import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:todo_app/domain/enums/enums.dart';

part 'task_entity.freezed.dart';
part 'task_entity.g.dart';

@freezed
abstract class TaskEntity with _$TaskEntity {
  const factory TaskEntity({
    required String id,
    required String title,
    @Default('') String description,
    @Default(TaskStatus.pending) TaskStatus status,
    @Default(Priority.medium) Priority priority,
    String? categoryId,
    @Default([]) List<String> tagIds,
    DateTime? dueDate,
    DateTime? completedAt,
    @Default(0) int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isSynced,
  }) = _TaskEntity;

  factory TaskEntity.fromJson(Map<String, dynamic> json) =>
      _$TaskEntityFromJson(json);
}
