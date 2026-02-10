import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:todo_app/domain/entities/entities.dart';
import 'package:todo_app/domain/enums/enums.dart';
import 'package:todo_app/presentation/providers/repository_providers.dart';
import 'package:todo_app/presentation/providers/task_providers.dart';
import 'package:todo_app/presentation/providers/category_providers.dart';
import 'package:todo_app/presentation/providers/tag_providers.dart';
import 'package:todo_app/presentation/shared_widgets/priority_indicator.dart';
import 'package:todo_app/core/extensions.dart';

class TaskEditorScreen extends ConsumerStatefulWidget {
  final String? taskId;
  const TaskEditorScreen({super.key, this.taskId});

  @override
  ConsumerState<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends ConsumerState<TaskEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Priority _priority = Priority.medium;
  String? _categoryId;
  List<String> _selectedTagIds = [];
  DateTime? _dueDate;
  DateTime? _reminderTime;

  bool _isLoading = false;
  bool _initialized = false;

  bool get _isEditing => widget.taskId != null;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initFromTask(TaskEntity task) {
    if (_initialized) return;
    _initialized = true;
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _priority = task.priority;
    _categoryId = task.categoryId;
    _selectedTagIds = List.from(task.tagIds);
    _dueDate = task.dueDate;
    _reminderTime = task.reminderTime;
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final tagsAsync = ref.watch(tagListProvider);

    // If editing, load existing task
    if (_isEditing) {
      final taskAsync = ref.watch(taskDetailProvider(widget.taskId!));
      taskAsync.whenData((task) {
        if (task != null) _initFromTask(task);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '할 일 수정' : '새 할 일'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTask,
            child: const Text('저장'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: '제목',
                      hintText: '할 일을 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '제목을 입력해주세요';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '설명',
                      hintText: '설명을 입력하세요 (선택)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Priority dropdown
                  DropdownButtonFormField<Priority>(
                    initialValue: _priority,
                    decoration: const InputDecoration(
                      labelText: '우선순위',
                      border: OutlineInputBorder(),
                    ),
                    items: Priority.values.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: PriorityIndicator.colorFor(p),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(PriorityIndicator.labelFor(p)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _priority = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category dropdown
                  categoriesAsync.when(
                    data: (categories) {
                      return DropdownButtonFormField<String?>(
                        initialValue: _categoryId,
                        decoration: const InputDecoration(
                          labelText: '카테고리',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('없음'),
                          ),
                          ...categories.map((c) {
                            return DropdownMenuItem(
                              value: c.id,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Color(c.colorValue),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(c.name),
                                ],
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _categoryId = value);
                        },
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('카테고리 로딩 실패: $e'),
                  ),
                  const SizedBox(height: 16),

                  // Due date picker
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      _dueDate != null
                          ? '마감일: ${_dueDate!.toFormattedDate()}'
                          : '마감일 설정',
                    ),
                    trailing: _dueDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _dueDate = null),
                          )
                        : null,
                    onTap: _pickDueDate,
                  ),
                  const Divider(),

                  // Reminder time picker
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.notifications_active),
                    title: Text(
                      _reminderTime != null
                          ? '리마인더: ${_reminderTime!.toFormattedDateTime()}'
                          : '리마인더 설정',
                    ),
                    trailing: _reminderTime != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                setState(() => _reminderTime = null),
                          )
                        : null,
                    onTap: _pickReminderTime,
                  ),
                  const Divider(),

                  // Tag multi-select
                  const SizedBox(height: 8),
                  Text('태그', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  tagsAsync.when(
                    data: (tags) {
                      if (tags.isEmpty) {
                        return Text(
                          '태그가 없습니다',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                        );
                      }
                      return Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: tags.map((tag) {
                          final isSelected = _selectedTagIds.contains(tag.id);
                          return FilterChip(
                            label: Text(tag.name),
                            selected: isSelected,
                            selectedColor: Color(
                              tag.colorValue,
                            ).withValues(alpha: 0.3),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedTagIds.add(tag.id);
                                } else {
                                  _selectedTagIds.remove(tag.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('태그 로딩 실패: $e'),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickReminderTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _reminderTime ?? now,
      firstDate: now,
      lastDate: DateTime(2100),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _reminderTime != null
          ? TimeOfDay.fromDateTime(_reminderTime!)
          : TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    setState(() {
      _reminderTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(taskRepositoryProvider);
      final now = DateTime.now();

      if (_isEditing) {
        // Update existing task
        final existingTask = await ref.read(
          taskDetailProvider(widget.taskId!).future,
        );
        if (existingTask == null) return;

        final updated = existingTask.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _priority,
          categoryId: _categoryId,
          tagIds: _selectedTagIds,
          dueDate: _dueDate,
          reminderTime: _reminderTime,
          updatedAt: now,
        );
        await repo.updateTask(updated);
        await repo.setTagsForTask(updated.id, _selectedTagIds);
      } else {
        // Create new task
        final id = const Uuid().v4();
        final task = TaskEntity(
          id: id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _priority,
          categoryId: _categoryId,
          tagIds: _selectedTagIds,
          dueDate: _dueDate,
          reminderTime: _reminderTime,
          createdAt: now,
          updatedAt: now,
        );
        await repo.createTask(task);
        await repo.setTagsForTask(id, _selectedTagIds);
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
