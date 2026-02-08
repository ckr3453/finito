import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/core/extensions.dart';
import 'package:todo_app/domain/entities/entities.dart';
import 'package:todo_app/domain/enums/enums.dart';
import 'package:todo_app/presentation/providers/repository_providers.dart';
import 'package:todo_app/presentation/shared_widgets/priority_indicator.dart';

class TaskListTile extends ConsumerWidget {
  final TaskEntity task;
  final CategoryEntity? category;

  const TaskListTile({super.key, required this.task, this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isCompleted = task.status == TaskStatus.completed;
    final isOverdue =
        task.dueDate != null && task.dueDate!.isOverdue && !isCompleted;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) => _confirmDelete(context),
      onDismissed: (_) {
        ref.read(taskRepositoryProvider).deleteTask(task.id);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            context.pushNamed('taskDetail', pathParameters: {'id': task.id});
          },
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Priority color bar on the left
                PriorityIndicator(priority: task.priority, width: 5),
                // Checkbox
                Checkbox(
                  value: isCompleted,
                  onChanged: (_) => _toggleCompletion(ref),
                ),
                // Content area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          task.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: isCompleted
                                ? theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  )
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Bottom row: due date + category
                        Row(
                          children: [
                            // Due date
                            if (task.dueDate != null) ...[
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: isOverdue
                                    ? Colors.red
                                    : theme.colorScheme.onSurface.withValues(
                                        alpha: 0.5,
                                      ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task.dueDate!.toFormattedDate(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isOverdue
                                      ? Colors.red
                                      : theme.colorScheme.onSurface.withValues(
                                          alpha: 0.5,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            // Category chip
                            if (category != null)
                              Flexible(
                                child: Chip(
                                  label: Text(category!.name),
                                  labelStyle: theme.textTheme.labelSmall,
                                  backgroundColor: Color(
                                    category!.colorValue,
                                  ).withValues(alpha: 0.2),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('할 일 삭제'),
        content: Text('"${task.title}" 을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleCompletion(WidgetRef ref) {
    final now = DateTime.now();
    final isCompleted = task.status == TaskStatus.completed;
    final updated = task.copyWith(
      status: isCompleted ? TaskStatus.pending : TaskStatus.completed,
      completedAt: isCompleted ? null : now,
      updatedAt: now,
    );
    ref.read(taskRepositoryProvider).updateTask(updated);
  }
}
