# Task 03: Repository 레이어 (인터페이스 + 로컬 구현)

## 의존성
- **Task 01** (도메인 모델) 완료 필요
- **Task 02** (Drift DB) 완료 필요

## 목표
도메인 리포지토리 인터페이스 정의 + Drift 기반 로컬 구현체 작성. Drift 생성 클래스 ↔ 도메인 엔티티 변환 포함.

## 생성할 파일

### 1. `lib/domain/repositories/task_repository.dart`
```dart
import 'package:todo_app/domain/entities/entities.dart';
import 'package:todo_app/domain/enums/enums.dart';

abstract class TaskRepository {
  Stream<List<TaskEntity>> watchAllTasks();
  Stream<List<TaskEntity>> watchTasksFiltered({
    TaskStatus? status,
    Priority? priority,
    String? categoryId,
    String? searchQuery,
  });
  Future<TaskEntity?> getTaskById(String id);
  Future<void> createTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String id);
  Future<void> setTagsForTask(String taskId, List<String> tagIds);
  Future<List<TagEntity>> getTagsForTask(String taskId);
  Future<List<TaskEntity>> getUnsyncedTasks();
  Future<void> markSynced(String id);
}
```

### 2. `lib/domain/repositories/category_repository.dart`
```dart
import 'package:todo_app/domain/entities/entities.dart';

abstract class CategoryRepository {
  Stream<List<CategoryEntity>> watchAllCategories();
  Future<void> createCategory(CategoryEntity category);
  Future<void> updateCategory(CategoryEntity category);
  Future<void> deleteCategory(String id);
}
```

### 3. `lib/domain/repositories/tag_repository.dart`
```dart
import 'package:todo_app/domain/entities/entities.dart';

abstract class TagRepository {
  Stream<List<TagEntity>> watchAllTags();
  Future<void> createTag(TagEntity tag);
  Future<void> updateTag(TagEntity tag);
  Future<void> deleteTag(String id);
}
```

### 4. `lib/domain/repositories/repositories.dart` (barrel export)
```dart
export 'task_repository.dart';
export 'category_repository.dart';
export 'tag_repository.dart';
```

### 5. `lib/data/repositories/local_task_repository.dart`
Drift DAO를 사용하여 TaskRepository 구현. Drift 생성 클래스(TaskItem) ↔ 도메인 엔티티(TaskEntity) 변환 로직 포함.

변환 헬퍼:
- `TaskItem` → `TaskEntity`: status/priority를 index에서 enum으로
- `TaskEntity` → `TaskItemsCompanion`: enum을 index로

### 6. `lib/data/repositories/local_category_repository.dart`
### 7. `lib/data/repositories/local_tag_repository.dart`

각각 CategoryDao, TagDao를 감싸서 도메인 인터페이스 구현.

## 변환 로직 핵심

```dart
// Drift TaskItem → Domain TaskEntity
TaskEntity _toEntity(TaskItem item, List<TagEntity> tags) {
  return TaskEntity(
    id: item.id,
    title: item.title,
    description: item.description,
    status: TaskStatus.values[item.status],
    priority: Priority.values[item.priority],
    categoryId: item.categoryId,
    tagIds: tags.map((t) => t.id).toList(),
    dueDate: item.dueDate,
    completedAt: item.completedAt,
    sortOrder: item.sortOrder,
    createdAt: item.createdAt,
    updatedAt: item.updatedAt,
    isSynced: item.isSynced,
  );
}

// Domain TaskEntity → Drift Companion
TaskItemsCompanion _toCompanion(TaskEntity entity) {
  return TaskItemsCompanion(
    id: Value(entity.id),
    title: Value(entity.title),
    description: Value(entity.description),
    status: Value(entity.status.index),
    priority: Value(entity.priority.index),
    categoryId: Value(entity.categoryId),
    dueDate: Value(entity.dueDate),
    completedAt: Value(entity.completedAt),
    sortOrder: Value(entity.sortOrder),
    createdAt: Value(entity.createdAt),
    updatedAt: Value(entity.updatedAt),
    isSynced: Value(entity.isSynced),
  );
}
```

## 완료 조건
- 모든 인터페이스 + 구현 파일 작성
- Task/Category/Tag 변환 로직 동작
- 컴파일 에러 없음

## 참고
- Drift가 생성하는 클래스명: `TaskItem` (테이블명 TaskItems에서), `Category`, `Tag`
- `TaskItemsCompanion`, `CategoriesCompanion` 등 Companion 클래스 사용
