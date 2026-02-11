import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/services/notification/fcm_client.dart';
import 'package:todo_app/services/notification/fcm_service.dart';
import 'package:todo_app/services/notification/fcm_service_impl.dart';

class MockFcmClient extends Mock implements FcmClient {}

void main() {
  late MockFcmClient mockClient;
  late FcmService service;

  setUp(() {
    mockClient = MockFcmClient();
    service = FcmServiceImpl(client: mockClient);
  });

  group('FcmServiceImpl', () {
    group('getToken', () {
      test('should return FCM token from client', () async {
        when(() => mockClient.getToken()).thenAnswer((_) async => 'test-token');

        final token = await service.getToken();

        expect(token, 'test-token');
        verify(() => mockClient.getToken()).called(1);
      });

      test('should return null when client returns null', () async {
        when(() => mockClient.getToken()).thenAnswer((_) async => null);

        final token = await service.getToken();

        expect(token, isNull);
      });
    });

    group('onTokenRefresh', () {
      test('should stream token refresh events', () async {
        final controller = StreamController<String>.broadcast();
        when(
          () => mockClient.onTokenRefresh,
        ).thenAnswer((_) => controller.stream);

        final stream = service.onTokenRefresh;
        final future = stream.first;

        controller.add('new-token');

        expect(await future, 'new-token');

        await controller.close();
      });
    });

    group('requestPermission', () {
      test('should delegate to client', () async {
        when(
          () => mockClient.requestPermission(),
        ).thenAnswer((_) async => true);

        final result = await service.requestPermission();

        expect(result, isTrue);
        verify(() => mockClient.requestPermission()).called(1);
      });
    });
  });
}
