import 'package:drift/drift.dart';
import 'package:todo_app/data/database/app_database.dart';
import 'package:todo_app/domain/entities/entities.dart';
import 'package:todo_app/domain/repositories/tag_repository.dart';

class LocalTagRepository implements TagRepository {
  final AppDatabase _db;

  LocalTagRepository(this._db);

  // ---------------------------------------------------------------------------
  // Drift Tag -> Domain TagEntity
  // ---------------------------------------------------------------------------
  TagEntity _toEntity(Tag tag) {
    return TagEntity(
      id: tag.id,
      name: tag.name,
      colorValue: tag.colorValue,
      createdAt: tag.createdAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Domain TagEntity -> Drift TagsCompanion
  // ---------------------------------------------------------------------------
  TagsCompanion _toCompanion(TagEntity entity) {
    return TagsCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      colorValue: Value(entity.colorValue),
      createdAt: Value(entity.createdAt),
    );
  }

  // ---------------------------------------------------------------------------
  // TagRepository implementation
  // ---------------------------------------------------------------------------

  @override
  Stream<List<TagEntity>> watchAllTags() {
    return _db.tagDao.watchAllTags().map(
      (tags) => tags.map(_toEntity).toList(),
    );
  }

  @override
  Future<void> createTag(TagEntity tag) async {
    await _db.tagDao.insertTag(_toCompanion(tag));
  }

  @override
  Future<void> updateTag(TagEntity tag) async {
    await _db.tagDao.updateTag(_toCompanion(tag));
  }

  @override
  Future<void> deleteTag(String id) async {
    await _db.tagDao.deleteTag(id);
  }
}
