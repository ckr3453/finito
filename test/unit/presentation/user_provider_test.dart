import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/presentation/providers/auth_provider.dart';
import 'package:todo_app/presentation/providers/user_provider.dart';
import 'package:todo_app/services/user_service.dart';

class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late UserService userService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    userService = UserService(firestore: fakeFirestore);
  });

  group('isApprovedProvider', () {
    test('returns false when no profile (unauthenticated)', () {
      final container = ProviderContainer(
        overrides: [
          userServiceProvider.overrideWithValue(userService),
          authStateProvider.overrideWith((ref) => Stream<User?>.value(null)),
        ],
      );
      addTearDown(container.dispose);

      final isApproved = container.read(isApprovedProvider);

      expect(isApproved, false);
    });

    test('returns true when profile is approved', () async {
      final container = ProviderContainer(
        overrides: [
          userServiceProvider.overrideWithValue(userService),
          currentUserProfileProvider.overrideWith(
            (ref) => Stream.value(
              UserProfile(
                uid: 'u1',
                approved: true,
                isAdmin: false,
                createdAt: DateTime(2026, 1, 1),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Wait for the stream to emit
      await container.read(currentUserProfileProvider.future);

      final isApproved = container.read(isApprovedProvider);

      expect(isApproved, true);
    });

    test('returns false when profile is not approved', () async {
      final container = ProviderContainer(
        overrides: [
          userServiceProvider.overrideWithValue(userService),
          currentUserProfileProvider.overrideWith(
            (ref) => Stream.value(
              UserProfile(
                uid: 'u1',
                approved: false,
                isAdmin: false,
                createdAt: DateTime(2026, 1, 1),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(currentUserProfileProvider.future);

      final isApproved = container.read(isApprovedProvider);

      expect(isApproved, false);
    });
  });

  group('isAdminProvider', () {
    test('returns false when no profile', () {
      final container = ProviderContainer(
        overrides: [
          userServiceProvider.overrideWithValue(userService),
          authStateProvider.overrideWith((ref) => Stream<User?>.value(null)),
        ],
      );
      addTearDown(container.dispose);

      final isAdmin = container.read(isAdminProvider);

      expect(isAdmin, false);
    });

    test('returns true when profile is admin', () async {
      final container = ProviderContainer(
        overrides: [
          userServiceProvider.overrideWithValue(userService),
          currentUserProfileProvider.overrideWith(
            (ref) => Stream.value(
              UserProfile(
                uid: 'u1',
                approved: true,
                isAdmin: true,
                createdAt: DateTime(2026, 1, 1),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(currentUserProfileProvider.future);

      final isAdmin = container.read(isAdminProvider);

      expect(isAdmin, true);
    });
  });

  group('allUsersProvider', () {
    test('delegates to userService.watchAllUsers', () async {
      // Seed a user in fake Firestore
      await fakeFirestore.doc('users/u1').set({
        'email': 'test@example.com',
        'approved': true,
        'isAdmin': false,
        'createdAt': DateTime(2026, 1, 1),
      });

      final container = ProviderContainer(
        overrides: [userServiceProvider.overrideWithValue(userService)],
      );
      addTearDown(container.dispose);

      final users = await container.read(allUsersProvider.future);

      expect(users, hasLength(1));
      expect(users[0].uid, 'u1');
    });
  });

  group('currentUserProfileProvider', () {
    test('yields null when no user is authenticated', () async {
      final container = ProviderContainer(
        overrides: [
          userServiceProvider.overrideWithValue(userService),
          authStateProvider.overrideWith((ref) => Stream<User?>.value(null)),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authStateProvider.future);

      final profile = await container.read(currentUserProfileProvider.future);

      expect(profile, isNull);
    });
  });
}
