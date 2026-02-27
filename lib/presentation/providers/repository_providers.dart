import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/data/repositories/local_task_repository.dart';
import 'package:todo_app/data/repositories/local_category_repository.dart';
import 'package:todo_app/data/repositories/local_tag_repository.dart';
import 'package:todo_app/data/repositories/synced_task_repository.dart';
import 'package:todo_app/domain/repositories/repositories.dart';
import 'package:todo_app/presentation/providers/auth_provider.dart';
import 'package:todo_app/presentation/providers/database_provider.dart';
import 'package:todo_app/presentation/providers/sync_providers.dart';

part 'repository_providers.g.dart';

@Riverpod(keepAlive: true)
LocalTaskRepository localTaskRepository(Ref ref) {
  return LocalTaskRepository(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
TaskRepository taskRepository(Ref ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) {
    return ref.watch(localTaskRepositoryProvider);
  }
  final db = ref.watch(appDatabaseProvider);
  final syncService = ref.watch(taskSyncServiceProvider);
  db.clearAllData().then((_) => syncService.start(user.uid));
  return SyncedTaskRepository(
    local: ref.watch(localTaskRepositoryProvider),
    syncService: syncService,
  );
}

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) {
  return LocalCategoryRepository(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
TagRepository tagRepository(Ref ref) {
  return LocalTagRepository(ref.watch(appDatabaseProvider));
}
