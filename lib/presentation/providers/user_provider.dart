import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/presentation/providers/auth_provider.dart';
import 'package:todo_app/services/user_service.dart';

part 'user_provider.g.dart';

@Riverpod(keepAlive: true)
UserService userService(Ref ref) {
  return UserService();
}

@riverpod
Stream<UserProfile?> currentUserProfile(Ref ref) async* {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    yield null;
    return;
  }
  final service = ref.watch(userServiceProvider);
  // Ensure profile exists on login
  await service.ensureUserProfile(
    uid: user.uid,
    email: user.email,
    displayName: user.displayName,
  );
  // Then fetch and yield
  final profile = await service.getUserProfile(user.uid);
  yield profile;
}

@riverpod
bool isApproved(Ref ref) {
  final profile = ref.watch(currentUserProfileProvider).valueOrNull;
  return profile?.approved ?? false;
}

@riverpod
bool isAdmin(Ref ref) {
  final profile = ref.watch(currentUserProfileProvider).valueOrNull;
  return profile?.isAdmin ?? false;
}

@riverpod
Stream<List<UserProfile>> allUsers(Ref ref) {
  final service = ref.watch(userServiceProvider);
  return service.watchAllUsers();
}
