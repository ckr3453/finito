import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/domain/enums/enums.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import 'package:todo_app/presentation/shared_widgets/priority_indicator.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    const delegate = AppLocalizations.delegate;
    l10n = await delegate.load(const Locale('ko'));
  });

  group('PriorityIndicator.colorFor', () {
    test('returns red for high priority', () {
      expect(PriorityIndicator.colorFor(Priority.high), Colors.red);
    });

    test('returns orange for medium priority', () {
      expect(PriorityIndicator.colorFor(Priority.medium), Colors.orange);
    });

    test('returns grey for low priority', () {
      expect(PriorityIndicator.colorFor(Priority.low), Colors.grey);
    });
  });

  group('PriorityIndicator.labelFor', () {
    test('returns 높음 for high', () {
      expect(PriorityIndicator.labelFor(Priority.high, l10n), '높음');
    });

    test('returns 보통 for medium', () {
      expect(PriorityIndicator.labelFor(Priority.medium, l10n), '보통');
    });

    test('returns 낮음 for low', () {
      expect(PriorityIndicator.labelFor(Priority.low, l10n), '낮음');
    });
  });

  group('PriorityIndicator widget', () {
    for (final priority in Priority.values) {
      testWidgets('renders with correct color for $priority', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SizedBox(
                height: 50,
                child: PriorityIndicator(priority: priority),
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, PriorityIndicator.colorFor(priority));
      });
    }
  });
}
