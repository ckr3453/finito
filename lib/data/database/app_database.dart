import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:todo_app/data/database/tables.dart';
import 'package:todo_app/data/database/daos/task_dao.dart';
import 'package:todo_app/data/database/daos/category_dao.dart';
import 'package:todo_app/data/database/daos/tag_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [TaskItems, Categories, Tags, TaskTags],
  daos: [TaskDao, CategoryDao, TagDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

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

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'todo_app.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
