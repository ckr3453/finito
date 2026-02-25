import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import 'package:todo_app/presentation/providers/auth_provider.dart';
import 'package:todo_app/presentation/screens/admin/pending_approval_screen.dart';
import 'package:todo_app/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  Widget buildSubject() {
    return ProviderScope(
      overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
      child: const MaterialApp(
        locale: Locale('ko'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: PendingApprovalScreen(),
      ),
    );
  }

  group('PendingApprovalScreen', () {
    testWidgets('renders hourglass icon', (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.hourglass_empty), findsOneWidget);
    });

    testWidgets('renders pending approval title text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('승인 대기 중'), findsOneWidget);
    });

    testWidgets('renders pending approval message text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(
        find.text('관리자의 승인을 기다리고 있습니다. 관리자가 접근을 승인할 때까지 잠시 기다려주세요.'),
        findsOneWidget,
      );
    });

    testWidgets('logout button calls authService.signOut when tapped', (
      WidgetTester tester,
    ) async {
      when(() => mockAuthService.signOut()).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('로그아웃'));
      await tester.pumpAndSettle();

      verify(() => mockAuthService.signOut()).called(1);
    });
  });
}
