import 'package:todo_app/domain/entities/entities.dart';

abstract class CategoryRepository {
  Stream<List<CategoryEntity>> watchAllCategories();
  Future<void> createCategory(CategoryEntity category);
  Future<void> updateCategory(CategoryEntity category);
  Future<void> deleteCategory(String id);
}
