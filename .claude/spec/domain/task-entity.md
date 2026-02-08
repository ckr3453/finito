# TODO App 데이터 모델 명세

## Overview

Cross-platform TODO app의 핵심 데이터 모델 명세.
Offline-first 아키텍처를 지원하며, 로컬 Drift(SQLite) 저장소를 UI의 단일 진실 공급원(source of truth)으로 사용하고 Firestore와 동기화한다.

---

## Entities

### TaskEntity

TODO 앱의 핵심 엔티티. 사용자가 생성하는 개별 할 일 항목을 나타낸다.

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|:----:|--------|------|
| `id` | `String` | O | UUID v4 자동생성 | 고유 식별자 |
| `title` | `String` | O | - | 할 일 제목 (최대 500자) |
| `description` | `String` | X | `''` | 상세 설명 |
| `status` | `TaskStatus` | O | `pending` | 작업 상태 (enum) |
| `priority` | `Priority` | O | `medium` | 우선순위 (enum) |
| `categoryId` | `String?` | X | `null` | 카테고리 FK (CategoryEntity.id) |
| `tagIds` | `List<String>` | X | `[]` | 연결된 태그 ID 목록 (M:M, TaskTags join table 경유) |
| `dueDate` | `DateTime?` | X | `null` | 마감일 |
| `completedAt` | `DateTime?` | X | `null` | 완료 시각 (status가 completed일 때 설정) |
| `sortOrder` | `int` | O | `0` | 정렬 순서 (낮을수록 상위) |
| `createdAt` | `DateTime` | O | 생성 시각 | 레코드 생성 시각 |
| `updatedAt` | `DateTime` | O | 생성 시각 | 최종 수정 시각 |
| `isSynced` | `bool` | O | `false` | Firestore 동기화 여부 |

#### TaskStatus Enum

| 값 | 설명 |
|----|------|
| `pending` | 미완료 (기본 상태) |
| `completed` | 완료됨 |
| `archived` | 보관됨 (soft delete) |

#### Priority Enum

| 값 | 설명 |
|----|------|
| `high` | 높음 |
| `medium` | 보통 (기본값) |
| `low` | 낮음 |

---

### CategoryEntity

할 일을 분류하는 카테고리. 하나의 Task는 최대 하나의 Category에 속할 수 있다.

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|:----:|--------|------|
| `id` | `String` | O | UUID v4 자동생성 | 고유 식별자 |
| `name` | `String` | O | - | 카테고리 이름 (최대 100자) |
| `colorValue` | `int` | O | - | 색상 값 (`0xAARRGGBB` 형식) |
| `iconName` | `String` | O | `'folder'` | Material Icon 이름 |
| `sortOrder` | `int` | O | `0` | 정렬 순서 (낮을수록 상위) |
| `createdAt` | `DateTime` | O | 생성 시각 | 레코드 생성 시각 |
| `updatedAt` | `DateTime` | O | 생성 시각 | 최종 수정 시각 |

---

### TagEntity

할 일에 부착하는 태그. 하나의 Task에 여러 Tag를 붙일 수 있고, 하나의 Tag가 여러 Task에 사용될 수 있다.

| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|:----:|--------|------|
| `id` | `String` | O | UUID v4 자동생성 | 고유 식별자 |
| `name` | `String` | O | - | 태그 이름 (최대 50자) |
| `colorValue` | `int` | O | - | 색상 값 (`0xAARRGGBB` 형식) |
| `createdAt` | `DateTime` | O | 생성 시각 | 레코드 생성 시각 |

---

### TaskTags (Join Table)

Task와 Tag 간 다대다(M:M) 관계를 위한 중간 테이블.

| 필드 | 타입 | 필수 | 설명 |
|------|------|:----:|------|
| `taskId` | `String` | O | TaskEntity.id (FK, CASCADE DELETE) |
| `tagId` | `String` | O | TagEntity.id (FK, CASCADE DELETE) |

- **복합 기본키**: (`taskId`, `tagId`)
- Task 또는 Tag 삭제 시 관련 TaskTags 레코드도 함께 삭제된다 (CASCADE).

---

## Relationships

```
TaskEntity ──── M:1 ────► CategoryEntity
    │                        (categoryId FK)
    │
    ├──── M:M ────► TagEntity
    │   (TaskTags join table: taskId + tagId)
```

| 관계 | 타입 | 설명 |
|------|------|------|
| Task → Category | Many-to-One | 하나의 Task는 최대 하나의 Category에 속함. `categoryId` FK로 참조. nullable이므로 카테고리 미지정 가능. |
| Task ↔ Tag | Many-to-Many | TaskTags join table을 통해 연결. 하나의 Task에 여러 Tag, 하나의 Tag에 여러 Task 가능. |

---

## Storage

### Local Storage (Drift / SQLite)

UI의 **단일 진실 공급원(Single Source of Truth)**. 모든 읽기/쓰기는 로컬 DB를 통해 수행된다.

| 테이블 | 대응 Entity |
|--------|-------------|
| `tasks` | TaskEntity |
| `categories` | CategoryEntity |
| `tags` | TagEntity |
| `task_tags` | TaskTags (join table) |

### Remote Storage (Firestore)

동기화 대상 원격 저장소. 사용자별 컬렉션으로 분리된다.

| Firestore 경로 | 대응 Entity |
|-----------------|-------------|
| `/users/{userId}/tasks/{taskId}` | TaskEntity |
| `/users/{userId}/categories/{categoryId}` | CategoryEntity |
| `/users/{userId}/tags/{tagId}` | TagEntity |

> **참고**: TaskTags 관계는 Firestore에서 별도 컬렉션 대신 TaskEntity 문서 내 `tagIds` 배열 필드로 저장한다 (비정규화).

---

## Sync Fields

Offline-first 동기화를 위한 필드 설명.

| 필드 | 위치 | 역할 |
|------|------|------|
| `isSynced` | TaskEntity | 로컬 변경 사항이 Firestore에 반영되었는지 여부. `false`이면 아직 push되지 않은 상태. |
| `updatedAt` | TaskEntity, CategoryEntity | **Last-Write-Wins (LWW)** 충돌 해결에 사용. 동기화 시 `updatedAt`이 더 최신인 쪽이 승리. |

### 동기화 흐름

1. **로컬 쓰기**: 데이터 변경 시 `isSynced = false`, `updatedAt = DateTime.now()` 설정
2. **Push**: `isSynced == false`인 레코드를 Firestore에 업로드
3. **Push 성공**: `isSynced = true`로 갱신
4. **Pull**: Firestore 변경 사항 수신 시 `updatedAt` 비교 후 LWW 적용
5. **충돌 해결**: 양쪽 모두 변경된 경우 `updatedAt`이 더 큰(최신) 쪽을 채택

---

## Validation Rules

| Entity | 필드 | 규칙 |
|--------|------|------|
| TaskEntity | `title` | 빈 문자열 불가, 최대 500자 |
| TaskEntity | `completedAt` | `status == completed`일 때만 non-null |
| CategoryEntity | `name` | 빈 문자열 불가, 최대 100자 |
| TagEntity | `name` | 빈 문자열 불가, 최대 50자 |
| 공통 | `id` | UUID v4 형식 |
| 공통 | `colorValue` | `0xAARRGGBB` 형식의 32비트 정수 |
