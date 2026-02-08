# Firestore Task Sync

## 개요

Local-First + Cloud-Synced 아키텍처에서 Task 데이터의 Firestore 양방향 동기화를 구현한다.
UI는 항상 로컬 Drift DB에서 읽고, 백그라운드에서 Firestore와 실시간 동기화한다.

- **범위**: Task만 (Category/Tag 동기화는 별도 Phase)
- **실시간 동기화**: Firestore snapshot listener로 원격 변경 즉시 반영
- **충돌 해결**: Last-Write-Wins (updatedAt 기준)
- **삭제 방식**: Soft delete (deletedAt 필드)

---

## 동작 정의

### Firestore 경로

| 리소스 | 경로 |
|--------|------|
| Task 컬렉션 | `users/{uid}/tasks` |
| Task 문서 | `users/{uid}/tasks/{taskId}` |

### TaskFirestoreDto

Firestore 문서 ↔ TaskEntity 간 변환을 담당하는 DTO.

| 필드 | Firestore 타입 | Dart 타입 | 변환 규칙 |
|------|---------------|-----------|-----------|
| `id` | `string` | `String` | 그대로 |
| `title` | `string` | `String` | 그대로 |
| `description` | `string` | `String` | 그대로 |
| `status` | `string` ("pending" / "completed" / "archived") | `TaskStatus` | enum name ↔ string |
| `priority` | `string` ("high" / "medium" / "low") | `Priority` | enum name ↔ string |
| `categoryId` | `string?` | `String?` | 그대로 |
| `tagIds` | `List<string>` | `List<String>` | 그대로 |
| `dueDate` | `Timestamp?` | `DateTime?` | `Timestamp.toDate()` / `Timestamp.fromDate()` |
| `completedAt` | `Timestamp?` | `DateTime?` | `Timestamp.toDate()` / `Timestamp.fromDate()` |
| `sortOrder` | `number` | `int` | 그대로 |
| `createdAt` | `Timestamp` | `DateTime` | `Timestamp.toDate()` / `Timestamp.fromDate()` |
| `updatedAt` | `Timestamp` | `DateTime` | `Timestamp.toDate()` / `Timestamp.fromDate()` |
| `deletedAt` | `Timestamp?` | `DateTime?` | `Timestamp.toDate()` / `Timestamp.fromDate()` |

메서드:
- `TaskFirestoreDto.fromFirestore(Map<String, dynamic> data)` — Firestore 문서 → DTO
- `TaskFirestoreDto.fromEntity(TaskEntity entity)` — 엔티티 → DTO
- `toFirestore()` → `Map<String, dynamic>` — DTO → Firestore 문서
- `toEntity({required bool isSynced})` → `TaskEntity` — DTO → 엔티티

### Drift 스키마 변경 (v1 → v2)

TaskItems 테이블에 `deletedAt` 컬럼 추가:

```dart
// tables.dart
class TaskItems extends Table {
  // ... 기존 컬럼들 ...
  DateTimeColumn get deletedAt => dateTime().nullable()();
}
```

마이그레이션:
```dart
// app_database.dart
@override
int get schemaVersion => 2;

@override
MigrationStrategy get migration => MigrationStrategy(
  onUpgrade: (m, from, to) async {
    if (from < 2) {
      await m.addColumn(taskItems, taskItems.deletedAt);
    }
  },
);
```

### TaskDao 변경

| 변경 항목 | 설명 |
|-----------|------|
| Soft delete | `deleteTask(id)` → `deletedAt = DateTime.now()`, `isSynced = false` 설정 |
| 필터링 | 모든 조회 쿼리에 `deletedAt IS NULL` 조건 추가 |
| Upsert | `upsertTask(TaskItemsCompanion)` 추가 — 동기화 pull 시 사용 |
| Purge | `purgeDeletedTasks(DateTime before)` — deletedAt이 `before`보다 오래된 항목 물리 삭제 |
| Unsynced 조회 | `getUnsyncedTasks()` — `isSynced = false AND deletedAt IS NULL` OR `isSynced = false AND deletedAt IS NOT NULL` (삭제된 항목도 push 필요) |

