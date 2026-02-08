import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/core/extensions.dart';
import 'package:todo_app/domain/entities/entities.dart';
import 'package:todo_app/domain/enums/enums.dart';
import 'package:todo_app/presentation/providers/task_providers.dart';
import 'package:todo_app/presentation/providers/repository_providers.dart';
import 'package:todo_app/presentation/providers/category_providers.dart';
import 'package:todo_app/presentation/shared_widgets/priority_indicator.dart';

class TaskDetailScreen extends ConsumerWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskDetailProvider(taskId));
    final tagsAsync = ref.watch(taskTagsProvider(taskId));
    final categoriesAsync = ref.watch(categoryListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('할 일 상세'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: '수정',
            onPressed: () {
              context.pushNamed(
                'taskEditor',
                queryParameters: {'taskId': taskId},
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: '삭제',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: taskAsync.when(
        data: (task) {
          if (task == null) {
            return const Center(child: Text('할 일을 찾을 수 없습니다.'));
          }

          final isCompleted = task.status == TaskStatus.completed;
          final isOverdue =
              task.dueDate != null && task.dueDate!.isOverdue && !isCompleted;

          // Find category name
          final category = categoriesAsync.whenData((categories) {
            if (task.categoryId == null) return null;
            try {
              return categories.firstWhere((c) => c.id == task.categoryId);
            } catch (_) {
              return null;
            }
          });

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Title and status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(status: task.status),
                ],
              ),
              const SizedBox(height: 24),

              // Priority
              _DetailRow(
                icon: Icons.flag,
                label: '우선순위',
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: PriorityIndicator.colorFor(task.priority),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(PriorityIndicator.labelFor(task.priority)),
                  ],
                ),
              ),
              const Divider(height: 24),

              // Description
              if (task.description.isNotEmpty) ...[
                _DetailRow(
                  icon: Icons.description,
                  label: '설명',
                  child: Text(task.description),
                ),
                const Divider(height: 24),
              ],

              // Category
              category.when(
                data: (cat) {
                  if (cat == null) return const SizedBox.shrink();
                  return Column(
                    children: [
                      _DetailRow(
                        icon: Icons.folder,
                        label: '카테고리',
                        child: Chip(
                          label: Text(cat.name),
                          backgroundColor:
                              Color(cat.colorValue).withValues(alpha: 0.2),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const Divider(height: 24),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
              ),

              // Tags
              tagsAsync.when(
                data: (tags) {
                  if (tags.isEmpty) return const SizedBox.shrink();
                  return Column(
                    children: [
                      _DetailRow(
                        icon: Icons.label,
                        label: '태그',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: tags.map((tag) {
                            return Chip(
                              label: Text(tag.name),
                              backgroundColor:
                                  Color(tag.colorValue).withValues(alpha: 0.2),
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                      ),
                      const Divider(height: 24),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
              ),

              // Due date
              if (task.dueDate != null) ...[
                _DetailRow(
                  icon: Icons.calendar_today,
                  label: '마감일',
                  child: Text(
                    task.dueDate!.toFormattedDate(),
                    style: TextStyle(
                      color: isOverdue ? Colors.red : null,
                      fontWeight: isOverdue ? FontWeight.bold : null,
                    ),
                  ),
                ),
                const Divider(height: 24),
              ],

              // Created / Updated info
              _DetailRow(
                icon: Icons.access_time,
                label: '생성일',
                child: Text(task.createdAt.toFormattedDateTime()),
              ),
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.update,
                label: '수정일',
                child: Text(task.updatedAt.toFormattedDateTime()),
              ),
              const SizedBox(height: 32),

              // Toggle complete button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _toggleCompletion(ref, task),
                  icon: Icon(isCompleted
                      ? Icons.undo
                      : Icons.check_circle),
                  label: Text(isCompleted ? '미완료로 변경' : '완료로 변경'),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        isCompleted ? Colors.grey : theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('오류가 발생했습니다: $error'),
        ),
      ),
    );
  }

  void _toggleCompletion(WidgetRef ref, TaskEntity task) {
    final now = DateTime.now();
    final isCompleted = task.status == TaskStatus.completed;
    final updated = task.copyWith(
      status: isCompleted ? TaskStatus.pending : TaskStatus.completed,
      completedAt: isCompleted ? null : now,
      updatedAt: now,
    );
    ref.read(taskRepositoryProvider).updateTask(updated);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('할 일 삭제'),
        content: const Text('이 할 일을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(taskRepositoryProvider).deleteTask(taskId);
      if (context.mounted) {
        context.pop();
      }
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final TaskStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TaskStatus.pending => ('진행중', Colors.blue),
      TaskStatus.completed => ('완료', Colors.green),
      TaskStatus.archived => ('보관', Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 4),
            child,
          ],
        ),
      ],
    );
  }
}
