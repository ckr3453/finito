# Firebase 연동 명세

## 개요

Firebase Spark(무료) 플랜 기반 백엔드 연동 명세. Cloud Functions 미사용 (비용 최적화).

아키텍처는 **Local-First + Cloud-Synced** 패턴을 따른다. UI는 항상 로컬 Drift DB에서 데이터를 읽고, 백그라운드에서 Firestore와 양방향 동기화한다. 충돌 해결은 **Last-Write-Wins (updatedAt)** 전략을 사용한다.

---

## 사용 서비스

### Firebase Authentication

| 항목 | 내용 |
|------|------|
| 패키지 | `firebase_auth ^6.1.4` |
| 이메일/비밀번호 | `createUserWithEmailAndPassword`, `signInWithEmailAndPassword` |
| Google 소셜 로그인 | `GoogleAuthProvider` + `signInWithPopup` (Web) / `signInWithCredential` (Mobile) |
| 익명 로그인 | `signInAnonymously` → 추후 `linkWithCredential`로 계정 연결 가능 |

### Cloud Firestore

| 항목 | 내용 |
|------|------|
| 패키지 | `cloud_firestore ^6.1.2` |
| 실시간 동기화 | `snapshots()` 스트림으로 서버 변경사항 수신 |
| 오프라인 캐시 | Firestore SDK 내장 (별도 설정 불필요) |
| 데이터 저장 | enum을 string으로 저장 (로컬 Drift DB에서는 integer index) |

### 미사용 서비스

| 서비스 | 미사용 사유 |
|--------|------------|
| Cloud Functions | Blaze 플랜 필요 (비용 발생) |
| Firebase Messaging | 알림 기능 제외됨 |
| Firebase Storage | 파일 첨부 기능 없음 |

---

## Firestore 데이터 구조

모든 데이터는 사용자별로 격리된다 (`/users/{userId}/` 하위).

```
/users/{userId}/
  ├── tasks/{taskId}
  │     ├── id: string
  │     ├── title: string
  │     ├── description: string
  │     ├── status: string ("pending" | "completed" | "archived")
  │     ├── priority: string ("high" | "medium" | "low")
  │     ├── categoryId: string?
  │     ├── tagIds: string[]
  │     ├── dueDate: timestamp?
  │     ├── completedAt: timestamp?
  │     ├── sortOrder: number
  │     ├── createdAt: timestamp
  │     └── updatedAt: timestamp
  ├── categories/{categoryId}
  │     ├── id: string
  │     ├── name: string
  │     ├── colorValue: number
  │     ├── iconName: string
  │     ├── sortOrder: number
  │     ├── createdAt: timestamp
  │     └── updatedAt: timestamp
  └── tags/{tagId}
        ├── id: string
        ├── name: string
        ├── colorValue: number
        └── createdAt: timestamp
```

### Firestore vs Drift 타입 매핑

| 필드 | Firestore 타입 | Drift(SQLite) 타입 | 비고 |
|------|---------------|-------------------|------|
| `status` | `string` ("pending") | `integer` (enum index) | 변환 필요 |
| `priority` | `string` ("high") | `integer` (enum index) | 변환 필요 |
| `dueDate` | `Timestamp` | `DateTime` | `Timestamp.toDate()` 사용 |
| `tagIds` | `List<String>` | `TaskTags` 조인 테이블 | 구조 차이 |
| `isSynced` | 미저장 | `boolean` | 로컬 전용 필드 |

---

## Firestore 인덱스

### 복합 인덱스

| 컬렉션 경로 | 필드 1 | 필드 2 |
|------------|--------|--------|
| `users/{userId}/tasks` | `status` (Ascending) | `sortOrder` (Ascending) |
| `users/{userId}/tasks` | `categoryId` (Ascending) | `sortOrder` (Ascending) |
| `users/{userId}/tasks` | `priority` (Ascending) | `sortOrder` (Ascending) |

### firestore.indexes.json