### LocalTaskRepository 변경

- `deleteTask()`: 물리 삭제 → soft delete 위임 (TaskDao.deleteTask)
- `updateTask()`: deletedAt 매핑 추가
- `_toEntity()`: deletedAt 매핑 추가
- `_toCompanion()`: deletedAt 매핑 추가
- `upsertTask()` 추가: TaskDao.upsertTask 위임

### FirestoreTaskDataSource

```dart
abstract class FirestoreTaskDataSource {
  /// userId의 모든 Task를 실시간 스트림으로 구독
  Stream<List<TaskFirestoreDto>> watchTasks(String userId);

  /// 단일 Task push (create or update)
  Future<void> setTask(String userId, TaskFirestoreDto dto);

  /// 여러 Task를 배치로 push
  Future<void> batchSetTasks(String userId, List<TaskFirestoreDto> dtos);

  /// Firestore에서 모든 Task를 1회 fetch
  Future<List<TaskFirestoreDto>> fetchAllTasks(String userId);
}
```

구현 클래스: `FirestoreTaskDataSourceImpl`
- `cloud_firestore` 패키지 사용
- `watchTasks()`: `snapshots()` 스트림으로 실시간 변경 수신
- `setTask()`: `set()` with merge (upsert)
- `batchSetTasks()`: `WriteBatch`로 일괄 처리

### ConnectivityService

```dart
abstract class ConnectivityService {
  /// 현재 온라인 여부
  Future<bool> get isOnline;

  /// 연결 상태 변경 스트림
  Stream<bool> get onConnectivityChanged;
}
```

구현 클래스: `ConnectivityServiceImpl`
- `connectivity_plus` 패키지 사용
- `ConnectivityResult.none` → offline, 그 외 → online

### TaskSyncService

핵심 동기화 로직을 담당하는 서비스.

```dart
class TaskSyncService {
  /// 동기화 시작 (로그인 시 호출)
  Future<void> start(String userId);

  /// 동기화 중지 (로그아웃 시 호출)
  void stop();

  /// 수동 동기화 트리거
  Future<void> syncNow();

  /// 미동기화 항목 수 스트림
  Stream<int> get unsyncedCountStream;

  /// 현재 동기화 상태
  Stream<SyncStatus> get statusStream;
}
```

**SyncStatus enum**: `idle`, `syncing`, `error`, `offline`

#### 초기 동기화 (start 호출 시)

1. 로컬의 unsynced 항목을 Firestore에 push
2. Firestore에서 전체 Task fetch
3. LWW 비교 후 로컬 DB upsert
4. 실시간 리스너 시작

#### 실시간 리스너

- Firestore `snapshots()` 구독
- 원격 변경 감지 → LWW 비교 → 로컬 upsert
- 로컬에만 있는 항목(원격에 없는)은 건드리지 않음

#### Push

- 로컬에서 Task CRUD 발생 시 즉시 push 시도
- 성공 시 `isSynced = true`
- 실패 시 `isSynced = false` 유지, 다음 기회에 재시도

#### 온라인 복귀 처리

- ConnectivityService의 onConnectivityChanged 구독
- offline → online 전환 시 `pushUnsyncedChanges()` 호출

### SyncedTaskRepository

`TaskRepository` 인터페이스를 구현하며, 내부적으로 `LocalTaskRepository`와 `TaskSyncService`를 조합.

```dart
class SyncedTaskRepository implements TaskRepository {
  final LocalTaskRepository _local;
  final TaskSyncService _syncService;

  // 읽기 메서드: _local에 위임
  // 쓰기 메서드: _local에 쓴 뒤 _syncService.push() 호출
}
```

