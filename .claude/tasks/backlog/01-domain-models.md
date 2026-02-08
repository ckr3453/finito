# Task 01: Freezed 도메인 모델 + Enums 정의

## 의존성
- 없음 (독립 실행 가능)

## 목표
`lib/domain/` 하위에 Freezed 엔티티와 enum 정의. 이후 Drift DB, Repository, Provider가 모두 이 모델을 참조함.

## 생성할 파일

### 1. `lib/domain/enums/task_status.dart`
```dart
enum TaskStatus {
  pending,
  completed,
  archived;
}
```

### 2. `lib/domain/enums/priority.dart`
```dart
enum Priority {
  high,
  medium,
  low;
}
```

### 3. `lib/domain/enums/enums.dart` (barrel export)
```dart
export 'task_status.dart';
export 'priority.dart';
```

### 4. `lib/domain/entities/task_entity.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:todo_app/domain/enums/enums.dart';

part 'task_entity.freezed.dart';
part 'task_entity.g.dart';

@freezed
abstract class TaskEntity with _$TaskEntity {
  const factory TaskEntity({
    required String id,
    required String title,
    @Default('') String description,
    @Default(TaskStatus.pending) TaskStatus status,
    @Default(Priority.medium) Priority priority,
    String? categoryId,
    @Default([]) List<String> tagIds,
    DateTime? dueDate,
    DateTime? completedAt,
    @Default(0) int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isSynced,
  }) = _TaskEntity;

  factory TaskEntity.fromJson(Map<String, dynamic> json) =>
      _$TaskEntityFromJson(json);
}
```

### 5. `lib/domain/entities/category_entity.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_entity.freezed.dart';
part 'category_entity.g.dart';

@freezed
abstract class CategoryEntity with _$CategoryEntity {
  const factory CategoryEntity({
    required String id,
    required String name,
    required int colorValue,
    @Default('folder') String iconName,
    @Default(0) int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CategoryEntity;

  factory CategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$CategoryEntityFromJson(json);
}
```

### 6. `lib/domain/entities/tag_entity.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag_entity.freezed.dart';
part 'tag_entity.g.dart';

@freezed
abstract class TagEntity with _$TagEntity {
  const factory TagEntity({
    required String id,
    required String name,
    required int colorValue,
    required DateTime createdAt,
  }) = _TagEntity;

  factory TagEntity.fromJson(Map<String, dynamic> json) =>
      _$TagEntityFromJson(json);
}
```

### 7. `lib/domain/entities/entities.dart` (barrel export)
```dart
export 'task_entity.dart';
export 'category_entity.dart';
export 'tag_entity.dart';
```

## 완료 조건
- 모든 파일 작성 완료
- `dart run build_runner build --delete-conflicting-outputs` 성공
- `.freezed.dart`, `.g.dart` 파일이 생성됨
- 컴파일 에러 없음

## 참고
- Flutter SDK 경로: `C:/flutter/bin/flutter`
- build_runner 실행: `C:/flutter/bin/dart run build_runner build --delete-conflicting-outputs`
- 프로젝트 루트: `C:/Users/david/todo_app`
