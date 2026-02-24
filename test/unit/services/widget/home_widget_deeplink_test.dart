import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/services/widget/home_widget_deeplink.dart';

void main() {
  group('handleWidgetDeepLink', () {
    testWidgets('does not throw when called', (tester) async {
      // In test environment, HomeWidget method channel returns null/empty
      // which is handled gracefully by the implementation.
      handleWidgetDeepLink(onUri: (_) {});
      await tester.pump();
      // onUri may or may not be called depending on method channel mock state
      // The key assertion is that no exception is thrown
    });
  });
}
