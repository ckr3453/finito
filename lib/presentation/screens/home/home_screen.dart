import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/domain/enums/enums.dart';
import 'package:todo_app/presentation/providers/task_providers.dart';
import 'package:todo_app/presentation/providers/filter_providers.dart';
import 'package:todo_app/presentation/providers/category_providers.dart';
import 'package:todo_app/presentation/shared_widgets/task_list_tile.dart';
import 'package:todo_app/presentation/shared_widgets/empty_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskListAsync = ref.watch(taskListProvider);
    final filter = ref.watch(taskFilterProvider);
    final categoriesAsync = ref.watch(categoryListProvider);

    // Build a map of categoryId -> CategoryEntity for quick lookup
    final categoryMap = categoriesAsync.whenData((categories) {
      return {for (final c in categories) c.id: c};
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('TODO'),
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: '전체',
                  selected: filter.status == null,
                  onSelected: (_) {
                    ref.read(taskFilterProvider.notifier).setStatus(null);
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '진행중',
                  selected: filter.status == TaskStatus.pending,
                  onSelected: (_) {
                    ref.read(taskFilterProvider.notifier).setStatus(TaskStatus.pending);
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '완료',
                  selected: filter.status == TaskStatus.completed,
                  onSelected: (_) {
                    ref.read(taskFilterProvider.notifier).setStatus(TaskStatus.completed);
                  },
                ),
              ],
            ),
          ),
          // Task list
          Expanded(
            child: taskListAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return EmptyState(
                    icon: Icons.check_circle_outline,
                    message: '할 일을 추가해보세요!',
                    actionLabel: '새 할 일 추가',
                    onAction: () => context.pushNamed('taskEditor'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final category = categoryMap.whenData(
                      (map) => task.categoryId != null ? map[task.categoryId] : null,
                    );
                    return TaskListTile(
                      task: task,
                      category: category.valueOrNull,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 8),
                    Text('오류가 발생했습니다: $error'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed('taskEditor'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    );
  }
}
