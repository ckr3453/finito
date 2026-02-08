import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/services/auth_service.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
AuthService authService(ref) {
  return AuthService();
}

@Riverpod(keepAlive: true)
Stream<User?> authState(ref) {
  final service = ref.watch(authServiceProvider);
  return service.authStateChanges();
}

@riverpod
User? currentUser(ref) {
  return ref.watch(authStateProvider).valueOrNull;
}

@riverpod
bool isAuthenticated(ref) {
  return ref.watch(currentUserProvider) != null;
}
