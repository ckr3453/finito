import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:todo_app/core/l10n_extension.dart';
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
    final l10n = context.l10n;

    // If editing, load existing task
    if (_isEditing) {
      final taskAsync = ref.watch(taskDetailProvider(widget.taskId!));
      taskAsync.whenData((task) {
        if (task != null) _initFromTask(task);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editTask : l10n.newTask),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTask,
            child: Text(l10n.save),
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
                    decoration: InputDecoration(
                      labelText: l10n.title,
                      hintText: l10n.titleHint,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.titleRequired;
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.description,
                      hintText: l10n.descriptionHint,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Priority dropdown
                  DropdownButtonFormField<Priority>(
                    initialValue: _priority,
                    decoration: InputDecoration(
                      labelText: l10n.priority,
                      border: const OutlineInputBorder(),
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
                            Text(PriorityIndicator.labelFor(p, l10n)),
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
                        decoration: InputDecoration(
                          labelText: l10n.category,
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(value: null, child: Text(l10n.none)),
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
                    error: (e, _) =>
                        Text(l10n.categoryLoadFailed(e.toString())),
                  ),
                  const SizedBox(height: 16),

                  // Due date picker
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      _dueDate != null
                          ? l10n.dueDateLabel(_dueDate!.toFormattedDateTime())
                          : l10n.setDueDate,
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
                          ? l10n.reminderLabel(
                              _reminderTime!.toFormattedDateTime(),
                            )
                          : l10n.setReminder,
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
                  Text(
                    l10n.tags,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  tagsAsync.when(
                    data: (tags) {
                      if (tags.isEmpty) {
                        return Text(
                          l10n.noTags,
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
                    error: (e, _) => Text(l10n.tagLoadFailed(e.toString())),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _dueDate != null
          ? TimeOfDay.fromDateTime(_dueDate!)
          : TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    setState(() {
      _dueDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _pickReminderTime() async {
    if (_dueDate != null) {
      await _pickReminderFromPresets();
    } else {
      await _pickReminderManually();
    }
  }

  Future<void> _pickReminderFromPresets() async {
    final l10n = context.l10n;
    final due = _dueDate!;
    final presets = <(String, Duration)>[
      ('15${l10n.minutesBefore}', const Duration(minutes: 15)),
      ('30${l10n.minutesBefore}', const Duration(minutes: 30)),
      ('1${l10n.hourBefore}', const Duration(hours: 1)),
      ('1${l10n.dayBefore}', const Duration(days: 1)),
    ];

    final selected = await showModalBottomSheet<Duration?>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...presets.map(
              (preset) => ListTile(
                title: Text(preset.$1),
                subtitle: Text(due.subtract(preset.$2).toFormattedDateTime()),
                onTap: () => Navigator.pop(context, preset.$2),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_calendar),
              title: Text(l10n.customTime),
              onTap: () => Navigator.pop(context, Duration.zero),
            ),
          ],
        ),
      ),
    );

    if (selected == null || !mounted) return;

    if (selected == Duration.zero) {
      await _pickReminderManually();
    } else {
      setState(() {
        _reminderTime = due.subtract(selected);
      });
    }
  }

  Future<void> _pickReminderManually() async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.saveFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
