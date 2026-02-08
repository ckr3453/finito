# Local-First + Cloud-Synced 동기화 아키텍처 명세

## 개요

Local-First 오프라인 우선 동기화 아키텍처 명세.
모든 데이터는 로컬 Drift(SQLite) DB에 우선 저장되며, 네트워크가 가능할 때 Firestore와 동기화한다.
사용자는 오프라인 상태에서도 모든 CRUD 작업을 수행할 수 있고, 온라인 복귀 시 자동으로 동기화된다.

---

## 아키텍처 다이어그램

```
[UI] ←watches→ [Riverpod Providers]
                      |
                 [Repository]
                  /        \
          [Drift DB]    [Firestore]
       (항상 여기서 읽음)  (온라인 시 동기화)
```

### 데이터 흐름 요약

| 방향 | 경로 | 조건 |
|------|------|------|
| 쓰기 | UI → Repository → Drift → SyncService → Firestore | 항상 Drift 먼저, 온라인 시 Firestore push |
| 읽기 | Firestore → SyncService → Drift → Repository → UI | UI는 항상 Drift Stream 구독 |

---

## 쓰기 플로우

```
1. 사용자가 Task 생성/수정/삭제
2. Repository가 Drift DB에 즉시 저장 (isSynced = false)
3. UI 즉시 반영 (Drift Stream으로 구독 중)
4. SyncService가 연결 상태 확인
5. 온라인이면 Firestore에 push
6. 성공 시 isSynced = true로 업데이트
```

### 시퀀스

```
User → UI → Repository → Drift DB (isSynced=false)
                              ↓ (Stream)
                           UI 갱신
                              ↓
                         SyncService
                              ↓ (온라인?)
                         Firestore push
                              ↓ (성공?)
                         Drift DB (isSynced=true)
```

---

## 읽기 플로우

```
1. UI는 항상 Drift DB에서 Stream으로 읽음
2. 앱 시작 시 Firestore 실시간 리스너 연결
3. Firestore 변경 감지 → Drift DB 업데이트 → UI 자동 반영
```

- UI가 Firestore를 직접 읽지 않음
- Drift DB가 단일 진실 공급원 (Single Source of Truth)
- Firestore 변경은 SyncService가 수신하여 Drift에 반영

---

## 충돌 해결

### 전략: Last-Write-Wins (LWW)

- `updatedAt` 타임스탬프 기준
- 동일 Task가 두 기기에서 수정된 경우, `updatedAt`이 더 최신인 것이 이김
- 개인용 앱이므로 복잡한 CRDT 불필요

### 충돌 시나리오

```
기기 A: Task "X" 수정 → updatedAt = 10:00:05
기기 B: Task "X" 수정 → updatedAt = 10:00:03

동기화 시: 기기 A의 버전이 승리 (updatedAt이 더 큼)
```

### 삭제 충돌

- Soft delete (status = archived) 사용 시 충돌 최소화
- Hard delete의 경우: 삭제가 항상 우선 (삭제된 문서는 Firestore에서 제거)

---

## SyncService 설계

### ConnectivityService

```dart
class ConnectivityService {
  // connectivity_plus로 네트워크 상태 모니터링
  Stream<bool> get isOnline;
  Future<bool> checkConnectivity();
}
```

### SyncService

```dart
class SyncService {
  // 앱 시작 시 초기화
  Future<void> initialize(String userId);

  // unsynced 항목 Firestore에 push
  Future<void> pushUnsyncedChanges();

  // Firestore 실시간 리스너 연결
  void startListening(String userId);

  // 리스너 해제
  void stopListening();

  // 수동 동기화 트리거
  Future<void> syncNow();
}
```

### 동기화 타이밍

| 이벤트 | 동작 |
|--------|------|
| 앱 시작 | `pushUnsyncedChanges()` + `startListening()` |
| 네트워크 복귀 | `pushUnsyncedChanges()` |
| 데이터 변경 | 온라인이면 즉시 push, 오프라인이면 `isSynced=false` 유지 |
| 앱 포그라운드 | `syncNow()` |
| 로그아웃 | `stopListening()` |

### 에러 처리

- Push 실패 시: `isSynced = false` 유지, 다음 동기화에서 자동 재시도
- 네트워크 타임아웃: 30초 후 포기, 다음 기회에 재시도
- 인증 만료: FirebaseAuth 재인증 후 재시도

---

## Firebase 인증 연동

### 상태별 동작

| 상태 | Drift DB | Firestore | SyncService |
|------|----------|-----------|-------------|
| 미로그인 | 사용 (로컬 전용) | 미사용 | 비활성 |
| 로그인 | 사용 | 사용 | 활성 |
| 로그아웃 | 데이터 유지 | 리스너 해제 | 비활성 |

### 최초 로그인 시 데이터 마이그레이션

1. 로컬에 기존 데이터가 있는 경우
2. 모든 로컬 데이터를 Firestore에 push (userId 할당)
3. `isSynced = true`로 업데이트
4. 이후 정상 동기화 플로우

### 다른 기기에서 로그인

1. Firestore에서 해당 userId의 모든 데이터 pull
2. Drift DB에 저장
3. 실시간 리스너 연결

---

## Firestore 보안 규칙

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

- 인증된 사용자만 자신의 데이터에 접근 가능
- 다른 사용자의 데이터 접근 불가

---

## 제약 사항 및 트레이드오프

| 항목 | 설명 |
|------|------|
| 실시간 협업 | 미지원 (개인용 앱) |
| 충돌 해결 정밀도 | 필드 단위가 아닌 문서 단위 LWW |
| 오프라인 기간 | 제한 없음 (로컬 DB에 모든 데이터 보관) |
| 초기 동기화 | 전체 컬렉션 pull (데이터 적으므로 문제 없음) |
| 페이지네이션 | 미구현 (개인용 TODO 항목 수가 적으므로 불필요) |
