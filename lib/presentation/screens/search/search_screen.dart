import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/core/extensions.dart';
import 'package:todo_app/domain/entities/entities.dart';
import 'package:todo_app/domain/enums/enums.dart';
import 'package:todo_app/presentation/providers/filter_providers.dart';
import 'package:todo_app/presentation/providers/task_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final trimmed = query.trim();
      ref
          .read(taskFilterProvider.notifier)
          .setSearchQuery(trimmed.isEmpty ? null : trimmed);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '할 일 검색...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref
                          .read(taskFilterProvider.notifier)
                          .setSearchQuery(null);
                      setState(() {});
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {}); // Update clear button visibility
            _onSearchChanged(value);
          },
        ),
      ),
      body: _buildBody(tasksAsync),
    );
  }

  Widget _buildBody(AsyncValue<List<TaskEntity>> tasksAsync) {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '검색어를 입력하세요',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return tasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  '검색 결과가 없습니다',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _SearchResultTile(task: task);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('오류가 발생했습니다: $error')),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final TaskEntity task;

  const _SearchResultTile({required this.task});

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        isCompleted ? Icons.check_circle : Icons.circle_outlined,
        color: isCompleted ? Colors.green : _priorityColor(task.priority),
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: isCompleted ? TextDecoration.lineThrough : null,
          color: isCompleted
              ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
              : null,
        ),
      ),
      subtitle: task.dueDate != null
          ? Text(
              task.dueDate!.toFormattedDate(),
              style: TextStyle(
                color: task.dueDate!.isOverdue && !isCompleted
                    ? Colors.red
                    : null,
                fontSize: 12,
              ),
            )
          : null,
      onTap: () {
        context.pushNamed('taskDetail', pathParameters: {'id': task.id});
      },
    );
  }

  Color _priorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.blue;
    }
  }
}
