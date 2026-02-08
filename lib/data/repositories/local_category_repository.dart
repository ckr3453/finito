import 'package:drift/drift.dart';
import 'package:todo_app/data/database/app_database.dart';
import 'package:todo_app/domain/entities/entities.dart';
import 'package:todo_app/domain/repositories/category_repository.dart';

class LocalCategoryRepository implements CategoryRepository {
  final AppDatabase _db;

  LocalCategoryRepository(this._db);

  // ---------------------------------------------------------------------------
  // Drift Category -> Domain CategoryEntity
  // ---------------------------------------------------------------------------
  CategoryEntity _toEntity(Category category) {
    return CategoryEntity(
      id: category.id,
      name: category.name,
      colorValue: category.colorValue,
      iconName: category.iconName,
      sortOrder: category.sortOrder,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Domain CategoryEntity -> Drift CategoriesCompanion
  // ---------------------------------------------------------------------------
  CategoriesCompanion _toCompanion(CategoryEntity entity) {
    return CategoriesCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      colorValue: Value(entity.colorValue),
      iconName: Value(entity.iconName),
      sortOrder: Value(entity.sortOrder),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }

  // ---------------------------------------------------------------------------
  // CategoryRepository implementation
  // ---------------------------------------------------------------------------

  @override
  Stream<List<CategoryEntity>> watchAllCategories() {
    return _db.categoryDao.watchAllCategories().map(
      (categories) => categories.map(_toEntity).toList(),
    );
  }

  @override
  Future<void> createCategory(CategoryEntity category) async {
    await _db.categoryDao.insertCategory(_toCompanion(category));
  }

  @override
  Future<void> updateCategory(CategoryEntity category) async {
    await _db.categoryDao.updateCategory(_toCompanion(category));
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _db.categoryDao.deleteCategory(id);
  }
}
