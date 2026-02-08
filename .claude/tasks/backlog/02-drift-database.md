# Task 02: Drift 데이터베이스 (테이블 + DAO)

## 의존성
- **Task 01** (도메인 모델) 완료 필요 — enum import 사용

## 목표
Drift SQLite DB 정의: 테이블 4개(tasks, categories, tags, task_tags) + DAO 3개

## 생성할 파일

### 1. `lib/data/database/tables.dart`
모든 Drift 테이블 정의.

```dart
import 'package:drift/drift.dart';

class TaskItems extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 500)();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get status => intEnum<TaskStatusIndex>()();
  IntColumn get priority => intEnum<PriorityIndex>()();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get colorValue => integer()();
  TextColumn get iconName => text().withDefault(const Constant('folder'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get colorValue => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// M:M join table
class TaskTags extends Table {
  TextColumn get taskId => text().references(TaskItems, #id)();
  TextColumn get tagId => text().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {taskId, tagId};
}

```

**주의**: `intEnum`에 사용할 인덱스 enum은 Drift가 자동 생성하지 않으므로, 도메인 enum의 index 값을 Drift 변환기로 매핑하는 방식 사용. 또는 `integer()`로 저장하고 DAO에서 변환.

실제 구현 시 권장 방식: `integer()`로 저장, DAO/Repository에서 `TaskStatus.values[index]`로 변환.

### 2. `lib/data/database/app_database.dart`

```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';
import 'daos/task_dao.dart';
import 'daos/category_dao.dart';
import 'daos/tag_dao.dart';
part 'app_database.g.dart';

@DriftDatabase(
  tables: [TaskItems, Categories, Tags, TaskTags],
  daos: [TaskDao, CategoryDao, TagDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'todo_app.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
```

### 3. `lib/data/database/daos/task_dao.dart`

```dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [TaskItems, TaskTags, Tags])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  // CRUD
  Future<List<TaskItem>> getAllTasks() => select(taskItems).get();

  Stream<List<TaskItem>> watchAllTasks() => select(taskItems).watch();

  Stream<List<TaskItem>> watchTasksByStatus(int status) {
    return (select(taskItems)..where((t) => t.status.equals(status))).watch();
  }

  Future<TaskItem?> getTaskById(String id) {
    return (select(taskItems)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertTask(TaskItemsCompanion task) {
    return into(taskItems).insert(task);
  }

  Future<bool> updateTask(TaskItemsCompanion task) {
    return update(taskItems).replace(task);
  }

  Future<int> deleteTask(String id) {
    return (delete(taskItems)..where((t) => t.id.equals(id))).go();
  }

  // Tag relations
  Future<void> setTagsForTask(String taskId, List<String> tagIds) async {
    await (delete(taskTags)..where((t) => t.taskId.equals(taskId))).go();
    for (final tagId in tagIds) {
      await into(taskTags).insert(TaskTagsCompanion.insert(
        taskId: taskId,
        tagId: tagId,
      ));
    }
  }

  Future<List<Tag>> getTagsForTask(String taskId) {
    final query = select(tags).join([
      innerJoin(taskTags, taskTags.tagId.equalsExp(tags.id)),
    ])..where(taskTags.taskId.equals(taskId));
    return query.map((row) => row.readTable(tags)).get();
  }

  // Search & Filter
  Stream<List<TaskItem>> watchTasksFiltered({
    int? status,
    int? priority,
    String? categoryId,
    String? searchQuery,
  }) {
    final query = select(taskItems);
    if (status != null) query.where((t) => t.status.equals(status));
    if (priority != null) query.where((t) => t.priority.equals(priority));
    if (categoryId != null) query.where((t) => t.categoryId.equals(categoryId));
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where((t) => t.title.contains(searchQuery) | t.description.contains(searchQuery));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return query.watch();
  }

  // Sync support
  Future<List<TaskItem>> getUnsyncedTasks() {
    return (select(taskItems)..where((t) => t.isSynced.equals(false))).get();
  }

  Future<void> markSynced(String id) {
    return (update(taskItems)..where((t) => t.id.equals(id)))
        .write(const TaskItemsCompanion(isSynced: Value(true)));
  }
}
```

### 4. `lib/data/database/daos/category_dao.dart`

```dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase> with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Future<List<Category>> getAllCategories() =>
      (select(categories)..orderBy([(c) => OrderingTerm.asc(c.sortOrder)])).get();

  Stream<List<Category>> watchAllCategories() =>
      (select(categories)..orderBy([(c) => OrderingTerm.asc(c.sortOrder)])).watch();

  Future<int> insertCategory(CategoriesCompanion category) =>
      into(categories).insert(category);

  Future<bool> updateCategory(CategoriesCompanion category) =>
      update(categories).replace(category);

  Future<int> deleteCategory(String id) =>
      (delete(categories)..where((c) => c.id.equals(id))).go();
}
```

### 5. `lib/data/database/daos/tag_dao.dart`

```dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'tag_dao.g.dart';

@DriftAccessor(tables: [Tags])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  TagDao(super.db);

  Future<List<Tag>> getAllTags() => select(tags).get();

  Stream<List<Tag>> watchAllTags() => select(tags).watch();

  Future<int> insertTag(TagsCompanion tag) => into(tags).insert(tag);

  Future<bool> updateTag(TagsCompanion tag) => update(tags).replace(tag);

  Future<int> deleteTag(String id) =>
      (delete(tags)..where((t) => t.id.equals(id))).go();
}
```

## 완료 조건
- 테이블, DAO 파일 모두 작성
- `dart run build_runner build --delete-conflicting-outputs` 성공
- `.g.dart` 파일 생성됨
- 컴파일 에러 없음

## 주의사항
- Drift의 `intEnum`은 Dart enum의 index 값을 사용. 도메인 enum 순서와 일치해야 함
- `status`, `priority`는 `integer()`로 저장 후 변환하는 것이 더 안전할 수 있음
- Task 01 코드가 완료된 상태에서 작업해야 함
- 폴더 `lib/data/database/daos/` 생성 필요

## 참고
- Flutter SDK: `C:/flutter/bin/flutter`
- build_runner: `cd C:/Users/david/todo_app && C:/flutter/bin/dart run build_runner build --delete-conflicting-outputs`
