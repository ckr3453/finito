import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/data/models/task_firestore_dto.dart';
import 'package:todo_app/domain/entities/task_entity.dart';
import 'package:todo_app/domain/enums/enums.dart';

void main() {
  final now = DateTime(2025, 6, 15, 10, 30, 0);
  final dueDate = DateTime(2025, 7, 1, 9, 0, 0);
  final completedAt = DateTime(2025, 6, 20, 14, 0, 0);
  final deletedAt = DateTime(2025, 6, 25, 8, 0, 0);

  Map<String, dynamic> fullFirestoreData() => {
    'id': 'task-1',
    'title': 'Test Task',
    'description': 'A test description',
    'status': 'completed',
    'priority': 'high',
    'categoryId': 'cat-1',
    'tagIds': ['tag-1', 'tag-2'],
    'dueDate': Timestamp.fromDate(dueDate),
    'completedAt': Timestamp.fromDate(completedAt),
    'deletedAt': Timestamp.fromDate(deletedAt),
    'sortOrder': 5,
    'createdAt': Timestamp.fromDate(now),
    'updatedAt': Timestamp.fromDate(now),
  };

  TaskEntity fullEntity() => TaskEntity(
    id: 'task-1',
    title: 'Test Task',
    description: 'A test description',
    status: TaskStatus.completed,
    priority: Priority.high,
    categoryId: 'cat-1',
    tagIds: ['tag-1', 'tag-2'],
    dueDate: dueDate,
    completedAt: completedAt,
    deletedAt: deletedAt,
    sortOrder: 5,
    createdAt: now,
    updatedAt: now,
    isSynced: true,
  );

  group('fromFirestore', () {
    test('maps all fields correctly from Firestore data', () {
      final data = fullFirestoreData();
      final dto = TaskFirestoreDto.fromFirestore(data);

      expect(dto.id, 'task-1');
      expect(dto.title, 'Test Task');
      expect(dto.description, 'A test description');
      expect(dto.status, 'completed');
      expect(dto.priority, 'high');
      expect(dto.categoryId, 'cat-1');
      expect(dto.tagIds, ['tag-1', 'tag-2']);
      expect(dto.dueDate, dueDate);
      expect(dto.completedAt, completedAt);
      expect(dto.deletedAt, deletedAt);
      expect(dto.sortOrder, 5);
      expect(dto.createdAt, now);
      expect(dto.updatedAt, now);
    });

    test('handles nullable fields as null', () {
      final data = fullFirestoreData()
        ..remove('categoryId')
        ..remove('dueDate')
        ..remove('completedAt')
        ..remove('deletedAt');

      final dto = TaskFirestoreDto.fromFirestore(data);

      expect(dto.categoryId, isNull);
      expect(dto.dueDate, isNull);
      expect(dto.completedAt, isNull);
      expect(dto.deletedAt, isNull);
    });

    test('casts tagIds from List<dynamic> to List<String>', () {
      final data = fullFirestoreData();
      // Firestore returns List<dynamic> even when contents are strings
      data['tagIds'] = <dynamic>['tag-a', 'tag-b'];

      final dto = TaskFirestoreDto.fromFirestore(data);

      expect(dto.tagIds, isA<List<String>>());
      expect(dto.tagIds, ['tag-a', 'tag-b']);
    });

    test('handles empty tagIds', () {
      final data = fullFirestoreData();
      data['tagIds'] = <dynamic>[];

      final dto = TaskFirestoreDto.fromFirestore(data);

      expect(dto.tagIds, isEmpty);
    });

    test('handles missing tagIds as empty list', () {
      final data = fullFirestoreData()..remove('tagIds');

      final dto = TaskFirestoreDto.fromFirestore(data);

      expect(dto.tagIds, isEmpty);
    });
  });

  group('toFirestore', () {
    test('converts all fields to Firestore-compatible map', () {
      final dto = TaskFirestoreDto.fromFirestore(fullFirestoreData());
      final map = dto.toFirestore();

      expect(map['id'], 'task-1');
      expect(map['title'], 'Test Task');
      expect(map['description'], 'A test description');
      expect(map['status'], 'completed');
      expect(map['priority'], 'high');
      expect(map['categoryId'], 'cat-1');
      expect(map['tagIds'], ['tag-1', 'tag-2']);
      expect(map['sortOrder'], 5);

      // DateTime → Timestamp
      expect(map['dueDate'], isA<Timestamp>());
      expect((map['dueDate'] as Timestamp).toDate(), dueDate);
      expect(map['completedAt'], isA<Timestamp>());
      expect((map['completedAt'] as Timestamp).toDate(), completedAt);
      expect(map['deletedAt'], isA<Timestamp>());
      expect((map['deletedAt'] as Timestamp).toDate(), deletedAt);
      expect(map['createdAt'], isA<Timestamp>());
      expect((map['createdAt'] as Timestamp).toDate(), now);
      expect(map['updatedAt'], isA<Timestamp>());
      expect((map['updatedAt'] as Timestamp).toDate(), now);
    });

    test('does not include isSynced field', () {
      final dto = TaskFirestoreDto.fromFirestore(fullFirestoreData());
      final map = dto.toFirestore();

      expect(map.containsKey('isSynced'), isFalse);
    });

    test('nullable DateTime fields are null in output', () {
      final data = fullFirestoreData()
        ..remove('dueDate')
        ..remove('completedAt')
        ..remove('deletedAt');
      final dto = TaskFirestoreDto.fromFirestore(data);
      final map = dto.toFirestore();

      expect(map['dueDate'], isNull);
      expect(map['completedAt'], isNull);
      expect(map['deletedAt'], isNull);
    });
  });

  group('fromEntity', () {
    test('converts TaskEntity to DTO with enum→string', () {
      final entity = fullEntity();
      final dto = TaskFirestoreDto.fromEntity(entity);

      expect(dto.id, entity.id);
      expect(dto.title, entity.title);
      expect(dto.description, entity.description);
      expect(dto.status, 'completed');
      expect(dto.priority, 'high');
      expect(dto.categoryId, entity.categoryId);
      expect(dto.tagIds, entity.tagIds);
      expect(dto.dueDate, entity.dueDate);
      expect(dto.completedAt, entity.completedAt);
      expect(dto.deletedAt, entity.deletedAt);
      expect(dto.sortOrder, entity.sortOrder);
      expect(dto.createdAt, entity.createdAt);
      expect(dto.updatedAt, entity.updatedAt);
    });

    test('converts all TaskStatus values', () {
      for (final status in TaskStatus.values) {
        final entity = fullEntity().copyWith(status: status);
        final dto = TaskFirestoreDto.fromEntity(entity);
        expect(dto.status, status.name);
      }
    });

    test('converts all Priority values', () {
      for (final priority in Priority.values) {
        final entity = fullEntity().copyWith(priority: priority);
        final dto = TaskFirestoreDto.fromEntity(entity);
        expect(dto.priority, priority.name);
      }
    });
  });

  group('toEntity', () {
    test('converts DTO to TaskEntity with string→enum', () {
      final dto = TaskFirestoreDto.fromFirestore(fullFirestoreData());
      final entity = dto.toEntity(isSynced: true);

      expect(entity.id, dto.id);
      expect(entity.title, dto.title);
      expect(entity.description, dto.description);
      expect(entity.status, TaskStatus.completed);
      expect(entity.priority, Priority.high);
      expect(entity.categoryId, dto.categoryId);
      expect(entity.tagIds, dto.tagIds);
      expect(entity.dueDate, dto.dueDate);
      expect(entity.completedAt, dto.completedAt);
      expect(entity.deletedAt, dto.deletedAt);
      expect(entity.sortOrder, dto.sortOrder);
      expect(entity.createdAt, dto.createdAt);
      expect(entity.updatedAt, dto.updatedAt);
      expect(entity.isSynced, isTrue);
    });

    test('respects isSynced parameter false', () {
      final dto = TaskFirestoreDto.fromFirestore(fullFirestoreData());
      final entity = dto.toEntity(isSynced: false);

      expect(entity.isSynced, isFalse);
    });

    test('maps all TaskStatus string values correctly', () {
      for (final status in TaskStatus.values) {
        final data = fullFirestoreData();
        data['status'] = status.name;
        final dto = TaskFirestoreDto.fromFirestore(data);
        final entity = dto.toEntity(isSynced: true);
        expect(entity.status, status);
      }
    });

    test('maps all Priority string values correctly', () {
      for (final priority in Priority.values) {
        final data = fullFirestoreData();
        data['priority'] = priority.name;
        final dto = TaskFirestoreDto.fromFirestore(data);
        final entity = dto.toEntity(isSynced: true);
        expect(entity.priority, priority);
      }
    });
  });

  group('round-trip', () {
    test('entity → DTO → entity preserves all data', () {
      final original = fullEntity();
      final dto = TaskFirestoreDto.fromEntity(original);
      final restored = dto.toEntity(isSynced: original.isSynced);

      expect(restored, original);
    });

    test('entity → DTO → map → DTO → entity preserves all data', () {
      final original = fullEntity();
      final dto1 = TaskFirestoreDto.fromEntity(original);
      final map = dto1.toFirestore();
      final dto2 = TaskFirestoreDto.fromFirestore(map);
      final restored = dto2.toEntity(isSynced: original.isSynced);

      expect(restored, original);
    });

    test('round-trip with nullable fields as null', () {
      final original = TaskEntity(
        id: 'task-2',
        title: 'Minimal',
        createdAt: now,
        updatedAt: now,
      );
      final dto = TaskFirestoreDto.fromEntity(original);
      final map = dto.toFirestore();
      final dto2 = TaskFirestoreDto.fromFirestore(map);
      final restored = dto2.toEntity(isSynced: original.isSynced);

      expect(restored, original);
    });
  });

  group('edge cases', () {
    test('toEntity throws on invalid status string', () {
      final data = fullFirestoreData();
      data['status'] = 'invalid_status';
      final dto = TaskFirestoreDto.fromFirestore(data);

      expect(() => dto.toEntity(isSynced: true), throwsA(isA<ArgumentError>()));
    });

    test('toEntity throws on invalid priority string', () {
      final data = fullFirestoreData();
      data['priority'] = 'invalid_priority';
      final dto = TaskFirestoreDto.fromFirestore(data);

      expect(() => dto.toEntity(isSynced: true), throwsA(isA<ArgumentError>()));
    });
  });
}
