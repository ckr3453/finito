import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/data/database/app_database.dart';
import 'package:todo_app/data/database/daos/category_dao.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late CategoryDao dao;

  setUp(() {
    db = createTestDatabase();
    dao = db.categoryDao;
  });

  tearDown(() => db.close());

  CategoriesCompanion makeCategory({
    String id = 'cat-1',
    String name = 'Work',
    int colorValue = 0xFF4CAF50,
    int sortOrder = 0,
  }) {
    final now = DateTime.now();
    return CategoriesCompanion.insert(
      id: id,
      name: name,
      colorValue: colorValue,
      sortOrder: Value(sortOrder),
      createdAt: now,
      updatedAt: now,
    );
  }

  group('CRUD', () {
    test('insert and getAllCategories returns the category', () async {
      await dao.insertCategory(makeCategory());

      final all = await dao.getAllCategories();
      expect(all, hasLength(1));
      expect(all.first.name, 'Work');
    });

    test('updateCategory modifies existing category', () async {
      await dao.insertCategory(makeCategory());
      final now = DateTime.now();

      await dao.updateCategory(
        CategoriesCompanion(
          id: const Value('cat-1'),
          name: const Value('Personal'),
          colorValue: const Value(0xFF2196F3),
          iconName: const Value('person'),
          sortOrder: const Value(1),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      final all = await dao.getAllCategories();
      expect(all.first.name, 'Personal');
      expect(all.first.iconName, 'person');
    });

    test('deleteCategory removes the category', () async {
      await dao.insertCategory(makeCategory());
      await dao.deleteCategory('cat-1');

      final all = await dao.getAllCategories();
      expect(all, isEmpty);
    });
  });

  group('sortOrder', () {
    test('getAllCategories returns sorted by sortOrder', () async {
      await dao.insertCategory(makeCategory(id: 'c', sortOrder: 2));
      await dao.insertCategory(makeCategory(id: 'a', sortOrder: 0));
      await dao.insertCategory(makeCategory(id: 'b', sortOrder: 1));

      final all = await dao.getAllCategories();
      expect(all.map((c) => c.id).toList(), ['a', 'b', 'c']);
    });
  });

  group('watchAllCategories stream', () {
    test('emits list containing inserted category', () async {
      final future = dao.watchAllCategories().firstWhere(
        (list) => list.isNotEmpty,
      );

      await dao.insertCategory(makeCategory());

      final result = await future;
      expect(result, hasLength(1));
      expect(result.first.name, 'Work');
    });
  });
}
