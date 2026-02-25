import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/core/l10n_extension.dart';
import 'package:todo_app/domain/enums/enums.dart';
import 'package:todo_app/presentation/providers/auth_provider.dart';
import 'package:todo_app/presentation/providers/task_providers.dart';
import 'package:todo_app/presentation/providers/filter_providers.dart';
import 'package:todo_app/presentation/providers/category_providers.dart';
import 'package:todo_app/presentation/providers/repository_providers.dart';
import 'package:todo_app/presentation/shared_widgets/task_list_tile.dart';
import 'package:todo_app/presentation/shared_widgets/empty_state.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _loginDialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLoginDialogIfNeeded();
    });
  }

  void _showLoginDialogIfNeeded() {
    if (_loginDialogShown) return;
    final isAuth = ref.read(isAuthenticatedProvider);
    if (!isAuth) {
      _loginDialogShown = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const _LoginPromptDialog(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskListAsync = ref.watch(taskListProvider);
    final filter = ref.watch(taskFilterProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final l10n = context.l10n;

    // Build a map of categoryId -> CategoryEntity for quick lookup
    final categoryMap = categoriesAsync.whenData((categories) {
      return {for (final c in categories) c.id: c};
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Offline banner
          if (!isAuthenticated)
            MaterialBanner(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Icon(
                Icons.cloud_off,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              content: Text(
                l10n.loginPrompt,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pushNamed('login'),
                  child: Text(l10n.login),
                ),
              ],
            ),
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 8,
              runSpacing: 4,
              children: [
                _FilterChip(
                  label: l10n.filterAll,
                  selected: filter.status == null,
                  onSelected: (_) {
                    ref.read(taskFilterProvider.notifier).setStatus(null);
                  },
                ),
                _FilterChip(
                  label: l10n.filterInProgress,
                  selected: filter.status == TaskStatus.pending,
                  onSelected: (_) {
                    ref
                        .read(taskFilterProvider.notifier)
                        .setStatus(TaskStatus.pending);
                  },
                ),
                _FilterChip(
                  label: l10n.filterCompleted,
                  selected: filter.status == TaskStatus.completed,
                  onSelected: (_) {
                    ref
                        .read(taskFilterProvider.notifier)
                        .setStatus(TaskStatus.completed);
                  },
                ),
                const SizedBox(width: 4),
                _SortChip(
                  sortBy: filter.sortBy,
                  onSelected: (sortBy) {
                    ref.read(taskFilterProvider.notifier).setSortBy(sortBy);
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
                  if (filter.status == TaskStatus.completed) {
                    return EmptyState(
                      icon: Icons.check_circle_outline,
                      message: l10n.emptyCompleted,
                    );
                  }
                  if (filter.status == TaskStatus.pending) {
                    return EmptyState(
                      icon: Icons.hourglass_empty,
                      message: l10n.emptyInProgress,
                      actionLabel: l10n.emptyTaskAction,
                      onAction: () => context.pushNamed('taskEditor'),
                    );
                  }
                  return EmptyState(
                    icon: Icons.check_circle_outline,
                    message: l10n.emptyTaskMessage,
                    actionLabel: l10n.emptyTaskAction,
                    onAction: () => context.pushNamed('taskEditor'),
                  );
                }
                return ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: tasks.length,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    final reordered = List.of(tasks);
                    final item = reordered.removeAt(oldIndex);
                    reordered.insert(newIndex, item);
                    final sortOrders = <String, int>{};
                    for (var i = 0; i < reordered.length; i++) {
                      sortOrders[reordered[i].id] = i;
                    }
                    ref.read(taskRepositoryProvider).reorderTasks(sortOrders);
                  },
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final category = categoryMap.whenData(
                      (map) =>
                          task.categoryId != null ? map[task.categoryId] : null,
                    );
                    return TaskListTile(
                      key: ValueKey(task.id),
                      task: task,
                      category: category.valueOrNull,
                      index: index,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.errorOccurred(error.toString())),
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

class _SortChip extends ConsumerWidget {
  final TaskSortBy sortBy;
  final ValueChanged<TaskSortBy> onSelected;

  const _SortChip({
    required this.sortBy,
    required this.onSelected,
  });

  String _sortLabel(TaskSortBy sortBy, BuildContext context) {
    final l10n = context.l10n;
    switch (sortBy) {
      case TaskSortBy.dueDate:
        return l10n.dueDate;
      case TaskSortBy.priority:
        return l10n.priority;
      case TaskSortBy.createdAt:
        return l10n.createdAt;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<TaskSortBy>(
      tooltip: '정렬기준 표시',
      onSelected: onSelected,
      itemBuilder: (context) => TaskSortBy.values.map((value) {
        return PopupMenuItem(
          value: value,
          child: Row(
            children: [
              Text(_sortLabel(value, context)),
              if (value == sortBy) ...[
                const Spacer(),
                const Icon(Icons.check, size: 18),
              ],
            ],
          ),
        );
      }).toList(),
      child: InputChip(
        avatar: const Icon(Icons.sort, size: 16),
        label: Text(_sortLabel(sortBy, context)),
        onPressed: () {},
      ),
    );
  }
}

class _LoginPromptDialog extends ConsumerStatefulWidget {
  const _LoginPromptDialog();

  @override
  ConsumerState<_LoginPromptDialog> createState() =>
      _LoginPromptDialogState();
}

class _LoginPromptDialogState extends ConsumerState<_LoginPromptDialog> {
  bool _isGoogleLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithGoogle();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.googleLoginFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Icon(
              Icons.check_circle_outline,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Finito',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.loginPrompt,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                icon: _isGoogleLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'G',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                label: Text(l10n.signInWithGoogle),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.pushNamed('login'),
                child: Text(l10n.login),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.or,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.continueWithoutAccount),
            ),
          ],
        ),
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
