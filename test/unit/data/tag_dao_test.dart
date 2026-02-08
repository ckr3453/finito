import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/data/database/app_database.dart';
import 'package:todo_app/data/database/daos/tag_dao.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late TagDao dao;

  setUp(() {
    db = createTestDatabase();
    dao = db.tagDao;
  });

  tearDown(() => db.close());

  TagsCompanion makeTag({
    String id = 'tag-1',
    String name = 'urgent',
    int colorValue = 0xFFEF5350,
  }) {
    return TagsCompanion.insert(
      id: id,
      name: name,
      colorValue: colorValue,
      createdAt: DateTime.now(),
    );
  }

  group('CRUD', () {
    test('insert and getAllTags returns the tag', () async {
      await dao.insertTag(makeTag());

      final all = await dao.getAllTags();
      expect(all, hasLength(1));
      expect(all.first.name, 'urgent');
      expect(all.first.colorValue, 0xFFEF5350);
    });

    test('updateTag modifies existing tag', () async {
      await dao.insertTag(makeTag());

      await dao.updateTag(
        TagsCompanion(
          id: const Value('tag-1'),
          name: const Value('important'),
          colorValue: const Value(0xFF42A5F5),
          createdAt: Value(DateTime.now()),
        ),
      );

      final all = await dao.getAllTags();
      expect(all.first.name, 'important');
      expect(all.first.colorValue, 0xFF42A5F5);
    });

    test('deleteTag removes the tag', () async {
      await dao.insertTag(makeTag());
      await dao.deleteTag('tag-1');

      final all = await dao.getAllTags();
      expect(all, isEmpty);
    });

    test('insert multiple tags', () async {
      await dao.insertTag(makeTag(id: 'tag-1', name: 'urgent'));
      await dao.insertTag(makeTag(id: 'tag-2', name: 'work'));
      await dao.insertTag(makeTag(id: 'tag-3', name: 'personal'));

      final all = await dao.getAllTags();
      expect(all, hasLength(3));
    });
  });

  group('watchAllTags stream', () {
    test('emits list containing inserted tag', () async {
      final future = dao.watchAllTags().firstWhere((list) => list.isNotEmpty);

      await dao.insertTag(makeTag());

      final result = await future;
      expect(result, hasLength(1));
      expect(result.first.name, 'urgent');
    });
  });
}
