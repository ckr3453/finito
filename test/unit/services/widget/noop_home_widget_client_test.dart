import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/services/widget/home_widget_client.dart';
import 'package:todo_app/services/widget/noop_home_widget_client.dart';

void main() {
  late HomeWidgetClient client;

  setUp(() {
    client = NoopHomeWidgetClient();
  });

  group('NoopHomeWidgetClient', () {
    group('saveWidgetData', () {
      test('does not throw and returns true', () async {
        final result = await client.saveWidgetData<String>('key', 'value');

        expect(result, isTrue);
      });

      test('accepts null data and returns true', () async {
        final result = await client.saveWidgetData<String>('key', null);

        expect(result, isTrue);
      });

      test('accepts non-string data type and returns true', () async {
        final result = await client.saveWidgetData<int>('count', 42);

        expect(result, isTrue);
      });
    });

    group('updateWidget', () {
      test(
        'does not throw and returns true when all named args provided',
        () async {
          final result = await client.updateWidget(
            androidName: 'MyWidget',
            iOSName: 'MyWidget',
            qualifiedAndroidName: 'com.example.MyWidget',
          );

          expect(result, isTrue);
        },
      );

      test('does not throw and returns true when no args provided', () async {
        final result = await client.updateWidget();

        expect(result, isTrue);
      });

      test('does not throw and returns true with only androidName', () async {
        final result = await client.updateWidget(androidName: 'MyWidget');

        expect(result, isTrue);
      });

      test('does not throw and returns true with only iOSName', () async {
        final result = await client.updateWidget(iOSName: 'MyWidget');

        expect(result, isTrue);
      });
    });

    group('registerInteractivityCallback', () {
      test('does not throw when callback is provided', () async {
        Future<void> callback(Uri? uri) async {}

        await expectLater(
          client.registerInteractivityCallback(callback),
          completes,
        );
      });

      test('does not invoke the callback', () async {
        var callbackInvoked = false;

        Future<void> callback(Uri? uri) async {
          callbackInvoked = true;
        }

        await client.registerInteractivityCallback(callback);

        expect(callbackInvoked, isFalse);
      });
    });
  });
}
