import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/data/datasources/remote/firestore_paths.dart';
import 'package:todo_app/data/datasources/remote/firestore_task_datasource.dart';
import 'package:todo_app/data/models/task_firestore_dto.dart';

const testUserId = 'user-123';

final _now = DateTime(2025, 6, 15, 10, 30, 0);

Map<String, dynamic> sampleTaskData({String id = 'task-1'}) => {
  'id': id,
  'title': 'Test Task $id',
  'description': 'Description',
  'status': 'pending',
  'priority': 'medium',
  'categoryId': null,
  'tagIds': <dynamic>[],
  'dueDate': null,
  'completedAt': null,
  'deletedAt': null,
  'sortOrder': 0,
  'createdAt': Timestamp.fromDate(_now),
  'updatedAt': Timestamp.fromDate(_now),
};

TaskFirestoreDto sampleDto({String id = 'task-1'}) =>
    TaskFirestoreDto.fromFirestore(sampleTaskData(id: id));

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreTaskDataSourceImpl dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = FirestoreTaskDataSourceImpl(fakeFirestore);
  });

  group('FirestorePaths', () {
    test('tasksCol returns correct path', () {
      expect(FirestorePaths.tasksCol('user-1'), 'users/user-1/tasks');
    });

    test('taskDoc returns correct path', () {
      expect(
        FirestorePaths.taskDoc('user-1', 'task-1'),
        'users/user-1/tasks/task-1',
      );
    });

    test('paths handle special characters in userId', () {
      expect(
        FirestorePaths.tasksCol('user@email.com'),
        'users/user@email.com/tasks',
      );
    });
  });

  group('setTask', () {
    test('writes data to the correct document path', () async {
      final dto = sampleDto();

      await dataSource.setTask(testUserId, dto);

      final doc = await fakeFirestore
          .doc(FirestorePaths.taskDoc(testUserId, dto.id))
          .get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['id'], dto.id);
      expect(doc.data()!['title'], dto.title);
    });

    test('stored data does not contain isSynced field', () async {
      final dto = sampleDto();

      await dataSource.setTask(testUserId, dto);

      final doc = await fakeFirestore
          .doc(FirestorePaths.taskDoc(testUserId, dto.id))
          .get();
      expect(doc.data()!.containsKey('isSynced'), isFalse);
    });

    test('overwrites existing document on second set', () async {
      final dto1 = sampleDto();
      await dataSource.setTask(testUserId, dto1);

      final updated = TaskFirestoreDto.fromFirestore({
        ...sampleTaskData(),
        'title': 'Updated Title',
      });
      await dataSource.setTask(testUserId, updated);

      final doc = await fakeFirestore
          .doc(FirestorePaths.taskDoc(testUserId, dto1.id))
          .get();
      expect(doc.data()!['title'], 'Updated Title');
    });
  });

  group('batchSetTasks', () {
    test('writes all DTOs in a single batch', () async {
      final dto1 = sampleDto(id: 'task-1');
      final dto2 = sampleDto(id: 'task-2');

      await dataSource.batchSetTasks(testUserId, [dto1, dto2]);

      final snapshot = await fakeFirestore
          .collection(FirestorePaths.tasksCol(testUserId))
          .get();
      expect(snapshot.docs, hasLength(2));

      final ids = snapshot.docs.map((d) => d.data()['id']).toSet();
      expect(ids, {'task-1', 'task-2'});
    });

    test('handles empty list without error', () async {
      await dataSource.batchSetTasks(testUserId, []);

      final snapshot = await fakeFirestore
          .collection(FirestorePaths.tasksCol(testUserId))
          .get();
      expect(snapshot.docs, isEmpty);
    });
  });

  group('fetchAllTasks', () {
    test('returns list of DTOs from stored documents', () async {
      // Seed data directly into fake Firestore
      final col =
          fakeFirestore.collection(FirestorePaths.tasksCol(testUserId));
      await col.doc('task-1').set(sampleTaskData(id: 'task-1'));
      await col.doc('task-2').set(sampleTaskData(id: 'task-2'));

      final result = await dataSource.fetchAllTasks(testUserId);

      expect(result, hasLength(2));
      final ids = result.map((d) => d.id).toSet();
      expect(ids, {'task-1', 'task-2'});
    });

    test('returns empty list when no documents exist', () async {
      final result = await dataSource.fetchAllTasks(testUserId);

      expect(result, isEmpty);
    });
  });

  group('watchTasks', () {
    test('emits current documents', () async {
      // Seed one task
      await fakeFirestore
          .collection(FirestorePaths.tasksCol(testUserId))
          .doc('task-1')
          .set(sampleTaskData(id: 'task-1'));

      final result = await dataSource.watchTasks(testUserId).first;

      expect(result, hasLength(1));
      expect(result[0].id, 'task-1');
    });

    test('emits empty list when no documents exist', () async {
      final result = await dataSource.watchTasks(testUserId).first;

      expect(result, isEmpty);
    });

    test('emits updated list when documents are added', () async {
      final stream = dataSource.watchTasks(testUserId);

      // Collect first two emissions
      final future = stream.take(2).toList();

      // Add a document to trigger second emission
      await fakeFirestore
          .collection(FirestorePaths.tasksCol(testUserId))
          .doc('task-1')
          .set(sampleTaskData(id: 'task-1'));

      final results = await future;

      expect(results[0], isEmpty);
      expect(results[1], hasLength(1));
      expect(results[1][0].id, 'task-1');
    });
  });
}
