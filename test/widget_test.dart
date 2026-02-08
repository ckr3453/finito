import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:todo_app/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TodoApp()));
    await tester.pump();

    // Verify the app renders with navigation
    expect(find.text('홈'), findsWidgets);
  });
}
