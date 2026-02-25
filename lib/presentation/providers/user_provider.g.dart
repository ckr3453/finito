// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userServiceHash() => r'db7b6b62ab179c0d9a73a4fcd54de191f4690550';

/// See also [userService].
@ProviderFor(userService)
final userServiceProvider = Provider<UserService>.internal(
  userService,
  name: r'userServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserServiceRef = ProviderRef<UserService>;
String _$currentUserProfileHash() =>
    r'a0eb875e005e052a234f6445dcf453b1cae1886a';

/// See also [currentUserProfile].
@ProviderFor(currentUserProfile)
final currentUserProfileProvider =
    AutoDisposeStreamProvider<UserProfile?>.internal(
      currentUserProfile,
      name: r'currentUserProfileProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentUserProfileHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserProfileRef = AutoDisposeStreamProviderRef<UserProfile?>;
String _$isApprovedHash() => r'e627715bf90b4aaeabca88055708997483d9e40b';

/// See also [isApproved].
@ProviderFor(isApproved)
final isApprovedProvider = AutoDisposeProvider<bool>.internal(
  isApproved,
  name: r'isApprovedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isApprovedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsApprovedRef = AutoDisposeProviderRef<bool>;
String _$isAdminHash() => r'26f1e2d742ea855a2b27312fb35e109a938a35e1';

/// See also [isAdmin].
@ProviderFor(isAdmin)
final isAdminProvider = AutoDisposeProvider<bool>.internal(
  isAdmin,
  name: r'isAdminProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAdminHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAdminRef = AutoDisposeProviderRef<bool>;
String _$allUsersHash() => r'61c4e4d5e059afbf81e55673e07d2cec7678b500';

/// See also [allUsers].
@ProviderFor(allUsers)
final allUsersProvider = AutoDisposeStreamProvider<List<UserProfile>>.internal(
  allUsers,
  name: r'allUsersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allUsersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllUsersRef = AutoDisposeStreamProviderRef<List<UserProfile>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
