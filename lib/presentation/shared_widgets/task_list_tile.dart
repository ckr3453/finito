import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/core/extensions.dart';
import 'package:todo_app/core/l10n_extension.dart';
import 'package:todo_app/domain/entities/entities.dart';
import 'package:todo_app/domain/enums/enums.dart';
import 'package:todo_app/presentation/providers/repository_providers.dart';
import 'package:todo_app/presentation/shared_widgets/priority_indicator.dart';

class TaskListTile extends ConsumerWidget {
  final TaskEntity task;
  final CategoryEntity? category;
  final int index;

  const TaskListTile({
    super.key,
    required this.task,
    this.category,
    required this.index,
  });

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
                // Drag handle
                ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.drag_indicator,
                      size: 20,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                // Checkbox
                Checkbox(
                  value: isCompleted,
                  onChanged: (_) => _toggleCompletion(context, ref),
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
                        // Bottom row: due date + reminder + category
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // Due date
                            if (task.dueDate != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: isOverdue
                                        ? Colors.red
                                        : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    task.dueDate!.toFormattedDateTime(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isOverdue
                                          ? Colors.red
                                          : theme.colorScheme.onSurface
                                                .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            // Reminder
                            if (task.reminderTime != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.notifications_active,
                                    size: 14,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    task.reminderTime!.toFormattedDateTime(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            // Category chip
                            if (category != null)
                              Chip(
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    final l10n = context.l10n;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTask),
        content: Text(l10n.deleteTaskConfirm(task.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleCompletion(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final isCompleted = task.status == TaskStatus.completed;
    final l10n = context.l10n;
    final updated = task.copyWith(
      status: isCompleted ? TaskStatus.pending : TaskStatus.completed,
      completedAt: isCompleted ? null : now,
      updatedAt: now,
    );
    ref.read(taskRepositoryProvider).updateTask(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCompleted ? l10n.markAsIncomplete : l10n.markAsComplete,
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
