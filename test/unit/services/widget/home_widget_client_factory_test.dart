import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/services/widget/home_widget_client.dart';
import 'package:todo_app/services/widget/home_widget_client_factory.dart';

void main() {
  group('createHomeWidgetClient', () {
    test('returns a HomeWidgetClient instance', () {
      final client = createHomeWidgetClient();

      expect(client, isA<HomeWidgetClient>());
    });

    test('returns a non-null value', () {
      final client = createHomeWidgetClient();

      expect(client, isNotNull);
    });
  });
}
