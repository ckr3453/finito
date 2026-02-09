import 'package:drift/drift.dart';
import 'package:todo_app/data/database/app_database.dart';
import 'package:todo_app/data/database/tables.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Future<List<Category>> getAllCategories() => (select(
    categories,
  )..orderBy([(c) => OrderingTerm.asc(c.sortOrder)])).get();

  Stream<List<Category>> watchAllCategories() => (select(
    categories,
  )..orderBy([(c) => OrderingTerm.asc(c.sortOrder)])).watch();

  Future<int> insertCategory(CategoriesCompanion category) =>
      into(categories).insert(category);

  Future<bool> updateCategory(CategoriesCompanion category) =>
      update(categories).replace(category);

  Future<int> deleteCategory(String id) =>
      (delete(categories)..where((c) => c.id.equals(id))).go();
}
