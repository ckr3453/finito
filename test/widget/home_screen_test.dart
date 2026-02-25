import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/domain/entities/category_entity.dart';
import 'package:todo_app/domain/entities/task_entity.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import 'package:todo_app/presentation/providers/auth_provider.dart';
import 'package:todo_app/presentation/providers/category_providers.dart';
import 'package:todo_app/presentation/providers/task_providers.dart';
import 'package:todo_app/presentation/screens/home/home_screen.dart';
import 'package:todo_app/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

class MockUser extends Mock implements User {}

Widget buildTestApp({required List<Override> overrides}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', name: 'home', builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const Scaffold(body: Text('Login')),
      ),
      GoRoute(
        path: '/task-editor',
        name: 'taskEditor',
        builder: (_, __) => const Scaffold(body: Text('Editor')),
      ),
    ],
  );

  return ProviderScope(
    overrides: overrides,
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
  );
}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  List<Override> baseOverrides({
    required Override authStateOverride,
    bool loginDismissed = false,
  }) {
    return [
      authStateOverride,
      authServiceProvider.overrideWithValue(mockAuthService),
      taskListProvider.overrideWith((ref) => Stream.value(<TaskEntity>[])),
      categoryListProvider.overrideWith(
        (ref) => Stream.value(<CategoryEntity>[]),
      ),
      if (loginDismissed) loginDismissedProvider.overrideWith((ref) => true),
    ];
  }

  group('HomeScreen login dialog', () {
    testWidgets('does NOT show dialog while auth state is loading', (
      WidgetTester tester,
    ) async {
      // Use a StreamController that never emits so auth stays in loading.
      final controller = StreamController<User?>();
      addTearDown(controller.close);

      await tester.pumpWidget(
        buildTestApp(
          overrides: baseOverrides(
            authStateOverride: authStateProvider.overrideWith(
              (ref) => controller.stream,
            ),
          ),
        ),
      );

      // Pump a few frames to process addPostFrameCallback.
      await tester.pump();
      await tester.pump();

      // The dialog should NOT appear because auth is still loading.
      expect(find.text('Finito'), findsNothing);
    });

    testWidgets('does NOT show dialog when user is authenticated', (
      WidgetTester tester,
    ) async {
      final mockUser = MockUser();

      await tester.pumpWidget(
        buildTestApp(
          overrides: baseOverrides(
            authStateOverride: authStateProvider.overrideWith(
              (ref) => Stream.value(mockUser),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Dialog should NOT appear because user is authenticated.
      expect(find.text('Finito'), findsNothing);
    });

    testWidgets('shows dialog when user is NOT authenticated', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: baseOverrides(
            authStateOverride: authStateProvider.overrideWith(
              (ref) => Stream.value(null),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Dialog should appear with Finito branding.
      expect(find.text('Finito'), findsOneWidget);

      // Verify dialog contains Google sign-in button.
      expect(find.text('Google\ub85c \ub85c\uadf8\uc778'), findsOneWidget);

      // Verify dialog contains email login button.
      expect(find.text('\ub85c\uadf8\uc778'), findsWidgets);

      // Verify dialog contains "continue without account" button.
      expect(
        find.text('\uacc4\uc815 \uc5c6\uc774 \uacc4\uc18d\ud558\uae30'),
        findsOneWidget,
      );
    });

    testWidgets('does NOT show dialog when loginDismissed is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: baseOverrides(
            authStateOverride: authStateProvider.overrideWith(
              (ref) => Stream.value(null),
            ),
            loginDismissed: true,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Dialog should NOT appear because user previously dismissed it.
      expect(find.text('Finito'), findsNothing);
    });
  });
}
