import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/services/widget/home_widget_client.dart';
import 'package:todo_app/services/widget/home_widget_client_native.dart';

void main() {
  group('createPlatformHomeWidgetClient', () {
    test('returns a HomeWidgetClient instance', () {
      final client = createPlatformHomeWidgetClient();
      expect(client, isA<HomeWidgetClient>());
    });
  });
}
