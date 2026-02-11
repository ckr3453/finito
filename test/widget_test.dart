import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/presentation/providers/notification_provider.dart';
import 'package:todo_app/services/notification/notification_service.dart';

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    final mockNotifSvc = MockNotificationService();
    when(
      () => mockNotifSvc.initialize(
        onNotificationTap: any(named: 'onNotificationTap'),
      ),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationServiceProvider.overrideWithValue(mockNotifSvc),
        ],
        child: const TodoApp(),
      ),
    );
    await tester.pump();

    // Verify the app renders with navigation
    expect(find.text('홈'), findsWidgets);
  });
}
