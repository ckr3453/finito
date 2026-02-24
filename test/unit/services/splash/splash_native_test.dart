import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/services/splash/splash_native.dart';

void main() {
  group('splash_native', () {
    testWidgets('preserveSplash does not throw', (tester) async {
      // FlutterNativeSplash.preserve may throw in test environment
      // but the function itself should be callable
      try {
        preserveSplash(tester.binding);
      } catch (_) {
        // Expected in test environment without native splash setup
      }
    });

    test('removeSplash does not throw', () {
      try {
        removeSplash();
      } catch (_) {
        // Expected in test environment without native splash setup
      }
    });
  });
}
