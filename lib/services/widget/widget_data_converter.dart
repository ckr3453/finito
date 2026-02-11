import 'dart:convert';

import 'package:todo_app/domain/entities/task_entity.dart';
import 'package:todo_app/domain/enums/enums.dart';

class WidgetDataConverter {
  static const int _maxTasks = 5;

  static const _priorityOrder = {
    Priority.high: 0,
    Priority.medium: 1,
    Priority.low: 2,
  };

  Map<String, dynamic> convert(List<TaskEntity> tasks, DateTime now) {
    final pending = tasks
        .where((t) => t.status == TaskStatus.pending && t.deletedAt == null)
        .toList();

    final todayCount = pending.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == now.year &&
          t.dueDate!.month == now.month &&
          t.dueDate!.day == now.day;
    }).length;

    pending.sort((a, b) {
      final pa = _priorityOrder[a.priority] ?? 1;
      final pb = _priorityOrder[b.priority] ?? 1;
      return pa.compareTo(pb);
    });

    final top = pending.take(_maxTasks).toList();

    return {
      'todayCount': todayCount,
      'tasks': top.map(_taskToMap).toList(),
      'lastUpdated': now.toIso8601String(),
    };
  }

  String convertToJsonString(List<TaskEntity> tasks, DateTime now) {
    return jsonEncode(convert(tasks, now));
  }

  Map<String, dynamic> _taskToMap(TaskEntity task) {
    return {
      'id': task.id,
      'title': task.title,
      'priority': task.priority.name,
      'dueDate': task.dueDate != null
          ? '${task.dueDate!.year}-${task.dueDate!.month.toString().padLeft(2, '0')}-${task.dueDate!.day.toString().padLeft(2, '0')}'
          : null,
      'completed': task.status == TaskStatus.completed,
    };
  }
}
