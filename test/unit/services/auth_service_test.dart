import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/services/auth_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockFirebaseAuth mockAuth;
  late AuthService authService;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    authService = AuthService(auth: mockAuth);
  });

  group('AuthService', () {
    test('currentUser delegates to FirebaseAuth', () {
      final mockUser = MockUser();
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      expect(authService.currentUser, equals(mockUser));
      verify(() => mockAuth.currentUser).called(1);
    });

    test('currentUser returns null when not signed in', () {
      when(() => mockAuth.currentUser).thenReturn(null);

      expect(authService.currentUser, isNull);
    });

    test('authStateChanges delegates to FirebaseAuth', () {
      final mockUser = MockUser();
      when(
        () => mockAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.value(mockUser));

      expect(authService.authStateChanges(), emits(mockUser));
    });

    test('authStateChanges emits null on sign out', () {
      when(
        () => mockAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.value(null));

      expect(authService.authStateChanges(), emits(isNull));
    });

    test('signInWithEmail delegates to FirebaseAuth', () async {
      final mockCredential = MockUserCredential();
      when(
        () => mockAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => mockCredential);

      final result = await authService.signInWithEmail(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, equals(mockCredential));
      verify(
        () => mockAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
    });

    test('signInWithEmail propagates FirebaseAuthException', () async {
      when(
        () => mockAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      expect(
        () => authService.signInWithEmail(
          email: 'test@example.com',
          password: 'wrong',
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('signUpWithEmail delegates to FirebaseAuth', () async {
      final mockCredential = MockUserCredential();
      when(
        () => mockAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => mockCredential);

      final result = await authService.signUpWithEmail(
        email: 'new@example.com',
        password: 'password123',
      );

      expect(result, equals(mockCredential));
      verify(
        () => mockAuth.createUserWithEmailAndPassword(
          email: 'new@example.com',
          password: 'password123',
        ),
      ).called(1);
    });

    test('signUpWithEmail propagates FirebaseAuthException', () async {
      when(
        () => mockAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      expect(
        () => authService.signUpWithEmail(
          email: 'existing@example.com',
          password: 'password123',
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('signOut delegates to FirebaseAuth', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      await authService.signOut();

      verify(() => mockAuth.signOut()).called(1);
    });

    test('signOut propagates exception', () async {
      when(() => mockAuth.signOut()).thenThrow(Exception('sign out failed'));

      expect(() => authService.signOut(), throwsA(isA<Exception>()));
    });

    test('resetPassword delegates to FirebaseAuth', () async {
      when(
        () => mockAuth.sendPasswordResetEmail(email: any(named: 'email')),
      ).thenAnswer((_) async {});

      await authService.resetPassword(email: 'test@example.com');

      verify(
        () => mockAuth.sendPasswordResetEmail(email: 'test@example.com'),
      ).called(1);
    });
    test('resetPassword propagates FirebaseAuthException', () async {
      when(
        () => mockAuth.sendPasswordResetEmail(email: any(named: 'email')),
      ).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      expect(
        () => authService.resetPassword(email: 'noone@example.com'),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });
}
