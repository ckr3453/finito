// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskListHash() => r'e077160398fd10e2ffee66829304ddb88d1a4164';

/// See also [taskList].
@ProviderFor(taskList)
final taskListProvider = AutoDisposeStreamProvider<List<TaskEntity>>.internal(
  taskList,
  name: r'taskListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskListRef = AutoDisposeStreamProviderRef<List<TaskEntity>>;
String _$taskDetailHash() => r'109a3aa8e8b2116910f3cf1ba41fbd21a1638958';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [taskDetail].
@ProviderFor(taskDetail)
const taskDetailProvider = TaskDetailFamily();

/// See also [taskDetail].
class TaskDetailFamily extends Family<AsyncValue<TaskEntity?>> {
  /// See also [taskDetail].
  const TaskDetailFamily();

  /// See also [taskDetail].
  TaskDetailProvider call(String taskId) {
    return TaskDetailProvider(taskId);
  }

  @override
  TaskDetailProvider getProviderOverride(
    covariant TaskDetailProvider provider,
  ) {
    return call(provider.taskId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'taskDetailProvider';
}

/// See also [taskDetail].
class TaskDetailProvider extends AutoDisposeFutureProvider<TaskEntity?> {
  /// See also [taskDetail].
  TaskDetailProvider(String taskId)
    : this._internal(
        (ref) => taskDetail(ref as TaskDetailRef, taskId),
        from: taskDetailProvider,
        name: r'taskDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$taskDetailHash,
        dependencies: TaskDetailFamily._dependencies,
        allTransitiveDependencies: TaskDetailFamily._allTransitiveDependencies,
        taskId: taskId,
      );

  TaskDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.taskId,
  }) : super.internal();

  final String taskId;

  @override
  Override overrideWith(
    FutureOr<TaskEntity?> Function(TaskDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TaskDetailProvider._internal(
        (ref) => create(ref as TaskDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        taskId: taskId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<TaskEntity?> createElement() {
    return _TaskDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskDetailProvider && other.taskId == taskId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, taskId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TaskDetailRef on AutoDisposeFutureProviderRef<TaskEntity?> {
  /// The parameter `taskId` of this provider.
  String get taskId;
}

class _TaskDetailProviderElement
    extends AutoDisposeFutureProviderElement<TaskEntity?>
    with TaskDetailRef {
  _TaskDetailProviderElement(super.provider);

  @override
  String get taskId => (origin as TaskDetailProvider).taskId;
}

String _$taskTagsHash() => r'4135d926bba9b0ff00a84bfb2c15cb4cb528cc60';

/// See also [taskTags].
@ProviderFor(taskTags)
const taskTagsProvider = TaskTagsFamily();

/// See also [taskTags].
class TaskTagsFamily extends Family<AsyncValue<List<TagEntity>>> {
  /// See also [taskTags].
  const TaskTagsFamily();

  /// See also [taskTags].
  TaskTagsProvider call(String taskId) {
    return TaskTagsProvider(taskId);
  }

  @override
  TaskTagsProvider getProviderOverride(covariant TaskTagsProvider provider) {
    return call(provider.taskId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'taskTagsProvider';
}

/// See also [taskTags].
class TaskTagsProvider extends AutoDisposeFutureProvider<List<TagEntity>> {
  /// See also [taskTags].
  TaskTagsProvider(String taskId)
    : this._internal(
        (ref) => taskTags(ref as TaskTagsRef, taskId),
        from: taskTagsProvider,
        name: r'taskTagsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$taskTagsHash,
        dependencies: TaskTagsFamily._dependencies,
        allTransitiveDependencies: TaskTagsFamily._allTransitiveDependencies,
        taskId: taskId,
      );

  TaskTagsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.taskId,
  }) : super.internal();

  final String taskId;

  @override
  Override overrideWith(
    FutureOr<List<TagEntity>> Function(TaskTagsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TaskTagsProvider._internal(
        (ref) => create(ref as TaskTagsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        taskId: taskId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TagEntity>> createElement() {
    return _TaskTagsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskTagsProvider && other.taskId == taskId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, taskId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TaskTagsRef on AutoDisposeFutureProviderRef<List<TagEntity>> {
  /// The parameter `taskId` of this provider.
  String get taskId;
}

class _TaskTagsProviderElement
    extends AutoDisposeFutureProviderElement<List<TagEntity>>
    with TaskTagsRef {
  _TaskTagsProviderElement(super.provider);

  @override
  String get taskId => (origin as TaskTagsProvider).taskId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
