import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/data/datasources/remote/firestore_paths.dart';
import 'package:todo_app/data/datasources/remote/firestore_task_datasource.dart';
import 'package:todo_app/data/models/task_firestore_dto.dart';

// --- Mocks ---
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

class MockWriteBatch extends Mock implements WriteBatch {}

// --- Fakes ---
class FakeDocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {}

// --- Helpers ---
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

MockQueryDocumentSnapshot createMockDoc(Map<String, dynamic> data) {
  final mockDoc = MockQueryDocumentSnapshot();
  when(() => mockDoc.data()).thenReturn(data);
  return mockDoc;
}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late FirestoreTaskDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(FakeDocumentReference());
  });

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    dataSource = FirestoreTaskDataSourceImpl(mockFirestore);

    when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
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
    test('calls set on the correct document path', () async {
      final mockDocRef = MockDocumentReference();
      final dto = sampleDto();

      when(() => mockFirestore.doc(any())).thenReturn(mockDocRef);
      when(() => mockDocRef.set(any())).thenAnswer((_) async {});

      await dataSource.setTask(testUserId, dto);

      verify(
        () => mockFirestore.doc('users/$testUserId/tasks/${dto.id}'),
      ).called(1);
      verify(() => mockDocRef.set(dto.toFirestore())).called(1);
    });

    test('passes DTO data converted to Firestore format', () async {
      final mockDocRef = MockDocumentReference();
      final dto = sampleDto();

      when(() => mockFirestore.doc(any())).thenReturn(mockDocRef);

      Map<String, dynamic>? capturedData;
      when(() => mockDocRef.set(any())).thenAnswer((invocation) async {
        capturedData =
            invocation.positionalArguments[0] as Map<String, dynamic>;
      });

      await dataSource.setTask(testUserId, dto);

      expect(capturedData, isNotNull);
      expect(capturedData!['id'], dto.id);
      expect(capturedData!['title'], dto.title);
      expect(capturedData!.containsKey('isSynced'), isFalse);
    });
  });

  group('batchSetTasks', () {
    test('calls batch.set for each DTO and commits once', () async {
      final mockBatch = MockWriteBatch();
      final mockDocRef1 = MockDocumentReference();
      final mockDocRef2 = MockDocumentReference();

      final dto1 = sampleDto(id: 'task-1');
      final dto2 = sampleDto(id: 'task-2');

      when(() => mockFirestore.batch()).thenReturn(mockBatch);
      when(
        () => mockFirestore.doc('users/$testUserId/tasks/task-1'),
      ).thenReturn(mockDocRef1);
      when(
        () => mockFirestore.doc('users/$testUserId/tasks/task-2'),
      ).thenReturn(mockDocRef2);
      when(() => mockBatch.set(any(), any())).thenReturn(null);
      when(() => mockBatch.commit()).thenAnswer((_) async {});

      await dataSource.batchSetTasks(testUserId, [dto1, dto2]);

      verify(() => mockBatch.set(mockDocRef1, dto1.toFirestore())).called(1);
      verify(() => mockBatch.set(mockDocRef2, dto2.toFirestore())).called(1);
      verify(() => mockBatch.commit()).called(1);
    });

    test('calls batch.set 0 times for empty list', () async {
      final mockBatch = MockWriteBatch();

      when(() => mockFirestore.batch()).thenReturn(mockBatch);
      when(() => mockBatch.set(any(), any())).thenReturn(null);
      when(() => mockBatch.commit()).thenAnswer((_) async {});

      await dataSource.batchSetTasks(testUserId, []);

      verifyNever(() => mockBatch.set(any(), any()));
      verify(() => mockBatch.commit()).called(1);
    });
  });

  group('fetchAllTasks', () {
    test('returns list of DTOs from snapshot docs', () async {
      final mockSnapshot = MockQuerySnapshot();
      final doc1 = createMockDoc(sampleTaskData(id: 'task-1'));
      final doc2 = createMockDoc(sampleTaskData(id: 'task-2'));

      when(() => mockCollection.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([doc1, doc2]);

      final result = await dataSource.fetchAllTasks(testUserId);

      expect(result, hasLength(2));
      expect(result[0].id, 'task-1');
      expect(result[1].id, 'task-2');
      verify(
        () => mockFirestore.collection('users/$testUserId/tasks'),
      ).called(1);
    });

    test('returns empty list for empty snapshot', () async {
      final mockSnapshot = MockQuerySnapshot();

      when(() => mockCollection.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([]);

      final result = await dataSource.fetchAllTasks(testUserId);

      expect(result, isEmpty);
    });
  });

  group('watchTasks', () {
    test('emits list of DTOs from snapshot stream', () async {
      final mockSnapshot = MockQuerySnapshot();
      final doc1 = createMockDoc(sampleTaskData(id: 'task-1'));

      when(
        () => mockCollection.snapshots(),
      ).thenAnswer((_) => Stream.value(mockSnapshot));
      when(() => mockSnapshot.docs).thenReturn([doc1]);

      final result = await dataSource.watchTasks(testUserId).first;

      expect(result, hasLength(1));
      expect(result[0].id, 'task-1');
    });

    test('emits empty list for empty snapshot', () async {
      final mockSnapshot = MockQuerySnapshot();

      when(
        () => mockCollection.snapshots(),
      ).thenAnswer((_) => Stream.value(mockSnapshot));
      when(() => mockSnapshot.docs).thenReturn([]);

      final result = await dataSource.watchTasks(testUserId).first;

      expect(result, isEmpty);
    });

    test('emits multiple updates from stream', () async {
      final snapshot1 = MockQuerySnapshot();
      final snapshot2 = MockQuerySnapshot();

      final doc1 = createMockDoc(sampleTaskData(id: 'task-1'));
      final doc2 = createMockDoc(sampleTaskData(id: 'task-2'));

      when(() => snapshot1.docs).thenReturn([doc1]);
      when(() => snapshot2.docs).thenReturn([doc1, doc2]);

      when(
        () => mockCollection.snapshots(),
      ).thenAnswer((_) => Stream.fromIterable([snapshot1, snapshot2]));

      final results = await dataSource.watchTasks(testUserId).toList();

      expect(results, hasLength(2));
      expect(results[0], hasLength(1));
      expect(results[1], hasLength(2));
    });
  });
}
