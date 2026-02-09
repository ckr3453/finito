import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/domain/entities/entities.dart';
import 'package:todo_app/presentation/providers/repository_providers.dart';

part 'tag_providers.g.dart';

@riverpod
Stream<List<TagEntity>> tagList(Ref ref) {
  return ref.watch(tagRepositoryProvider).watchAllTags();
}
