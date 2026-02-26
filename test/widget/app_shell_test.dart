import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import 'package:todo_app/routing/app_shell.dart';

Widget buildTestApp({Size screenSize = const Size(400, 800)}) {
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

  return MediaQuery(
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
  );
}

void main() {
  group('Responsive navigation', () {
    testWidgets('shows NavigationBar on narrow screen (width < 600)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp(screenSize: const Size(400, 800)));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('shows NavigationRail on wide screen (width >= 600)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp(screenSize: const Size(800, 600)));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });
  });
}
