import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/services/notification/notification_service.dart';
import 'package:todo_app/services/notification/notification_service_native.dart';

void main() {
  group('createPlatformNotificationService', () {
    test('returns a NotificationService instance', () {
      final service = createPlatformNotificationService();
      expect(service, isA<NotificationService>());
    });
  });
}
