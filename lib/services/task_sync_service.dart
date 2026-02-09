import 'dart:async';

import 'package:todo_app/data/datasources/remote/firestore_task_datasource.dart';
import 'package:todo_app/data/models/task_firestore_dto.dart';
import 'package:todo_app/domain/repositories/task_repository.dart';
import 'package:todo_app/services/connectivity_service.dart';

enum SyncStatus { idle, syncing, error, offline }

class TaskSyncService {
  final TaskRepository _repository;
  final FirestoreTaskDataSource _remoteDataSource;
  final ConnectivityService _connectivityService;

  String? _userId;
  bool _isRunning = false;

  SyncStatus _lastStatus = SyncStatus.idle;
  int _lastUnsyncedCount = 0;

  final _statusController = StreamController<SyncStatus>.broadcast();
  final _unsyncedCountController = StreamController<int>.broadcast();

  StreamSubscription<List<TaskFirestoreDto>>? _remoteSub;
  StreamSubscription<bool>? _connectivitySub;

  TaskSyncService({
    required TaskRepository repository,
    required FirestoreTaskDataSource remoteDataSource,
    required ConnectivityService connectivityService,
  }) : _repository = repository,
       _remoteDataSource = remoteDataSource,
       _connectivityService = connectivityService;

  SyncStatus get currentStatus => _lastStatus;
  int get currentUnsyncedCount => _lastUnsyncedCount;

  Stream<SyncStatus> get statusStream => _statusController.stream;
  Stream<int> get unsyncedCountStream => _unsyncedCountController.stream;

  void _setStatus(SyncStatus status) {
    _lastStatus = status;
    _statusController.add(status);
  }

  void _setUnsyncedCount(int count) {
    _lastUnsyncedCount = count;
    _unsyncedCountController.add(count);
  }

  Future<void> start(String userId) async {
    if (_isRunning) return;
    _isRunning = true;
    _userId = userId;

    final online = await _connectivityService.isOnline;
    if (!online) {
      _setStatus(SyncStatus.offline);
      _startConnectivityListener();
      await _updateUnsyncedCount();
      return;
    }

    _setStatus(SyncStatus.syncing);
    try {
      await _pushUnsyncedChanges();
      await _pullAndMerge();
      _startRemoteListener();
      _startConnectivityListener();
      await _updateUnsyncedCount();
      _setStatus(SyncStatus.idle);
    } catch (_) {
      _setStatus(SyncStatus.error);
    }
  }

  void stop() {
    _remoteSub?.cancel();
    _remoteSub = null;
    _connectivitySub?.cancel();
    _connectivitySub = null;
    _isRunning = false;
    _userId = null;
    _setStatus(SyncStatus.idle);
    _setUnsyncedCount(0);
  }

  Future<void> syncNow() async {
    if (!_isRunning) return;

    final online = await _connectivityService.isOnline;
    if (!online) {
      _setStatus(SyncStatus.offline);
      return;
    }

    _setStatus(SyncStatus.syncing);
    try {
      await _pushUnsyncedChanges();
      await _updateUnsyncedCount();
      _setStatus(SyncStatus.idle);
    } catch (_) {
      _setStatus(SyncStatus.error);
    }
  }

  Future<void> _pushUnsyncedChanges() async {
    final unsynced = await _repository.getUnsyncedTasks();
    if (unsynced.isEmpty) return;

    final dtos = unsynced.map(TaskFirestoreDto.fromEntity).toList();
    await _remoteDataSource.batchSetTasks(_userId!, dtos);

    for (final task in unsynced) {
      await _repository.markSynced(task.id);
    }
  }

  Future<void> _pullAndMerge() async {
    final remoteDtos = await _remoteDataSource.fetchAllTasks(_userId!);
    for (final dto in remoteDtos) {
      await _applyLww(dto);
    }
  }

  Future<void> _applyLww(TaskFirestoreDto remoteDto) async {
    final local = await _repository.getTaskById(remoteDto.id);
    if (local == null) {
      await _repository.upsertTask(remoteDto.toEntity(isSynced: true));
      return;
    }
    if (remoteDto.updatedAt.isAfter(local.updatedAt)) {
      await _repository.upsertTask(remoteDto.toEntity(isSynced: true));
      return;
    }
    // local wins (including equal timestamps)
  }

  void _startRemoteListener() {
    _remoteSub = _remoteDataSource
        .watchTasks(_userId!)
        .listen(
          (dtos) async {
            for (final dto in dtos) {
              await _applyLww(dto);
            }
          },
          onError: (_) {
            _setStatus(SyncStatus.error);
          },
        );
  }

  void _startConnectivityListener() {
    _connectivitySub = _connectivityService.onConnectivityChanged.listen((
      online,
    ) async {
      if (online) {
        _setStatus(SyncStatus.syncing);
        try {
          await _pushUnsyncedChanges();
          await _updateUnsyncedCount();
          _setStatus(SyncStatus.idle);
        } catch (_) {
          _setStatus(SyncStatus.error);
        }
      } else {
        _setStatus(SyncStatus.offline);
      }
    });
  }

  Future<void> _updateUnsyncedCount() async {
    final unsynced = await _repository.getUnsyncedTasks();
    _setUnsyncedCount(unsynced.length);
  }
}
