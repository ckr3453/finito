import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/data/datasources/remote/firestore_task_datasource.dart';
import 'package:todo_app/data/models/task_firestore_dto.dart';
import 'package:todo_app/domain/entities/task_entity.dart';
import 'package:todo_app/domain/repositories/task_repository.dart';
import 'package:todo_app/services/connectivity_service.dart';
import 'package:todo_app/services/task_sync_service.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class MockFirestoreTaskDataSource extends Mock
    implements FirestoreTaskDataSource {}

class MockConnectivityService extends Mock implements ConnectivityService {}

class FakeTaskFirestoreDto extends Fake implements TaskFirestoreDto {}

class FakeTaskEntity extends Fake implements TaskEntity {}

void main() {
  late MockTaskRepository mockRepository;
  late MockFirestoreTaskDataSource mockRemoteDataSource;
  late MockConnectivityService mockConnectivityService;
  late TaskSyncService service;
  late StreamController<List<TaskFirestoreDto>> watchTasksController;
  late StreamController<bool> connectivityController;

  const testUserId = 'test-user-123';
  final now = DateTime(2026, 1, 15, 12, 0, 0);

  setUpAll(() {
    registerFallbackValue(FakeTaskFirestoreDto());
    registerFallbackValue(FakeTaskEntity());
    registerFallbackValue(<TaskFirestoreDto>[]);
  });

  setUp(() {
    mockRepository = MockTaskRepository();
    mockRemoteDataSource = MockFirestoreTaskDataSource();
    mockConnectivityService = MockConnectivityService();
    watchTasksController = StreamController<List<TaskFirestoreDto>>.broadcast();
    connectivityController = StreamController<bool>.broadcast();

    service = TaskSyncService(
      repository: mockRepository,
      remoteDataSource: mockRemoteDataSource,
      connectivityService: mockConnectivityService,
    );
  });

  tearDown(() {
    service.stop();
    watchTasksController.close();
    connectivityController.close();
  });

  TaskEntity makeEntity({
    String id = 'task-1',
    String title = 'Test Task',
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool isSynced = false,
  }) {
    return TaskEntity(
      id: id,
      title: title,
      createdAt: now,
      updatedAt: updatedAt ?? now,
      isSynced: isSynced,
      deletedAt: deletedAt,
    );
  }

  TaskFirestoreDto makeDto({
    String id = 'task-1',
    String title = 'Test Task',
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TaskFirestoreDto(
      id: id,
      title: title,
      description: '',
      status: 'pending',
      priority: 'medium',
      tagIds: [],
      sortOrder: 0,
      createdAt: now,
      updatedAt: updatedAt ?? now,
      deletedAt: deletedAt,
    );
  }

  void stubHappyPathStart() {
    when(() => mockConnectivityService.isOnline).thenAnswer((_) async => true);
    when(
      () => mockConnectivityService.onConnectivityChanged,
    ).thenAnswer((_) => connectivityController.stream);
    when(() => mockRepository.getUnsyncedTasks()).thenAnswer((_) async => []);
    when(
      () => mockRemoteDataSource.fetchAllTasks(any()),
    ).thenAnswer((_) async => []);
    when(
      () => mockRemoteDataSource.watchTasks(any()),
    ).thenAnswer((_) => watchTasksController.stream);
  }

  // ============================================================
  // Group 1: statusStream
  // ============================================================
  group('statusStream', () {
    test('initial currentStatus is idle', () {
      expect(service.currentStatus, SyncStatus.idle);
    });

    test('emits syncing then idle during successful start', () async {
      stubHappyPathStart();

      final future = expectLater(
        service.statusStream,
        emitsInOrder([SyncStatus.syncing, SyncStatus.idle]),
      );

      await service.start(testUserId);
      await future;
    });
  });

  // ============================================================
  // Group 2: unsyncedCountStream
  // ============================================================
  group('unsyncedCountStream', () {
    test('initial currentUnsyncedCount is 0', () {
      expect(service.currentUnsyncedCount, 0);
    });

    test('emits count via stream after start', () async {
      stubHappyPathStart();

      final future = expectLater(service.unsyncedCountStream, emits(0));

      await service.start(testUserId);
      await future;
    });
  });

  // ============================================================
  // Group 3: start > initial push
  // ============================================================
  group('start > initial push', () {
    test('pushes unsynced tasks to remote', () async {
      final unsyncedTask = makeEntity(id: 'task-1', isSynced: false);

      when(
        () => mockConnectivityService.isOnline,
      ).thenAnswer((_) async => true);
      when(
        () => mockConnectivityService.onConnectivityChanged,
      ).thenAnswer((_) => connectivityController.stream);
      when(
        () => mockRepository.getUnsyncedTasks(),
      ).thenAnswer((_) async => [unsyncedTask]);
      when(
        () => mockRemoteDataSource.batchSetTasks(any(), any()),
      ).thenAnswer((_) async {});
      when(() => mockRepository.markSynced(any())).thenAnswer((_) async {});
      when(
        () => mockRemoteDataSource.fetchAllTasks(any()),
      ).thenAnswer((_) async => []);
      when(
        () => mockRemoteDataSource.watchTasks(any()),
      ).thenAnswer((_) => watchTasksController.stream);

      await service.start(testUserId);

      verify(
        () => mockRemoteDataSource.batchSetTasks(testUserId, any()),
      ).called(1);
    });

    test('skips push when no unsynced tasks', () async {
      stubHappyPathStart();

      await service.start(testUserId);

      verifyNever(() => mockRemoteDataSource.batchSetTasks(any(), any()));
    });

    test('calls markSynced for each pushed task', () async {
      final task1 = makeEntity(id: 'task-1');
      final task2 = makeEntity(id: 'task-2');

      when(
        () => mockConnectivityService.isOnline,
      ).thenAnswer((_) async => true);
      when(
        () => mockConnectivityService.onConnectivityChanged,
      ).thenAnswer((_) => connectivityController.stream);
      var pushCallCount = 0;
      when(() => mockRepository.getUnsyncedTasks()).thenAnswer((_) async {
        pushCallCount++;
        if (pushCallCount == 1) return [task1, task2];
        return [];
      });
      when(
        () => mockRemoteDataSource.batchSetTasks(any(), any()),
      ).thenAnswer((_) async {});
      when(() => mockRepository.markSynced(any())).thenAnswer((_) async {});
      when(
        () => mockRemoteDataSource.fetchAllTasks(any()),
      ).thenAnswer((_) async => []);
      when(
        () => mockRemoteDataSource.watchTasks(any()),
      ).thenAnswer((_) => watchTasksController.stream);

      await service.start(testUserId);

      verify(() => mockRepository.markSynced('task-1')).called(1);
      verify(() => mockRepository.markSynced('task-2')).called(1);
    });

    test('updates unsynced count after push', () async {
      final unsyncedTask = makeEntity(id: 'task-1', isSynced: false);

      when(
        () => mockConnectivityService.isOnline,
      ).thenAnswer((_) async => true);
      when(
        () => mockConnectivityService.onConnectivityChanged,
      ).thenAnswer((_) => connectivityController.stream);
      var callCount = 0;
      when(() => mockRepository.getUnsyncedTasks()).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) return [unsyncedTask];
        return [];
      });
      when(
        () => mockRemoteDataSource.batchSetTasks(any(), any()),
      ).thenAnswer((_) async {});
      when(() => mockRepository.markSynced(any())).thenAnswer((_) async {});
      when(
        () => mockRemoteDataSource.fetchAllTasks(any()),
      ).thenAnswer((_) async => []);
      when(
        () => mockRemoteDataSource.watchTasks(any()),
      ).thenAnswer((_) => watchTasksController.stream);

      final future = expectLater(service.unsyncedCountStream, emits(0));

      await service.start(testUserId);
      await future;
    });
  });

  // ============================================================
  // Group 4: start > pull and merge / LWW
  // ============================================================
  group('start > pull and merge / LWW', () {
    test('upserts remote task when not in local DB', () async {
      final remoteDto = makeDto(id: 'remote-1');

      when(
        () => mockConnectivityService.isOnline,
      ).thenAnswer((_) async => true);
      when(
        () => mockConnectivityService.onConnectivityChanged,
      ).thenAnswer((_) => connectivityController.stream);
      when(() => mockRepository.getUnsyncedTasks()).thenAnswer((_) async => []);
      when(
        () => mockRemoteDataSource.fetchAllTasks(any()),
      ).thenAnswer((_) async => [remoteDto]);
      when(
        () => mockRepository.getTaskById('remote-1'),
      ).thenAnswer((_) async => null);
      when(() => mockRepository.upsertTask(any())).thenAnswer((_) async {});
      when(
        () => mockRemoteDataSource.watchTasks(any()),
      ).thenAnswer((_) => watchTasksController.stream);

      await service.start(testUserId);

      final captured = verify(
        () => mockRepository.upsertTask(captureAny()),
      ).captured;
      expect(captured.length, 1);
      final upserted = captured.first as TaskEntity;
      expect(upserted.id, 'remote-1');
      expect(upserted.isSynced, true);
    });

    test('remote wins when remote.updatedAt > local.updatedAt', () async {
      final remoteDto = makeDto(
        id: 'task-1',
        title: 'Remote Title',
        updatedAt: now.add(const Duration(seconds: 10)),
      );
      final localEntity = makeEntity(
        id: 'task-1',
        title: 'Local Title',
        updatedAt: now,
      );

      when(
        () => mockConnectivityService.isOnline,
      ).thenAnswer((_) async => true);
      when(
        () => mockConnectivityService.onConnectivityChanged,
      ).thenAnswer((_) => connectivityController.stream);
      when(() => mockRepository.getUnsyncedTasks()).thenAnswer((_) async => []);
      when(
        () => mockRemoteDataSource.fetchAllTasks(any()),
      ).thenAnswer((_) async => [remoteDto]);
      when(
        () => mockRepository.getTaskById('task-1'),
      ).thenAnswer((_) async => localEntity);
      when(() => mockRepository.upsertTask(any())).thenAnswer((_) async {});
      when(
        () => mockRemoteDataSource.watchTasks(any()),
      ).thenAnswer((_) => watchTasksController.stream);

      await service.start(testUserId);

      final captured = verify(
        () => mockRepository.upsertTask(captureAny()),
      ).captured;
      expect(captured.length, 1);
      final upserted = captured.first as TaskEntity;
      expect(upserted.title, 'Remote Title');
    });

    test('local wins when local.updatedAt > remote.updatedAt', () async {
      final remoteDto = makeDto(
        id: 'task-1',
        title: 'Remote Title',
        updatedAt: now,
      );
      final localEntity = makeEntity(
        id: 'task-1',
        title: 'Local Title',
        updatedAt: now.add(const Duration(seconds: 10)),
      );

      when(
        () => mockConnectivityService.isOnline,
      ).thenAnswer((_) async => true);
      when(
        () => mockConnectivityService.onConnectivityChanged,
      ).thenAnswer((_) => connectivityController.stream);
      when(() => mockRepository.getUnsyncedTasks()).thenAnswer((_) async => []);
      when(
        () => mockRemoteDataSource.fetchAllTasks(any()),
      ).thenAnswer((_) async => [remoteDto]);
      when(
        () => mockRepository.getTaskById('task-1'),
      ).thenAnswer((_) async => localEntity);
      when(
        () => mockRemoteDataSource.watchTasks(any()),
      ).thenAnswer((_) => watchTasksController.stream);

      await service.start(testUserId);

      verifyNever(() => mockRepository.upsertTask(any()));
    });

    test('local wins when timestamps are equal', () async {
      final remoteDto = makeDto(
        id: 'task-1',
        title: 'Remote Title',
        updatedAt: now,
      );
      final localEntity = makeEntity(
        id: 'task-1',
        title: 'Local Title',
        updatedAt: now,
      );

      when(
        () => mockConnectivityService.isOnline,
      ).thenAnswer((_) async => true);
      when(
        () => mockConnectivityService.onConnectivityChanged,
      ).thenAnswer((_) => connectivityController.stream);
      when(() => mockRepository.getUnsyncedTasks()).thenAnswer((_) async => []);
      when(
        () => mockRemoteDataSource.fetchAllTasks(any()),
      ).thenAnswer((_) async => [remoteDto]);
      when(
        () => mockRepository.getTaskById('task-1'),
      ).thenAnswer((_) async => localEntity);
      when(
        () => mockRemoteDataSource.watchTasks(any()),
      ).thenAnswer((_) => watchTasksController.stream);

      await service.start(testUserId);

      verifyNever(() => mockRepository.upsertTask(any()));
    });

    test('handles multiple tasks with mixed LWW outcomes', () async {
      final remoteNew = makeDto(
        id: 'new-1',
        title: 'New Remote',
        updatedAt: now,
      );
      final remoteWins = makeDto(
        id: 'existing-1',
        title: 'Remote Wins',
        updatedAt: now.add(const Duration(seconds: 10)),
      );
      final localWins = makeDto(
        id: 'existing-2',
        title: 'Local Wins',
        updatedAt: now,
      );

      when(
        () => mockConnectivityService.isOnline,
      ).thenAnswer((_) async => true);
      when(
        () => mockConnectivityService.onConnectivityChanged,
      ).thenAnswer((_) => connectivityController.stream);
      when(() => mockRepository.getUnsyncedTasks()).thenAnswer((_) async => []);
      when(
        () => mockRemoteDataSource.fetchAllTasks(any()),
      ).thenAnswer((_) async => [remoteNew, remoteWins, localWins]);
      when(
        () => mockRepository.getTaskById('new-1'),
      ).thenAnswer((_) async => null);
      when(
        () => mockRepository.getTaskById('existing-1'),
      ).thenAnswer((_) async => makeEntity(id: 'existing-1', updatedAt: now));
      when(() => mockRepository.getTaskById('existing-2')).thenAnswer(
        (_) async => makeEntity(
          id: 'existing-2',
          updatedAt: now.add(const Duration(seconds: 10)),
        ),
      );
      when(() => mockRepository.upsertTask(any())).thenAnswer((_) async {});
      when(
        () => mockRemoteDataSource.watchTasks(any()),
      ).thenAnswer((_) => watchTasksController.stream);

      await service.start(testUserId);

      verify(() => mockRepository.upsertTask(any())).called(2);
    });

    test('propagates deletedAt from remote', () async {
      final deletedAt = now.add(const Duration(hours: 1));
      final remoteDto = makeDto(
        id: 'task-1',
        updatedAt: now.add(const Duration(seconds: 10)),
        deletedAt: deletedAt,
      );

      when(
        () => mockConnectivityService.isOnline,
      ).thenAnswer((_) async => true);
      when(
        () => mockConnectivityService.onConnectivityChanged,
      ).thenAnswer((_) => connectivityController.stream);
      when(() => mockRepository.getUnsyncedTasks()).thenAnswer((_) async => []);
      when(
        () => mockRemoteDataSource.fetchAllTasks(any()),
      ).thenAnswer((_) async => [remoteDto]);
      when(
        () => mockRepository.getTaskById('task-1'),
      ).thenAnswer((_) async => makeEntity(id: 'task-1', updatedAt: now));
      when(() => mockRepository.upsertTask(any())).thenAnswer((_) async {});
      when(
        () => mockRemoteDataSource.watchTasks(any()),
      ).thenAnswer((_) => watchTasksController.stream);

      await service.start(testUserId);

      final captured = verify(
        () => mockRepository.upsertTask(captureAny()),
      ).captured;
      final upserted = captured.first as TaskEntity;
      expect(upserted.deletedAt, deletedAt);
    });
  });

  // ============================================================
  // Group 5: start > remote listener
  // ============================================================
  group('start > remote listener', () {
    test('subscribes to watchTasks', () async {
      stubHappyPathStart();

      await service.start(testUserId);

      verify(() => mockRemoteDataSource.watchTasks(testUserId)).called(1);
    });

    test('applies LWW on new snapshot from remote', () async {
      stubHappyPathStart();
      when(
        () => mockRepository.getTaskById('snap-1'),
      ).thenAnswer((_) async => null);
      when(() => mockRepository.upsertTask(any())).thenAnswer((_) async {});

      await service.start(testUserId);

      final snapshotDto = makeDto(id: 'snap-1');
      watchTasksController.add([snapshotDto]);
      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => mockRepository.upsertTask(any())).called(1);
    });

    test('skips stale snapshot where local is newer', () async {
      stubHappyPathStart();
      when(() => mockRepository.getTaskById('snap-1')).thenAnswer(
        (_) async => makeEntity(
          id: 'snap-1',
          updatedAt: now.add(const Duration(hours: 1)),
        ),
      );

      await service.start(testUserId);

      final staleDto = makeDto(id: 'snap-1', updatedAt: now);
      watchTasksController.add([staleDto]);
      await Future.delayed(const Duration(milliseconds: 50));

      verifyNever(() => mockRepository.upsertTask(any()));
    });

    test('emits error status on stream error', () async {
      stubHappyPathStart();

      await service.start(testUserId);

      final future = expectLater(service.statusStream, emits(SyncStatus.error));

      watchTasksController.addError(Exception('stream error'));
      await future;
    });
  });

  // ============================================================
  // Group 6: connectivity handling
  // ============================================================
  group('connectivity handling', () {
    test('sets offline status when starting offline', () async {
      when(
        () => mockConnectivityService.isOnline,
      ).thenAnswer((_) async => false);
      when(
        () => mockConnectivityService.onConnectivityChanged,
      ).thenAnswer((_) => connectivityController.stream);
      when(() => mockRepository.getUnsyncedTasks()).thenAnswer((_) async => []);

      final future = expectLater(
        service.statusStream,
        emits(SyncStatus.offline),
      );

      await service.start(testUserId);
      await future;
    });

    test('pushes changes when going from offline to online', () async {
      stubHappyPathStart();

      await service.start(testUserId);

      connectivityController.add(true);
      await Future.delayed(const Duration(milliseconds: 50));

      // getUnsyncedTasks called during: start push check, start count,
      // connectivity push, connectivity count
      verify(() => mockRepository.getUnsyncedTasks()).called(greaterThan(2));
    });

    test('emits offline status when connectivity is lost', () async {
      stubHappyPathStart();

      await service.start(testUserId);

      final future = expectLater(
        service.statusStream,
        emits(SyncStatus.offline),
      );

      connectivityController.add(false);
      await future;
    });

    test('emits syncing then idle when connectivity returns', () async {
      stubHappyPathStart();

      await service.start(testUserId);

      final future = expectLater(
        service.statusStream,
        emitsInOrder([SyncStatus.syncing, SyncStatus.idle]),
      );

      connectivityController.add(true);
      await future;
    });

    test('emits syncing then error when push fails on reconnect', () async {
      when(
        () => mockConnectivityService.isOnline,
      ).thenAnswer((_) async => true);
      when(
        () => mockConnectivityService.onConnectivityChanged,
      ).thenAnswer((_) => connectivityController.stream);
      when(() => mockRepository.getUnsyncedTasks()).thenAnswer((_) async => []);
      when(
        () => mockRemoteDataSource.fetchAllTasks(any()),
      ).thenAnswer((_) async => []);
      when(
        () => mockRemoteDataSource.watchTasks(any()),
      ).thenAnswer((_) => watchTasksController.stream);

      await service.start(testUserId);

      // Now make push fail on reconnect
      when(
        () => mockRepository.getUnsyncedTasks(),
      ).thenAnswer((_) async => [makeEntity(id: 'task-1')]);
      when(
        () => mockRemoteDataSource.batchSetTasks(any(), any()),
      ).thenAnswer((_) async => throw Exception('push failed'));

      final future = expectLater(
        service.statusStream,
        emitsInOrder([SyncStatus.syncing, SyncStatus.error]),
      );

      connectivityController.add(true);
      await future;
    });
  });

  // ============================================================
  // Group 7: stop + guards
  // ============================================================
  group('stop + guards', () {
    test('resets state on stop', () async {
      stubHappyPathStart();

      await service.start(testUserId);
      service.stop();

      expect(service.currentStatus, SyncStatus.idle);
      expect(service.currentUnsyncedCount, 0);
    });

    test('stop without start is safe', () {
      expect(() => service.stop(), returnsNormally);
    });

    test('double start is guarded', () async {
      stubHappyPathStart();

      await service.start(testUserId);
      await service.start(testUserId);

      verify(() => mockRemoteDataSource.fetchAllTasks(any())).called(1);
    });

    test('can restart after stop', () async {
      stubHappyPathStart();

      await service.start(testUserId);
      service.stop();
      await service.start(testUserId);

      verify(() => mockRemoteDataSource.fetchAllTasks(any())).called(2);
    });

    test('cancels remote and connectivity subscriptions', () async {
      stubHappyPathStart();

      await service.start(testUserId);
      service.stop();

      when(
        () => mockRepository.getTaskById(any()),
      ).thenAnswer((_) async => null);
      when(() => mockRepository.upsertTask(any())).thenAnswer((_) async {});

      watchTasksController.add([makeDto(id: 'after-stop')]);
      connectivityController.add(true);
      await Future.delayed(const Duration(milliseconds: 50));

      verifyNever(() => mockRepository.upsertTask(any()));
    });
  });

  // ============================================================
  // Group 8: syncNow + error handling
  // ============================================================
  group('syncNow + error handling', () {
    test('emits syncing then idle on syncNow', () async {
      stubHappyPathStart();

      await service.start(testUserId);

      final future = expectLater(
        service.statusStream,
        emitsInOrder([SyncStatus.syncing, SyncStatus.idle]),
      );

      await service.syncNow();
      await future;
    });

    test('emits offline status when syncing offline', () async {
      when(
        () => mockConnectivityService.isOnline,
      ).thenAnswer((_) async => true);
      when(
        () => mockConnectivityService.onConnectivityChanged,
      ).thenAnswer((_) => connectivityController.stream);
      when(() => mockRepository.getUnsyncedTasks()).thenAnswer((_) async => []);
      when(
        () => mockRemoteDataSource.fetchAllTasks(any()),
      ).thenAnswer((_) async => []);
      when(
        () => mockRemoteDataSource.watchTasks(any()),
      ).thenAnswer((_) => watchTasksController.stream);

      await service.start(testUserId);

      // Now go offline
      when(
        () => mockConnectivityService.isOnline,
      ).thenAnswer((_) async => false);

      final future = expectLater(
        service.statusStream,
        emits(SyncStatus.offline),
      );

      await service.syncNow();
      await future;
    });

    test('syncNow is no-op when not running', () async {
      await service.syncNow();

      verifyNever(() => mockConnectivityService.isOnline);
    });

    test('start emits syncing then error when push fails', () async {
      when(
        () => mockConnectivityService.isOnline,
      ).thenAnswer((_) async => true);
      when(
        () => mockConnectivityService.onConnectivityChanged,
      ).thenAnswer((_) => connectivityController.stream);
      when(
        () => mockRepository.getUnsyncedTasks(),
      ).thenAnswer((_) async => [makeEntity(id: 'task-1')]);
      when(
        () => mockRemoteDataSource.batchSetTasks(any(), any()),
      ).thenAnswer((_) async => throw Exception('push failed'));

      final future = expectLater(
        service.statusStream,
        emitsInOrder([SyncStatus.syncing, SyncStatus.error]),
      );

      await service.start(testUserId);
      await future;
    });

    test('start emits syncing then error when pull fails', () async {
      when(
        () => mockConnectivityService.isOnline,
      ).thenAnswer((_) async => true);
      when(
        () => mockConnectivityService.onConnectivityChanged,
      ).thenAnswer((_) => connectivityController.stream);
      when(() => mockRepository.getUnsyncedTasks()).thenAnswer((_) async => []);
      when(
        () => mockRemoteDataSource.fetchAllTasks(any()),
      ).thenAnswer((_) async => throw Exception('pull failed'));

      final future = expectLater(
        service.statusStream,
        emitsInOrder([SyncStatus.syncing, SyncStatus.error]),
      );

      await service.start(testUserId);
      await future;
    });

    test('syncNow emits syncing then error when push fails', () async {
      stubHappyPathStart();

      await service.start(testUserId);

      // Make push fail on syncNow
      when(
        () => mockRepository.getUnsyncedTasks(),
      ).thenAnswer((_) async => [makeEntity(id: 'task-1')]);
      when(
        () => mockRemoteDataSource.batchSetTasks(any(), any()),
      ).thenAnswer((_) async => throw Exception('push failed'));

      final future = expectLater(
        service.statusStream,
        emitsInOrder([SyncStatus.syncing, SyncStatus.error]),
      );

      await service.syncNow();
      await future;
    });
  });
}
