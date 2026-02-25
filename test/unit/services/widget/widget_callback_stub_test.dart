import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/services/widget/widget_callback_stub.dart';

void main() {
  group('registerWidgetCallback', () {
    test('does not throw', () {
      expect(() => registerWidgetCallback(), returnsNormally);
    });
  });
}