```json
{
  "indexes": [
    {
      "collectionGroup": "tasks",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "sortOrder", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "tasks",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "categoryId", "order": "ASCENDING" },
        { "fieldPath": "sortOrder", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "tasks",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "priority", "order": "ASCENDING" },
        { "fieldPath": "sortOrder", "order": "ASCENDING" }
      ]
    }
  ]
}
```

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

---

## 무료 티어 한도 (Spark 플랜)

| 항목 | 일일 한도 | 개인 사용 예상 | 여유율 |
|------|----------|--------------|--------|
| 저장소 | 1 GiB | ~10 MB | 99% |
| 읽기 | 50,000/일 | ~1,000/일 | 98% |
| 쓰기 | 20,000/일 | ~200/일 | 99% |
| 삭제 | 20,000/일 | ~50/일 | 99.7% |
| Auth | 무제한 (이메일) | - | - |

### 한도 초과 방지 전략

- **배치 쓰기**: 여러 변경사항을 `WriteBatch`로 묶어 한 번에 처리
- **디바운싱**: 빠른 연속 수정 시 마지막 상태만 동기화 (500ms 디바운스)
- **스냅샷 리스너 최소화**: 필요한 컬렉션만 구독, 화면 전환 시 해제
- **오프라인 우선**: 로컬 DB에서 먼저 읽고, 네트워크 요청 최소화

---

## Remote DataSource 인터페이스

### FirestoreTaskDataSource

```dart
abstract class FirestoreTaskDataSource {
  Future<void> createTask(String userId, Map<String, dynamic> taskData);
  Future<Map<String, dynamic>?> getTask(String userId, String taskId);
  Future<void> updateTask(String userId, String taskId, Map<String, dynamic> data);
  Future<void> deleteTask(String userId, String taskId);
  Future<void> batchWrite(String userId, List<Map<String, dynamic>> tasks);
  Stream<List<Map<String, dynamic>>> watchTasks(String userId);
}
```

### FirestoreCategoryDataSource / FirestoreTagDataSource

동일 패턴: CRUD + `Stream<List<Map<String, dynamic>>> watch*(String userId)`

### Firestore 경로 헬퍼

```dart
class FirestorePaths {
  static String tasksCol(String userId) => 'users/$userId/tasks';
  static String taskDoc(String userId, String taskId) => 'users/$userId/tasks/$taskId';
  static String categoriesCol(String userId) => 'users/$userId/categories';
  static String categoryDoc(String userId, String catId) => 'users/$userId/categories/$catId';
  static String tagsCol(String userId) => 'users/$userId/tags';
  static String tagDoc(String userId, String tagId) => 'users/$userId/tags/$tagId';
}
```

---

## 인증 플로우

```
앱 시작
  │
  ▼
authStateChanges() 구독
  │
  ├─ user == null ──► 로컬 전용 모드 (모든 기능 사용 가능, 동기화만 비활성)
  │
  └─ user != null ──► userId 획득 → SyncService 시작 → 로컬 데이터 마이그레이션
```

### 로그아웃 시

- `SyncService.stop()` (스냅샷 리스너 해제)
- 로컬 데이터 유지 (삭제하지 않음)
- 로컬 전용 모드로 전환

### 익명 → 정식 계정 전환

```dart
final credential = EmailAuthProvider.credential(email: email, password: password);
await FirebaseAuth.instance.currentUser!.linkWithCredential(credential);
// userId 유지 → 데이터 마이그레이션 불필요
```

---

## 에러 처리

| 에러 유형 | 처리 방식 |
|----------|----------|
| 네트워크 오프라인 | 로컬 모드로 자동 전환, 재연결 시 동기화 재개 |
| 권한 거부 (`permission-denied`) | 로그아웃 처리 + 재인증 유도 |
| 한도 초과 (`resource-exhausted`) | 동기화 일시 중지 + 사용자 알림 |
| 문서 미존재 (`not-found`) | 로컬에서 삭제 처리 |
| 인증 만료 (`unauthenticated`) | 토큰 갱신 시도 → 실패 시 재로그인 유도 |
