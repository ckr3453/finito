import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/data/database/app_database.dart';
import 'package:todo_app/data/datasources/remote/firestore_task_datasource.dart';
import 'package:todo_app/data/models/task_firestore_dto.dart';
import 'package:todo_app/data/repositories/local_task_repository.dart';
import 'package:todo_app/domain/entities/task_entity.dart';
import 'package:todo_app/services/connectivity_service.dart';
import 'package:todo_app/services/task_sync_service.dart';

import '../helpers/test_database.dart';

class MockFirestoreTaskDataSource extends Mock
    implements FirestoreTaskDataSource {}

class MockConnectivityService extends Mock implements ConnectivityService {}

class FakeTaskFirestoreDto extends Fake implements TaskFirestoreDto {}

void main() {
  late AppDatabase db;
  late LocalTaskRepository localRepo;
  late MockFirestoreTaskDataSource mockRemote;
  late MockConnectivityService mockConnectivity;
  late TaskSyncService syncService;
  late StreamController<List<TaskFirestoreDto>> watchController;
  late StreamController<bool> connectivityController;

  const userId = 'integration-user';
  final baseTime = DateTime(2026, 2, 10, 12, 0, 0);

  setUpAll(() {
    registerFallbackValue(FakeTaskFirestoreDto());
    registerFallbackValue(<TaskFirestoreDto>[]);
  });

  setUp(() {
    db = createTestDatabase();
    localRepo = LocalTaskRepository(db);
    mockRemote = MockFirestoreTaskDataSource();
    mockConnectivity = MockConnectivityService();
    watchController = StreamController<List<TaskFirestoreDto>>.broadcast();
    connectivityController = StreamController<bool>.broadcast();

    syncService = TaskSyncService(
      repository: localRepo,
      remoteDataSource: mockRemote,
      connectivityService: mockConnectivity,
    );
  });

  tearDown(() async {
    syncService.stop();
    await watchController.close();
    await connectivityController.close();
    await db.close();
  });

  TaskEntity makeEntity({
    required String id,
    String title = 'Test Task',
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool isSynced = false,
  }) {
    return TaskEntity(
      id: id,
      title: title,
      createdAt: baseTime,
      updatedAt: updatedAt ?? baseTime,
      isSynced: isSynced,
      deletedAt: deletedAt,
    );
  }

  TaskFirestoreDto makeDto({
    required String id,
    String title = 'Remote Task',
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
      createdAt: baseTime,
      updatedAt: updatedAt ?? baseTime,
      deletedAt: deletedAt,
    );
  }

  void stubOnline() {
    when(() => mockConnectivity.isOnline).thenAnswer((_) async => true);
    when(
      () => mockConnectivity.onConnectivityChanged,
    ).thenAnswer((_) => connectivityController.stream);
  }

  void stubOffline() {
    when(() => mockConnectivity.isOnline).thenAnswer((_) async => false);
    when(
      () => mockConnectivity.onConnectivityChanged,
    ).thenAnswer((_) => connectivityController.stream);
  }

  void stubRemoteEmpty() {
    when(
      () => mockRemote.fetchAllTasks(any()),
    ).thenAnswer((_) async => []);
    when(
      () => mockRemote.watchTasks(any()),
    ).thenAnswer((_) => watchController.stream);
  }

  void stubRemotePush() {
    when(
      () => mockRemote.batchSetTasks(any(), any()),
    ).thenAnswer((_) async {});
  }

  // ==========================================================================
  // 1. Full push flow: local unsynced → push to remote → markSynced
  // ==========================================================================
  group('full push flow', () {
    test('로컬 미동기 태스크가 start 시 remote에 push되고 synced 처리된다', () async {
      // Arrange: 로컬에 unsynced 태스크 2개 생성
      await localRepo.createTask(makeEntity(id: 'local-1', title: 'Task A'));
      await localRepo.createTask(makeEntity(id: 'local-2', title: 'Task B'));

      // unsynced 확인
      var unsynced = await localRepo.getUnsyncedTasks();
      expect(unsynced, hasLength(2));

      stubOnline();
      stubRemoteEmpty();
      stubRemotePush();

      // Act
      await syncService.start(userId);

      // Assert: remote에 push 호출됨
      final captured =
          verify(() => mockRemote.batchSetTasks(userId, captureAny())).captured;
      final pushedDtos = captured.first as List<TaskFirestoreDto>;
      expect(pushedDtos, hasLength(2));
      expect(pushedDtos.map((d) => d.id).toSet(), {'local-1', 'local-2'});

      // Assert: 로컬에서 모두 synced 처리됨
      unsynced = await localRepo.getUnsyncedTasks();
      expect(unsynced, isEmpty);

      // Assert: unsyncedCount stream에 0 반영
      expect(syncService.currentUnsyncedCount, 0);
    });

    test('syncNow 호출 시 새로 생긴 unsynced 태스크가 push된다', () async {
      stubOnline();
      stubRemoteEmpty();
      stubRemotePush();

      await syncService.start(userId);

      // start 후 새 태스크 추가 (로컬에 직접)
      await localRepo.createTask(makeEntity(id: 'new-1', title: 'New Task'));

      var unsynced = await localRepo.getUnsyncedTasks();
      expect(unsynced, hasLength(1));

      // Act
      await syncService.syncNow();

      // Assert
      unsynced = await localRepo.getUnsyncedTasks();
      expect(unsynced, isEmpty);
      expect(syncService.currentStatus, SyncStatus.idle);
    });
  });

  // ==========================================================================
  // 2. Full pull flow: remote tasks → pull & merge → local DB
  // ==========================================================================
  group('full pull flow', () {
    test('remote에만 있는 태스크가 로컬 DB에 upsert된다', () async {
      final remoteDtos = [
        makeDto(id: 'remote-1', title: 'Remote Task 1'),
        makeDto(id: 'remote-2', title: 'Remote Task 2'),
      ];

      stubOnline();
      stubRemotePush();
      when(
        () => mockRemote.fetchAllTasks(any()),
      ).thenAnswer((_) async => remoteDtos);
      when(
        () => mockRemote.watchTasks(any()),
      ).thenAnswer((_) => watchController.stream);

      // Act
      await syncService.start(userId);

      // Assert: 로컬 DB에 존재
      final task1 = await localRepo.getTaskById('remote-1');
      final task2 = await localRepo.getTaskById('remote-2');

      expect(task1, isNotNull);
      expect(task1!.title, 'Remote Task 1');
      expect(task1.isSynced, true);

      expect(task2, isNotNull);
      expect(task2!.title, 'Remote Task 2');
      expect(task2.isSynced, true);
    });

    test('remote listener snapshot이 로컬 DB에 반영된다', () async {
      stubOnline();
      stubRemoteEmpty();
      stubRemotePush();

      await syncService.start(userId);

      // Act: remote listener로 새 태스크 수신
      watchController.add([makeDto(id: 'live-1', title: 'Live Task')]);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      final task = await localRepo.getTaskById('live-1');
      expect(task, isNotNull);
      expect(task!.title, 'Live Task');
      expect(task.isSynced, true);
    });
  });

  // ==========================================================================
  // 3. LWW conflict resolution with real DB
  // ==========================================================================
  group('LWW conflict resolution', () {
    test('remote가 더 최신이면 로컬이 remote 버전으로 덮어쓰인다', () async {
      // Arrange: 로컬에 기존 태스크
      await localRepo.createTask(
        makeEntity(
          id: 'conflict-1',
          title: 'Local Version',
          updatedAt: baseTime,
          isSynced: true,
        ),
      );

      // remote에 더 최신 버전
      final remoteDto = makeDto(
        id: 'conflict-1',
        title: 'Remote Version',
        updatedAt: baseTime.add(const Duration(minutes: 5)),
      );

      stubOnline();
      stubRemotePush();
      when(
        () => mockRemote.fetchAllTasks(any()),
      ).thenAnswer((_) async => [remoteDto]);
      when(
        () => mockRemote.watchTasks(any()),
      ).thenAnswer((_) => watchController.stream);

      // Act
      await syncService.start(userId);

      // Assert: 로컬 DB가 remote 버전으로 업데이트됨
      final task = await localRepo.getTaskById('conflict-1');
      expect(task, isNotNull);
      expect(task!.title, 'Remote Version');
    });

    test('local이 더 최신이면 로컬이 유지된다', () async {
      // Arrange: 로컬에 더 최신 태스크
      await localRepo.createTask(
        makeEntity(
          id: 'conflict-2',
          title: 'Local Newer',
          updatedAt: baseTime.add(const Duration(minutes: 5)),
          isSynced: true,
        ),
      );

      // remote에 오래된 버전
      final remoteDto = makeDto(
        id: 'conflict-2',
        title: 'Remote Older',
        updatedAt: baseTime,
      );

      stubOnline();
      stubRemotePush();
      when(
        () => mockRemote.fetchAllTasks(any()),
      ).thenAnswer((_) async => [remoteDto]);
      when(
        () => mockRemote.watchTasks(any()),
      ).thenAnswer((_) => watchController.stream);

      // Act
      await syncService.start(userId);

      // Assert: 로컬 버전 유지
      final task = await localRepo.getTaskById('conflict-2');
      expect(task, isNotNull);
      expect(task!.title, 'Local Newer');
    });

    test('remote에서 삭제된 태스크는 LWW에 의해 로컬에도 삭제 반영된다', () async {
      // Arrange: 로컬에 기존 태스크
      await localRepo.createTask(
        makeEntity(
          id: 'del-1',
          title: 'Will Be Deleted',
          updatedAt: baseTime,
          isSynced: true,
        ),
      );

      // remote에서 soft delete (더 최신)
      final remoteDto = makeDto(
        id: 'del-1',
        title: 'Will Be Deleted',
        updatedAt: baseTime.add(const Duration(minutes: 1)),
        deletedAt: baseTime.add(const Duration(minutes: 1)),
      );

      stubOnline();
      stubRemotePush();
      when(
        () => mockRemote.fetchAllTasks(any()),
      ).thenAnswer((_) async => [remoteDto]);
      when(
        () => mockRemote.watchTasks(any()),
      ).thenAnswer((_) => watchController.stream);

      // Act
      await syncService.start(userId);

      // Assert: getTaskById는 soft-deleted 태스크를 숨김
      final task = await localRepo.getTaskById('del-1');
      expect(task, isNull);
    });
  });

  // ==========================================================================
  // 4. Offline → online transition
  // ==========================================================================
  group('offline to online transition', () {
    test('오프라인에서 시작 후 온라인 전환 시 미동기 태스크가 push된다', () async {
      // Arrange: 로컬에 unsynced 태스크
      await localRepo.createTask(makeEntity(id: 'offline-1', title: 'Offline'));

      stubOffline();

      // Act: 오프라인으로 시작
      await syncService.start(userId);

      expect(syncService.currentStatus, SyncStatus.offline);
      expect(syncService.currentUnsyncedCount, 1);

      // 온라인 전환 준비
      when(() => mockConnectivity.isOnline).thenAnswer((_) async => true);
      stubRemotePush();

      // Act: 온라인 전환
      connectivityController.add(true);
      await Future.delayed(const Duration(milliseconds: 200));

      // Assert: push 호출됨
      verify(() => mockRemote.batchSetTasks(userId, any())).called(1);

      // Assert: synced 처리됨
      final unsynced = await localRepo.getUnsyncedTasks();
      expect(unsynced, isEmpty);
      expect(syncService.currentStatus, SyncStatus.idle);
    });

    test('온라인에서 오프라인으로 전환 시 상태가 offline으로 변경된다', () async {
      stubOnline();
      stubRemoteEmpty();
      stubRemotePush();

      await syncService.start(userId);
      expect(syncService.currentStatus, SyncStatus.idle);

      // Act
      final future = expectLater(
        syncService.statusStream,
        emits(SyncStatus.offline),
      );
      connectivityController.add(false);
      await future;

      expect(syncService.currentStatus, SyncStatus.offline);
    });
  });

  // ==========================================================================
  // 5. Error recovery
  // ==========================================================================
  group('error recovery', () {
    test('push 실패 후 syncNow로 재시도하면 성공한다', () async {
      await localRepo.createTask(makeEntity(id: 'retry-1'));

      stubOnline();
      when(
        () => mockRemote.fetchAllTasks(any()),
      ).thenAnswer((_) async => []);
      when(
        () => mockRemote.watchTasks(any()),
      ).thenAnswer((_) => watchController.stream);

      // 첫 push 실패
      when(
        () => mockRemote.batchSetTasks(any(), any()),
      ).thenAnswer((_) async => throw Exception('network error'));

      await syncService.start(userId);
      expect(syncService.currentStatus, SyncStatus.error);

      // unsynced 태스크 아직 남아있음
      var unsynced = await localRepo.getUnsyncedTasks();
      expect(unsynced, hasLength(1));

      // 재시도 시 성공
      when(
        () => mockRemote.batchSetTasks(any(), any()),
      ).thenAnswer((_) async {});

      await syncService.syncNow();

      expect(syncService.currentStatus, SyncStatus.idle);
      unsynced = await localRepo.getUnsyncedTasks();
      expect(unsynced, isEmpty);
    });
  });

  // ==========================================================================
  // 6. Status stream + unsyncedCount stream accuracy
  // ==========================================================================
  group('stream accuracy', () {
    test('start 전체 과정에서 status stream이 올바른 순서로 emit된다', () async {
      await localRepo.createTask(makeEntity(id: 'stream-1'));

      stubOnline();
      stubRemotePush();
      when(
        () => mockRemote.fetchAllTasks(any()),
      ).thenAnswer((_) async => []);
      when(
        () => mockRemote.watchTasks(any()),
      ).thenAnswer((_) => watchController.stream);

      final statuses = <SyncStatus>[];
      final sub = syncService.statusStream.listen(statuses.add);

      await syncService.start(userId);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(statuses, [SyncStatus.syncing, SyncStatus.idle]);

      await sub.cancel();
    });

    test('unsyncedCount가 push 전후로 정확히 반영된다', () async {
      await localRepo.createTask(makeEntity(id: 'count-1'));
      await localRepo.createTask(makeEntity(id: 'count-2'));
      await localRepo.createTask(makeEntity(id: 'count-3'));

      stubOnline();
      stubRemotePush();
      stubRemoteEmpty();

      final counts = <int>[];
      final sub = syncService.unsyncedCountStream.listen(counts.add);

      await syncService.start(userId);
      await Future.delayed(const Duration(milliseconds: 50));

      // push 후 0이 되어야 함
      expect(counts.last, 0);

      await sub.cancel();
    });
  });

  // ==========================================================================
  // 7. Soft-deleted task push
  // ==========================================================================
  group('soft-deleted task sync', () {
    test('soft-deleted 태스크도 remote에 push된다', () async {
      // Arrange: 태스크 생성 후 삭제
      await localRepo.createTask(makeEntity(id: 'soft-del-1'));
      await localRepo.deleteTask('soft-del-1');

      // getUnsyncedTasks는 soft-deleted도 포함
      final unsynced = await localRepo.getUnsyncedTasks();
      expect(unsynced, hasLength(1));
      expect(unsynced.first.deletedAt, isNotNull);

      stubOnline();
      stubRemoteEmpty();
      stubRemotePush();

      // Act
      await syncService.start(userId);

      // Assert: push에 soft-deleted 태스크가 포함됨
      final captured =
          verify(() => mockRemote.batchSetTasks(userId, captureAny())).captured;
      final pushedDtos = captured.first as List<TaskFirestoreDto>;
      expect(pushedDtos, hasLength(1));
      expect(pushedDtos.first.id, 'soft-del-1');
      expect(pushedDtos.first.deletedAt, isNotNull);
    });
  });
}
