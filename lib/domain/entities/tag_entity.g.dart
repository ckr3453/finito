// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TagEntity _$TagEntityFromJson(Map<String, dynamic> json) => _TagEntity(
  id: json['id'] as String,
  name: json['name'] as String,
  colorValue: (json['colorValue'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$TagEntityToJson(_TagEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'colorValue': instance.colorValue,
      'createdAt': instance.createdAt.toIso8601String(),
    };
