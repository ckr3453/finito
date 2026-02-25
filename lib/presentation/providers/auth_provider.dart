import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/services/auth_service.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  return AuthService();
}

@Riverpod(keepAlive: true)
Stream<User?> authState(Ref ref) {
  final service = ref.watch(authServiceProvider);
  return service.authStateChanges();
}

@riverpod
User? currentUser(Ref ref) {
  return ref.watch(authStateProvider).valueOrNull;
}

@riverpod
bool isAuthenticated(Ref ref) {
  return ref.watch(currentUserProvider) != null;
}

@riverpod
bool isEmailVerified(Ref ref) {
  final user = ref.watch(currentUserProvider);
  return user?.emailVerified ?? false;
}

@riverpod
bool isAnonymous(Ref ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isAnonymous ?? false;
}
