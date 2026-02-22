import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/domain/entities/task_entity.dart';
import 'package:todo_app/domain/enums/enums.dart';
import 'package:todo_app/services/widget/widget_data_converter.dart';

void main() {
  late WidgetDataConverter converter;

  setUp(() {
    converter = WidgetDataConverter();
  });

  TaskEntity makeTask({
    required String id,
    required String title,
    TaskStatus status = TaskStatus.pending,
    Priority priority = Priority.medium,
    DateTime? dueDate,
  }) {
    final now = DateTime(2026, 2, 10);
    return TaskEntity(
      id: id,
      title: title,
      status: status,
      priority: priority,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('convert', () {
    test('빈 리스트 → todayCount 0, tasks 빈 리스트', () {
      final result = converter.convert([], DateTime(2026, 2, 10));

      expect(result['todayCount'], 0);
      expect(result['tasks'], isEmpty);
      expect(result['lastUpdated'], isNotNull);
    });

    test('completed 태스크는 제외된다', () {
      final tasks = [
        makeTask(id: '1', title: 'Pending', status: TaskStatus.pending),
        makeTask(id: '2', title: 'Done', status: TaskStatus.completed),
      ];

      final result = converter.convert(tasks, DateTime(2026, 2, 10));
      final taskList = result['tasks'] as List;

      expect(taskList.length, 1);
      expect(taskList[0]['title'], 'Pending');
    });

    test('archived 태스크는 제외된다', () {
      final tasks = [
        makeTask(id: '1', title: 'Pending'),
        makeTask(id: '2', title: 'Archived', status: TaskStatus.archived),
      ];

      final result = converter.convert(tasks, DateTime(2026, 2, 10));
      final taskList = result['tasks'] as List;

      expect(taskList.length, 1);
    });

    test('오늘 마감 pending 태스크만 todayCount에 집계된다', () {
      final today = DateTime(2026, 2, 10);
      final tasks = [
        makeTask(id: '1', title: 'Today 1', dueDate: today),
        makeTask(id: '2', title: 'Today 2', dueDate: today),
        makeTask(id: '3', title: 'Tomorrow', dueDate: DateTime(2026, 2, 11)),
        makeTask(id: '4', title: 'No due'),
      ];

      final result = converter.convert(tasks, today);

      expect(result['todayCount'], 2);
    });

    test('우선순위 순으로 정렬된다 (high > medium > low)', () {
      final tasks = [
        makeTask(id: '1', title: 'Low', priority: Priority.low),
        makeTask(id: '2', title: 'High', priority: Priority.high),
        makeTask(id: '3', title: 'Medium', priority: Priority.medium),
      ];

      final result = converter.convert(tasks, DateTime(2026, 2, 10));
      final taskList = result['tasks'] as List;

      expect(taskList[0]['title'], 'High');
      expect(taskList[1]['title'], 'Medium');
      expect(taskList[2]['title'], 'Low');
    });

    test('최대 5개까지만 반환된다', () {
      final tasks = List.generate(
        8,
        (i) => makeTask(id: '$i', title: 'Task $i'),
      );

      final result = converter.convert(tasks, DateTime(2026, 2, 10));
      final taskList = result['tasks'] as List;

      expect(taskList.length, 5);
    });

    test('각 태스크에 id, title, priority, dueDate, completed 필드가 포함된다', () {
      final tasks = [
        makeTask(
          id: 'uuid-1',
          title: 'Test',
          priority: Priority.high,
          dueDate: DateTime(2026, 2, 10),
        ),
      ];

      final result = converter.convert(tasks, DateTime(2026, 2, 10));
      final task = (result['tasks'] as List).first;

      expect(task['id'], 'uuid-1');
      expect(task['title'], 'Test');
      expect(task['priority'], 'high');
      expect(task['dueDate'], '2026-02-10');
      expect(task['completed'], false);
    });

    test('lastUpdated는 ISO 8601 형식이다', () {
      final result = converter.convert([], DateTime(2026, 2, 10));
      final lastUpdated = result['lastUpdated'] as String;

      expect(() => DateTime.parse(lastUpdated), returnsNormally);
    });

    test('deletedAt이 설정된 태스크는 제외된다', () {
      final now = DateTime(2026, 2, 10);
      final tasks = [
        TaskEntity(id: '1', title: 'Active', createdAt: now, updatedAt: now),
        TaskEntity(
          id: '2',
          title: 'Deleted',
          createdAt: now,
          updatedAt: now,
          deletedAt: now,
        ),
      ];

      final result = converter.convert(tasks, now);
      final taskList = result['tasks'] as List;

      expect(taskList.length, 1);
      expect(taskList[0]['title'], 'Active');
    });
  });

  group('convertToJsonString', () {
    test('JSON 문자열로 직렬화된다', () {
      final result = converter.convertToJsonString([], DateTime(2026, 2, 10));

      expect(result, contains('"todayCount":0'));
      expect(result, contains('"tasks":[]'));
    });
  });
}
