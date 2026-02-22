// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connectivityServiceHash() =>
    r'a8630b7da977bea817a66b7615e1a52a2e15c586';

/// See also [connectivityService].
@ProviderFor(connectivityService)
final connectivityServiceProvider = Provider<ConnectivityService>.internal(
  connectivityService,
  name: r'connectivityServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectivityServiceRef = ProviderRef<ConnectivityService>;
String _$firestoreTaskDataSourceHash() =>
    r'44873b9b91c364d7cc3ea348e51117a2a4e80cc3';

/// See also [firestoreTaskDataSource].
@ProviderFor(firestoreTaskDataSource)
final firestoreTaskDataSourceProvider =
    Provider<FirestoreTaskDataSource>.internal(
      firestoreTaskDataSource,
      name: r'firestoreTaskDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$firestoreTaskDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirestoreTaskDataSourceRef = ProviderRef<FirestoreTaskDataSource>;
String _$taskSyncServiceHash() => r'434e7ae3e012d8485189fb8b903258df224a3c65';

/// See also [taskSyncService].
@ProviderFor(taskSyncService)
final taskSyncServiceProvider = Provider<TaskSyncService>.internal(
  taskSyncService,
  name: r'taskSyncServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskSyncServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskSyncServiceRef = ProviderRef<TaskSyncService>;
String _$syncStatusHash() => r'ff8bbe21872d199016b0d4a21861d07aa6a9d3a5';

/// See also [syncStatus].
@ProviderFor(syncStatus)
final syncStatusProvider = AutoDisposeStreamProvider<SyncStatus>.internal(
  syncStatus,
  name: r'syncStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncStatusRef = AutoDisposeStreamProviderRef<SyncStatus>;
String _$unsyncedCountHash() => r'1266e9caec5e1aba776e401cb0a3aba65f7599c0';

/// See also [unsyncedCount].
@ProviderFor(unsyncedCount)
final unsyncedCountProvider = AutoDisposeStreamProvider<int>.internal(
  unsyncedCount,
  name: r'unsyncedCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unsyncedCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnsyncedCountRef = AutoDisposeStreamProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
