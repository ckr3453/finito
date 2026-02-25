import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import 'package:todo_app/presentation/providers/auth_provider.dart';
import 'package:todo_app/presentation/providers/user_provider.dart';
import 'package:todo_app/routing/app_shell.dart';
import 'package:todo_app/services/auth_service.dart';
import 'package:todo_app/services/user_service.dart';

class MockAuthService extends Mock implements AuthService {}

Widget buildTestApp({
  required List<Override> overrides,
  Size screenSize = const Size(400, 800),
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (_, _) => const Text('Home'),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: overrides,
    child: MediaQuery(
      data: MediaQueryData(size: screenSize),
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('ko'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
}

UserProfile createTestProfile({bool approved = false, bool isAdmin = false}) {
  return UserProfile(
    uid: 'test-uid',
    email: 'test@example.com',
    displayName: 'Test User',
    approved: approved,
    isAdmin: isAdmin,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    when(() => mockAuthService.signOut()).thenAnswer((_) async {});
  });

  group('Approval gate', () {
    testWidgets('shows CircularProgressIndicator while profile is loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
            isAuthenticatedProvider.overrideWithValue(true),
            currentUserProfileProvider.overrideWith(
              (ref) => const Stream<UserProfile?>.empty(),
            ),
            isApprovedProvider.overrideWithValue(false),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows PendingApprovalScreen when user is unapproved', (
      WidgetTester tester,
    ) async {
      final unapprovedProfile = createTestProfile(approved: false);

      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
            isAuthenticatedProvider.overrideWithValue(true),
            currentUserProfileProvider.overrideWith(
              (ref) => Stream.value(unapprovedProfile),
            ),
            isApprovedProvider.overrideWithValue(false),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('승인 대기 중'), findsOneWidget);
    });

    testWidgets('shows child when user is approved', (
      WidgetTester tester,
    ) async {
      final approvedProfile = createTestProfile(approved: true);

      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
            isAuthenticatedProvider.overrideWithValue(true),
            currentUserProfileProvider.overrideWith(
              (ref) => Stream.value(approvedProfile),
            ),
            isApprovedProvider.overrideWithValue(true),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('shows child when profile loading errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
            isAuthenticatedProvider.overrideWithValue(true),
            currentUserProfileProvider.overrideWith(
              (ref) => Stream<UserProfile?>.error(Exception('test error')),
            ),
            isApprovedProvider.overrideWithValue(false),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });
  });

  group('Responsive navigation', () {
    testWidgets('shows NavigationBar on narrow screen (width < 600)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          screenSize: const Size(400, 800),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
            isAuthenticatedProvider.overrideWithValue(false),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('shows NavigationRail on wide screen (width >= 600)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          screenSize: const Size(800, 600),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
            isAuthenticatedProvider.overrideWithValue(false),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });
  });
}