| 메서드 | 동작 |
|--------|------|
| `watchAllTasks()` | `_local.watchAllTasks()` 위임 |
| `watchTasksFiltered(...)` | `_local.watchTasksFiltered(...)` 위임 |
| `getTaskById(id)` | `_local.getTaskById(id)` 위임 |
| `createTask(task)` | `_local.createTask(task)` → `_syncService.pushTask(task)` |
| `updateTask(task)` | `_local.updateTask(task)` → `_syncService.pushTask(task)` |
| `deleteTask(id)` | `_local.deleteTask(id)` → `_syncService.pushDeletedTask(id)` |
| `setTagsForTask(...)` | `_local.setTagsForTask(...)` → 해당 task를 push |
| `getTagsForTask(...)` | `_local.getTagsForTask(...)` 위임 |
| `getUnsyncedTasks()` | `_local.getUnsyncedTasks()` 위임 |
| `markSynced(id)` | `_local.markSynced(id)` 위임 |

### Provider 변경

```dart
// connectivity_provider.dart
@Riverpod(keepAlive: true)
ConnectivityService connectivityService(ref) =>
    ConnectivityServiceImpl();

// sync_providers.dart
@Riverpod(keepAlive: true)
TaskSyncService taskSyncService(ref) {
  final localRepo = LocalTaskRepository(ref.watch(appDatabaseProvider));
  final remoteDs = FirestoreTaskDataSourceImpl();
  final connectivity = ref.watch(connectivityServiceProvider);
  return TaskSyncService(
    localRepository: localRepo,
    remoteDataSource: remoteDs,
    connectivityService: connectivity,
  );
}

// repository_providers.dart 변경
@Riverpod(keepAlive: true)
TaskRepository taskRepository(ref) {
  final authState = ref.watch(authStateProvider);
  final localRepo = LocalTaskRepository(ref.watch(appDatabaseProvider));

  if (authState.value != null) {
    // 로그인 상태: SyncedTaskRepository 사용
    final syncService = ref.watch(taskSyncServiceProvider);
    return SyncedTaskRepository(localRepo, syncService);
  }

  // 미로그인: 로컬 전용
  return localRepo;
}
```

### 설정 화면

동기화 섹션 추가 (로그인 상태에서만 표시):

| UI 요소 | 설명 |
|---------|------|
| 동기화 상태 표시 | SyncStatus에 따라 아이콘 + 텍스트 (동기화 완료 / 동기화 중... / 오프라인 / 오류) |
| 수동 동기화 버튼 | `syncNow()` 호출, syncing 중 비활성화 |
| 미동기화 항목 수 | `unsyncedCountStream` 구독, "n개 항목 동기화 대기 중" |

---

## 비즈니스 규칙

### LWW (Last-Write-Wins) 충돌 해결

- `updatedAt` 타임스탬프 비교
- 원격 `updatedAt` > 로컬 `updatedAt` → 원격 데이터로 덮어씀
- 원격 `updatedAt` <= 로컬 `updatedAt` → 로컬 데이터 유지
- 동일 시각(==)인 경우 로컬 유지 (로컬 우선)

### Soft Delete

- `deleteTask()` 호출 시 `deletedAt = DateTime.now()`, `updatedAt` 갱신, `isSynced = false`
- UI 조회 시 `deletedAt IS NULL` 필터 적용 → 삭제된 항목 미노출
- Firestore에도 `deletedAt` 필드 push → 다른 기기에서도 삭제 반영
- 30일 경과된 항목은 purge (물리 삭제) — 앱 시작 시 1회 실행

### 인증 게이트

- **미로그인**: 로컬 전용 모드, TaskSyncService 비활성, LocalTaskRepository 직접 사용
- **로그인**: TaskSyncService.start(userId) 호출, SyncedTaskRepository로 교체
- **로그아웃**: TaskSyncService.stop() 호출, 로컬 데이터 유지 (삭제하지 않음), LocalTaskRepository로 복귀

### 오프라인 처리

- 오프라인 상태에서 모든 CRUD 가능 (로컬 DB)
- 변경된 항목은 `isSynced = false`로 유지
- 온라인 복귀 시 ConnectivityService 이벤트로 감지 → 자동 push
- push 순서: `updatedAt` 오름차순 (오래된 변경부터)

### 에러 처리

