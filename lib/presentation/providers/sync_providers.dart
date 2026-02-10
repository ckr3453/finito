import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/data/datasources/remote/firestore_task_datasource.dart';
import 'package:todo_app/presentation/providers/repository_providers.dart';
import 'package:todo_app/services/connectivity_service.dart';
import 'package:todo_app/services/connectivity_service_impl.dart';
import 'package:todo_app/services/task_sync_service.dart';

part 'sync_providers.g.dart';

@Riverpod(keepAlive: true)
ConnectivityService connectivityService(Ref ref) {
  return ConnectivityServiceImpl(Connectivity());
}

@Riverpod(keepAlive: true)
FirestoreTaskDataSource firestoreTaskDataSource(Ref ref) {
  return FirestoreTaskDataSourceImpl(FirebaseFirestore.instance);
}

@Riverpod(keepAlive: true)
TaskSyncService taskSyncService(Ref ref) {
  final service = TaskSyncService(
    repository: ref.watch(localTaskRepositoryProvider),
    remoteDataSource: ref.watch(firestoreTaskDataSourceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  );
  ref.onDispose(service.stop);
  return service;
}
