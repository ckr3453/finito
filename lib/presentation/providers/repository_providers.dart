import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/data/repositories/local_task_repository.dart';
import 'package:todo_app/data/repositories/local_category_repository.dart';
import 'package:todo_app/data/repositories/local_tag_repository.dart';
import 'package:todo_app/domain/repositories/repositories.dart';
import 'package:todo_app/presentation/providers/database_provider.dart';

part 'repository_providers.g.dart';

@Riverpod(keepAlive: true)
TaskRepository taskRepository(Ref ref) {
  return LocalTaskRepository(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) {
  return LocalCategoryRepository(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
TagRepository tagRepository(Ref ref) {
  return LocalTagRepository(ref.watch(appDatabaseProvider));
}
