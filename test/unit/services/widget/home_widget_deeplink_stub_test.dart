import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/services/widget/home_widget_deeplink_stub.dart';

void main() {
  group('handleWidgetDeepLink', () {
    test('does not throw', () {
      expect(() => handleWidgetDeepLink(onUri: (_) {}), returnsNormally);
    });

    test('does not invoke onUri callback', () {
      var callbackInvoked = false;

      handleWidgetDeepLink(
        onUri: (_) {
          callbackInvoked = true;
        },
      );

      expect(callbackInvoked, isFalse);
    });
  });
}
