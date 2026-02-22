import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/data/database/app_database.dart';
import 'package:todo_app/data/repositories/local_category_repository.dart';
import 'package:todo_app/domain/entities/entities.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late LocalCategoryRepository repo;
  final now = DateTime.now();

  setUp(() {
    db = createTestDatabase();
    repo = LocalCategoryRepository(db);
  });

  tearDown(() => db.close());

  CategoryEntity makeCategory({
    String id = 'cat-1',
    String name = 'Work',
    int colorValue = 0xFF4CAF50,
    String iconName = 'folder',
    int sortOrder = 0,
  }) {
    return CategoryEntity(
      id: id,
      name: name,
      colorValue: colorValue,
      iconName: iconName,
      sortOrder: sortOrder,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('createCategory and watchAllCategories', () {
    test('creates a category and emits it in the stream', () async {
      await repo.createCategory(makeCategory());

      final categories = await repo.watchAllCategories().first;

      expect(categories, hasLength(1));
      expect(categories.first.id, 'cat-1');
      expect(categories.first.name, 'Work');
      expect(categories.first.colorValue, 0xFF4CAF50);
      expect(categories.first.iconName, 'folder');
    });

    test('creates multiple categories', () async {
      await repo.createCategory(makeCategory(id: 'cat-1', name: 'Work'));
      await repo.createCategory(makeCategory(id: 'cat-2', name: 'Personal'));

      final categories = await repo.watchAllCategories().first;

      expect(categories, hasLength(2));
    });
  });

  group('updateCategory', () {
    test('updates category fields', () async {
      await repo.createCategory(makeCategory());

      await repo.updateCategory(
        makeCategory(name: 'Updated', colorValue: 0xFFFF0000),
      );

      final categories = await repo.watchAllCategories().first;
      expect(categories.first.name, 'Updated');
      expect(categories.first.colorValue, 0xFFFF0000);
    });
  });

  group('deleteCategory', () {
    test('removes category from stream', () async {
      await repo.createCategory(makeCategory());
      await repo.deleteCategory('cat-1');

      final categories = await repo.watchAllCategories().first;
      expect(categories, isEmpty);
    });
  });
}
