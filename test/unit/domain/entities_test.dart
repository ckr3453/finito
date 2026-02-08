import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/domain/entities/entities.dart';
import 'package:todo_app/domain/enums/enums.dart';

void main() {
  final now = DateTime.now();

  group('TaskEntity', () {
    test('has correct default values', () {
      final task = TaskEntity(
        id: '1',
        title: 'Test',
        createdAt: now,
        updatedAt: now,
      );

      expect(task.description, '');
      expect(task.status, TaskStatus.pending);
      expect(task.priority, Priority.medium);
      expect(task.categoryId, isNull);
      expect(task.tagIds, isEmpty);
      expect(task.dueDate, isNull);
      expect(task.completedAt, isNull);
      expect(task.sortOrder, 0);
      expect(task.isSynced, isFalse);
    });

    test('copyWith creates modified copy', () {
      final task = TaskEntity(
        id: '1',
        title: 'Original',
        createdAt: now,
        updatedAt: now,
      );

      final modified = task.copyWith(
        title: 'Modified',
        status: TaskStatus.completed,
        priority: Priority.high,
      );

      expect(modified.id, '1');
      expect(modified.title, 'Modified');
      expect(modified.status, TaskStatus.completed);
      expect(modified.priority, Priority.high);
      // unchanged fields
      expect(modified.createdAt, now);
    });

    test('JSON round-trip preserves data', () {
      final task = TaskEntity(
        id: 'task-1',
        title: 'JSON Test',
        description: 'Testing JSON',
        status: TaskStatus.completed,
        priority: Priority.high,
        tagIds: ['tag-1', 'tag-2'],
        sortOrder: 5,
        createdAt: now,
        updatedAt: now,
        isSynced: true,
      );

      final json = task.toJson();
      final restored = TaskEntity.fromJson(json);

      expect(restored.id, task.id);
      expect(restored.title, task.title);
      expect(restored.description, task.description);
      expect(restored.status, task.status);
      expect(restored.priority, task.priority);
      expect(restored.tagIds, task.tagIds);
      expect(restored.sortOrder, task.sortOrder);
      expect(restored.isSynced, task.isSynced);
    });

    test('equality works for identical entities', () {
      final a = TaskEntity(
        id: '1',
        title: 'Same',
        createdAt: now,
        updatedAt: now,
      );
      final b = TaskEntity(
        id: '1',
        title: 'Same',
        createdAt: now,
        updatedAt: now,
      );

      expect(a, equals(b));
    });

    test('equality fails for different entities', () {
      final a = TaskEntity(id: '1', title: 'A', createdAt: now, updatedAt: now);
      final b = TaskEntity(id: '2', title: 'B', createdAt: now, updatedAt: now);

      expect(a, isNot(equals(b)));
    });
  });

  group('CategoryEntity', () {
    test('has correct default values', () {
      final cat = CategoryEntity(
        id: '1',
        name: 'Work',
        colorValue: 0xFF4CAF50,
        createdAt: now,
        updatedAt: now,
      );

      expect(cat.iconName, 'folder');
      expect(cat.sortOrder, 0);
    });

    test('copyWith creates modified copy', () {
      final cat = CategoryEntity(
        id: '1',
        name: 'Work',
        colorValue: 0xFF4CAF50,
        createdAt: now,
        updatedAt: now,
      );

      final modified = cat.copyWith(name: 'Personal', sortOrder: 3);

      expect(modified.id, '1');
      expect(modified.name, 'Personal');
      expect(modified.sortOrder, 3);
      expect(modified.colorValue, 0xFF4CAF50);
    });

    test('JSON round-trip preserves data', () {
      final cat = CategoryEntity(
        id: 'cat-1',
        name: 'Work',
        colorValue: 0xFF2196F3,
        iconName: 'work',
        sortOrder: 2,
        createdAt: now,
        updatedAt: now,
      );

      final json = cat.toJson();
      final restored = CategoryEntity.fromJson(json);

      expect(restored.id, cat.id);
      expect(restored.name, cat.name);
      expect(restored.colorValue, cat.colorValue);
      expect(restored.iconName, cat.iconName);
      expect(restored.sortOrder, cat.sortOrder);
    });
  });

  group('TagEntity', () {
    test('creates with required fields', () {
      final tag = TagEntity(
        id: 'tag-1',
        name: 'urgent',
        colorValue: 0xFFEF5350,
        createdAt: now,
      );

      expect(tag.id, 'tag-1');
      expect(tag.name, 'urgent');
      expect(tag.colorValue, 0xFFEF5350);
    });

    test('JSON round-trip preserves data', () {
      final tag = TagEntity(
        id: 'tag-1',
        name: 'urgent',
        colorValue: 0xFFEF5350,
        createdAt: now,
      );

      final json = tag.toJson();
      final restored = TagEntity.fromJson(json);

      expect(restored.id, tag.id);
      expect(restored.name, tag.name);
      expect(restored.colorValue, tag.colorValue);
    });

    test('equality works', () {
      final a = TagEntity(
        id: 'tag-1',
        name: 'urgent',
        colorValue: 0xFFEF5350,
        createdAt: now,
      );
      final b = TagEntity(
        id: 'tag-1',
        name: 'urgent',
        colorValue: 0xFFEF5350,
        createdAt: now,
      );

      expect(a, equals(b));
    });
  });
}
