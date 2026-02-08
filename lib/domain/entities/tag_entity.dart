import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag_entity.freezed.dart';
part 'tag_entity.g.dart';

@freezed
abstract class TagEntity with _$TagEntity {
  const factory TagEntity({
    required String id,
    required String name,
    required int colorValue,
    required DateTime createdAt,
  }) = _TagEntity;

  factory TagEntity.fromJson(Map<String, dynamic> json) =>
      _$TagEntityFromJson(json);
}
