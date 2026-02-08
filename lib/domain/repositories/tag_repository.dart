import 'package:todo_app/domain/entities/entities.dart';

abstract class TagRepository {
  Stream<List<TagEntity>> watchAllTags();
  Future<void> createTag(TagEntity tag);
  Future<void> updateTag(TagEntity tag);
  Future<void> deleteTag(String id);
}
