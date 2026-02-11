import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/core/l10n_extension.dart';
import 'package:todo_app/l10n/app_localizations.dart';

void main() {
  group('L10nX extension', () {
    testWidgets('context.l10n returns AppLocalizations for Korean', (
      WidgetTester tester,
    ) async {
      late AppLocalizations captured;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ko'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              captured = context.l10n;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(captured.appTitle, 'TODO');
      expect(captured.filterAll, '전체');
      expect(captured.cancel, '취소');
    });

    testWidgets('context.l10n returns AppLocalizations for English', (
      WidgetTester tester,
    ) async {
      late AppLocalizations captured;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              captured = context.l10n;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(captured.appTitle, 'TODO');
      expect(captured.filterAll, 'All');
      expect(captured.cancel, 'Cancel');
    });
  });
}
