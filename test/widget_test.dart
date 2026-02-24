import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/presentation/providers/category_providers.dart';
import 'package:todo_app/presentation/providers/database_provider.dart';
import 'package:todo_app/presentation/providers/notification_provider.dart';
import 'package:todo_app/presentation/providers/task_providers.dart';
import 'package:todo_app/presentation/providers/widget_provider.dart';
import 'package:todo_app/services/notification/notification_service.dart';
import 'package:todo_app/services/widget/widget_service.dart';

import 'helpers/test_database.dart';

class MockNotificationService extends Mock implements NotificationService {}

class MockWidgetService extends Mock implements WidgetService {}

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    final mockNotifSvc = MockNotificationService();
    when(
      () => mockNotifSvc.initialize(
        onNotificationTap: any(named: 'onNotificationTap'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockNotifSvc.rescheduleAll(any()),
    ).thenAnswer((_) async {});

    final mockWidgetSvc = MockWidgetService();
    when(() => mockWidgetSvc.refreshWidget()).thenAnswer((_) async {});
    when(
      () => mockWidgetSvc.updateWidgetData(any()),
    ).thenAnswer((_) async {});

    final testDb = createTestDatabase();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(testDb),
          notificationServiceProvider.overrideWithValue(mockNotifSvc),
          widgetServiceProvider.overrideWithValue(mockWidgetSvc),
          // Override all stream providers to avoid drift stream query timers
          widgetAutoUpdateProvider.overrideWith(
            (ref) => const Stream<void>.empty(),
          ),
          reminderAutoRescheduleProvider.overrideWith(
            (ref) => const Stream<void>.empty(),
          ),
          taskListProvider.overrideWith(
            (ref) => const Stream.empty(),
          ),
          categoryListProvider.overrideWith(
            (ref) => const Stream.empty(),
          ),
        ],
        child: const TodoApp(),
      ),
    );
    await tester.pump();

    // Verify the app renders with l10n-powered UI
    expect(find.byType(TodoApp), findsOneWidget);
  });
}
