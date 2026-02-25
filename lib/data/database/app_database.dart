import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(taskItems, taskItems.deletedAt);
      }
      if (from < 3) {
        await m.addColumn(taskItems, taskItems.reminderTime);
      }
    },
  );

  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(taskTags).go();
      await delete(taskItems).go();
      await delete(tags).go();
      await delete(categories).go();
    });
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'todo_app',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}