| 상황 | 처리 |
|------|------|
| Push 실패 (네트워크) | `isSynced = false` 유지, 다음 온라인 시 자동 재시도 |
| Push 실패 (권한) | 동기화 중지, 사용자에게 재로그인 안내 |
| Pull 파싱 실패 | 해당 문서 skip, 로그 기록, 나머지 계속 처리 |
| 인증 만료 | 동기화 중지, SyncStatus.error, 재인증 유도 |
| Firestore 한도 초과 | 동기화 일시 중지, 사용자 알림 |

---

## 제외 범위

- Category/Tag 동기화 (별도 Phase에서 구현)
- 익명 로그인 (현재 이메일/비밀번호만 지원)
- 서버 타임스탬프 (`FieldValue.serverTimestamp()` 미사용, 클라이언트 시각 사용)
- 페이지네이션 (개인용 앱, 데이터 소량)
- 실시간 협업 (다른 사용자와 공유 미지원)
- 데이터 암호화 (Firestore 전송 중 암호화는 기본 제공)
- 필드 단위 충돌 해결 (문서 단위 LWW만 사용)

---

## 검증 체크리스트

### 기본 동기화 (6항목)
- [ ] 로그인 상태에서 Task 생성 시 Firestore에 즉시 반영되는가
- [ ] 로그인 상태에서 Task 수정 시 Firestore에 즉시 반영되는가
- [ ] 로그인 상태에서 Task 삭제 시 Firestore에 deletedAt이 설정되는가
- [ ] Firestore에서 Task 변경 시 로컬 DB에 반영되는가
- [ ] 다른 기기에서 생성한 Task가 실시간으로 나타나는가
- [ ] isSynced 플래그가 push 성공 후 true로 변경되는가

### 실시간 동기화 (3항목)
- [ ] Firestore snapshot listener가 앱 시작 시 활성화되는가
- [ ] 원격 변경이 UI에 자동으로 반영되는가
- [ ] 로그아웃 시 snapshot listener가 해제되는가

### 오프라인 처리 (4항목)
- [ ] 오프라인에서 Task CRUD가 정상 동작하는가
- [ ] 오프라인에서 변경된 항목의 isSynced가 false인가
- [ ] 온라인 복귀 시 미동기화 항목이 자동 push되는가
- [ ] 온라인 복귀 후 isSynced가 true로 변경되는가

### 충돌 해결 (2항목)
- [ ] 원격 updatedAt > 로컬 updatedAt 시 원격 데이터로 덮어쓰는가
- [ ] 원격 updatedAt <= 로컬 updatedAt 시 로컬 데이터를 유지하는가

### 소프트 삭제 (5항목)
- [ ] deleteTask 호출 시 deletedAt이 설정되는가 (물리 삭제 아님)
- [ ] deletedAt이 설정된 항목이 UI 목록에서 제외되는가
- [ ] 삭제된 항목이 Firestore에 deletedAt과 함께 push되는가
- [ ] 다른 기기에서 삭제한 항목이 로컬에서도 사라지는가
- [ ] 30일 경과된 삭제 항목이 purge되는가

### 인증 연동 (5항목)
- [ ] 미로그인 시 로컬 전용 모드로 동작하는가 (동기화 비활성)
- [ ] 로그인 시 TaskSyncService가 자동 시작되는가
- [ ] 최초 로그인 시 기존 로컬 데이터가 Firestore에 push되는가
- [ ] 로그아웃 시 동기화가 중지되는가 (데이터 유지)
- [ ] 다른 기기에서 로그인 시 Firestore 데이터가 로컬에 pull되는가

### 설정 화면 (3항목)
- [ ] 동기화 상태가 실시간으로 표시되는가 (완료/동기화 중/오프라인/오류)
- [ ] 수동 동기화 버튼이 정상 동작하는가
- [ ] 미동기화 항목 수가 표시되는가

### 스키마 마이그레이션 (3항목)
- [ ] 기존 v1 DB에서 v2로 마이그레이션이 성공하는가
- [ ] 마이그레이션 후 기존 Task 데이터가 보존되는가
- [ ] 새로 설치한 앱에서 v2 스키마로 정상 생성되는가

---

## 관련 문서

- Domain: `domain/task-entity.md`
- Domain: `domain/sync-architecture.md`
- API: `api/firebase-integration.md`
