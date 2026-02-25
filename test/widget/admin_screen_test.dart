import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import 'package:todo_app/presentation/providers/user_provider.dart';
import 'package:todo_app/presentation/screens/admin/admin_screen.dart';
import 'package:todo_app/services/user_service.dart';

Widget buildSubject({required List<Override> overrides}) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(
      locale: Locale('ko'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: AdminScreen(),
    ),
  );
}

void main() {
  late UserService userService;

  setUp(() {
    userService = UserService(firestore: FakeFirebaseFirestore());
  });

  group('AdminScreen', () {
    testWidgets('shows CircularProgressIndicator while loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          overrides: [
            userServiceProvider.overrideWithValue(userService),
            allUsersProvider.overrideWith(
              (ref) => const Stream<List<UserProfile>>.empty(),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error text on error', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildSubject(
          overrides: [
            userServiceProvider.overrideWithValue(userService),
            allUsersProvider.overrideWith(
              (ref) => Stream<List<UserProfile>>.error(Exception('test error')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('shows empty state text when no users', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          overrides: [
            userServiceProvider.overrideWithValue(userService),
            allUsersProvider.overrideWith(
              (ref) => Stream.value(<UserProfile>[]),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('사용자 없음'), findsOneWidget);
    });

    testWidgets('shows correct stat card counts', (WidgetTester tester) async {
      final users = [
        UserProfile(
          uid: 'u1',
          email: 'a@example.com',
          approved: true,
          isAdmin: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        UserProfile(
          uid: 'u2',
          email: 'b@example.com',
          approved: true,
          isAdmin: false,
          createdAt: DateTime(2026, 1, 2),
        ),
        UserProfile(
          uid: 'u3',
          email: 'c@example.com',
          approved: false,
          isAdmin: false,
          createdAt: DateTime(2026, 1, 3),
        ),
      ];

      await tester.pumpWidget(
        buildSubject(
          overrides: [
            userServiceProvider.overrideWithValue(userService),
            allUsersProvider.overrideWith((ref) => Stream.value(users)),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Total: 3, Pending: 1, Approved: 2
      // Numbers may appear in both stat cards and group section headers
      expect(find.text('3'), findsWidgets); // total
      expect(find.text('1'), findsWidgets); // pending/admin count
      expect(find.text('2'), findsWidgets); // approved/user count
      expect(find.text('전체 사용자'), findsOneWidget);
      expect(find.text('승인 대기'), findsOneWidget);
    });

    testWidgets('shows user list with approve button for unapproved user', (
      WidgetTester tester,
    ) async {
      final users = [
        UserProfile(
          uid: 'u1',
          email: 'pending@example.com',
          approved: false,
          isAdmin: false,
          createdAt: DateTime(2026, 1, 1),
        ),
      ];

      await tester.pumpWidget(
        buildSubject(
          overrides: [
            userServiceProvider.overrideWithValue(userService),
            allUsersProvider.overrideWith((ref) => Stream.value(users)),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('pending@example.com'), findsOneWidget);
      expect(find.text('승인'), findsOneWidget);
    });

    testWidgets('shows approved chip for approved user', (
      WidgetTester tester,
    ) async {
      final users = [
        UserProfile(
          uid: 'u1',
          email: 'approved@example.com',
          approved: true,
          isAdmin: false,
          createdAt: DateTime(2026, 1, 1),
        ),
      ];

      await tester.pumpWidget(
        buildSubject(
          overrides: [
            userServiceProvider.overrideWithValue(userService),
            allUsersProvider.overrideWith((ref) => Stream.value(users)),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('approved@example.com'), findsOneWidget);
      // "승인됨" appears in both stat card label and the chip
      expect(find.text('승인됨'), findsWidgets);
    });
  });
}
