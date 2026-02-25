import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/services/splash/splash_stub.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('splash_stub', () {
    group('preserveSplash', () {
      test('does not throw when called with a WidgetsBinding', () {
        final binding = WidgetsBinding.instance;

        expect(() => preserveSplash(binding), returnsNormally);
      });
    });

    group('removeSplash', () {
      test('does not throw', () {
        expect(() => removeSplash(), returnsNormally);
      });
    });
  });
}
