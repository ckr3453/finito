# Task 05: Riverpod Providers

## 의존성
- **Task 01** (도메인 모델)
- **Task 02** (Drift DB)
- **Task 03** (Repository)

## 목표
Riverpod providers 정의: DB 인스턴스, Repository, Task/Category/Tag 상태, 필터/검색 상태.
riverpod_annotation 스타일 (@riverpod) 사용.

## 생성할 파일

### 1. `lib/presentation/providers/database_provider.dart`
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/data/database/app_database.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
}
```

### 2. `lib/presentation/providers/repository_providers.dart`
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/data/repositories/local_task_repository.dart';
import 'package:todo_app/data/repositories/local_category_repository.dart';
import 'package:todo_app/data/repositories/local_tag_repository.dart';
import 'package:todo_app/domain/repositories/repositories.dart';
import 'database_provider.dart';

part 'repository_providers.g.dart';

@Riverpod(keepAlive: true)
TaskRepository taskRepository(ref) {
  return LocalTaskRepository(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(ref) {
  return LocalCategoryRepository(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
TagRepository tagRepository(ref) {
  return LocalTagRepository(ref.watch(appDatabaseProvider));
}
```

### 3. `lib/presentation/providers/task_providers.dart`
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/domain/entities/entities.dart';
import 'package:todo_app/domain/enums/enums.dart';
import 'repository_providers.dart';
import 'filter_providers.dart';

part 'task_providers.g.dart';

@riverpod
Stream<List<TaskEntity>> taskList(ref) {
  final repo = ref.watch(taskRepositoryProvider);
  final filter = ref.watch(taskFilterProvider);
  return repo.watchTasksFiltered(
    status: filter.status,
    priority: filter.priority,
    categoryId: filter.categoryId,
    searchQuery: filter.searchQuery,
  );
}

@riverpod
Future<TaskEntity?> taskDetail(ref, String taskId) {
  return ref.watch(taskRepositoryProvider).getTaskById(taskId);
}

@riverpod
Future<List<TagEntity>> taskTags(ref, String taskId) {
  return ref.watch(taskRepositoryProvider).getTagsForTask(taskId);
}
```

### 4. `lib/presentation/providers/category_providers.dart`
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/domain/entities/entities.dart';
import 'repository_providers.dart';

part 'category_providers.g.dart';

@riverpod
Stream<List<CategoryEntity>> categoryList(ref) {
  return ref.watch(categoryRepositoryProvider).watchAllCategories();
}
```

### 5. `lib/presentation/providers/tag_providers.dart`
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/domain/entities/entities.dart';
import 'repository_providers.dart';

part 'tag_providers.g.dart';

@riverpod
Stream<List<TagEntity>> tagList(ref) {
  return ref.watch(tagRepositoryProvider).watchAllTags();
}
```

### 6. `lib/presentation/providers/filter_providers.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:todo_app/domain/enums/enums.dart';

part 'filter_providers.freezed.dart';

@freezed
abstract class TaskFilter with _$TaskFilter {
  const factory TaskFilter({
    TaskStatus? status,
    Priority? priority,
    String? categoryId,
    String? searchQuery,
  }) = _TaskFilter;
}

class TaskFilterNotifier extends StateNotifier<TaskFilter> {
  TaskFilterNotifier() : super(const TaskFilter());

  void setStatus(TaskStatus? status) => state = state.copyWith(status: status);
  void setPriority(Priority? priority) => state = state.copyWith(priority: priority);
  void setCategoryId(String? id) => state = state.copyWith(categoryId: id);
  void setSearchQuery(String? query) => state = state.copyWith(searchQuery: query);
  void clearAll() => state = const TaskFilter();
}

final taskFilterProvider = StateNotifierProvider<TaskFilterNotifier, TaskFilter>(
  (ref) => TaskFilterNotifier(),
);
```

### 7. `lib/presentation/providers/theme_provider.dart`
```dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

@Riverpod(keepAlive: true)
class ThemeMode_ extends _$ThemeMode_ {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() => ThemeMode.system;

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, mode.index);
  }

  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_key);
    if (index != null && index < ThemeMode.values.length) {
      state = ThemeMode.values[index];
    }
  }
}
```

## 완료 조건
- 모든 Provider 파일 작성
- `dart run build_runner build --delete-conflicting-outputs` 성공
- `.g.dart` 파일 생성됨
- 컴파일 에러 없음

## 주의사항
- riverpod_annotation 2.x에서 함수형 provider의 첫 파라미터는 `ref` (타입 명시 불필요)
- `@Riverpod(keepAlive: true)` = 앱 수명 동안 유지
- `@riverpod` = autoDispose
- ThemeMode_ 이름의 trailing underscore는 `ThemeMode`와의 충돌 방지 (riverpod_generator가 `themeModeProvider` 생성)
