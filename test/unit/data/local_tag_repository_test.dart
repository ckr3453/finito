import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/data/database/app_database.dart';
import 'package:todo_app/data/repositories/local_tag_repository.dart';
import 'package:todo_app/domain/entities/entities.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late LocalTagRepository repo;
  final now = DateTime.now();

  setUp(() {
    db = createTestDatabase();
    repo = LocalTagRepository(db);
  });

  tearDown(() => db.close());

  TagEntity makeTag({
    String id = 'tag-1',
    String name = 'Urgent',
    int colorValue = 0xFFEF5350,
  }) {
    return TagEntity(
      id: id,
      name: name,
      colorValue: colorValue,
      createdAt: now,
    );
  }

  group('createTag and watchAllTags', () {
    test('creates a tag and emits it in the stream', () async {
      await repo.createTag(makeTag());

      final tags = await repo.watchAllTags().first;

      expect(tags, hasLength(1));
      expect(tags.first.id, 'tag-1');
      expect(tags.first.name, 'Urgent');
      expect(tags.first.colorValue, 0xFFEF5350);
    });

    test('creates multiple tags', () async {
      await repo.createTag(makeTag(id: 'tag-1', name: 'Urgent'));
      await repo.createTag(makeTag(id: 'tag-2', name: 'Important'));

      final tags = await repo.watchAllTags().first;

      expect(tags, hasLength(2));
    });
  });

  group('updateTag', () {
    test('updates tag fields', () async {
      await repo.createTag(makeTag());

      await repo.updateTag(makeTag(name: 'Updated', colorValue: 0xFF42A5F5));

      final tags = await repo.watchAllTags().first;
      expect(tags.first.name, 'Updated');
      expect(tags.first.colorValue, 0xFF42A5F5);
    });
  });

  group('deleteTag', () {
    test('removes tag from stream', () async {
      await repo.createTag(makeTag());
      await repo.deleteTag('tag-1');

      final tags = await repo.watchAllTags().first;
      expect(tags, isEmpty);
    });
  });
}
