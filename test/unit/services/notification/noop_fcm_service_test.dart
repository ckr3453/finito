import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/services/notification/noop_fcm_service.dart';

void main() {
  late NoopFcmService service;

  setUp(() {
    service = NoopFcmService();
  });

  group('NoopFcmService', () {
    test('getToken returns null', () async {
      expect(await service.getToken(), isNull);
    });

    test('onTokenRefresh emits nothing', () async {
      expect(service.onTokenRefresh, emitsDone);
    });

    test('requestPermission returns false', () async {
      expect(await service.requestPermission(), isFalse);
    });

    test('saveTokenToFirestore completes without error', () async {
      await service.saveTokenToFirestore('user123');
    });

    test('deleteTokenFromFirestore completes without error', () async {
      await service.deleteTokenFromFirestore('user123');
    });

    test('listenForTokenRefresh returns null', () {
      expect(service.listenForTokenRefresh('user123'), isNull);
    });

    test('setupMessageHandlers completes without error', () async {
      await service.setupMessageHandlers(onNotificationTap: (_) {});
    });
  });
}
