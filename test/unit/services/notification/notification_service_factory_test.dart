import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/services/notification/notification_service.dart';
import 'package:todo_app/services/notification/notification_service_factory.dart';

void main() {
  group('createNotificationService', () {
    test('returns a NotificationService instance', () {
      final service = createNotificationService();

      expect(service, isA<NotificationService>());
    });

    test('returns a non-null value', () {
      final service = createNotificationService();

      expect(service, isNotNull);
    });
  });
}
