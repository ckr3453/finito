import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/domain/repositories/fcm_token_repository.dart';
import 'package:todo_app/services/notification/fcm_client.dart';
import 'package:todo_app/services/notification/fcm_service.dart';
import 'package:todo_app/services/notification/fcm_service_impl.dart';

class MockFcmClient extends Mock implements FcmClient {}

class MockFcmTokenRepository extends Mock implements FcmTokenRepository {}

void main() {
  late MockFcmClient mockClient;
  late MockFcmTokenRepository mockTokenRepo;
  late FcmService service;

  setUp(() {
    mockClient = MockFcmClient();
    mockTokenRepo = MockFcmTokenRepository();
    service = FcmServiceImpl(
      client: mockClient,
      tokenRepository: mockTokenRepo,
    );
  });

  group('FcmServiceImpl', () {
    group('getToken', () {
      test('should return FCM token from client', () async {
        when(
          () => mockClient.getToken(vapidKey: any(named: 'vapidKey')),
        ).thenAnswer((_) async => 'test-token');

        final token = await service.getToken();

        expect(token, 'test-token');
        verify(
          () => mockClient.getToken(vapidKey: any(named: 'vapidKey')),
        ).called(1);
      });

      test('should return null when client returns null', () async {
        when(
          () => mockClient.getToken(vapidKey: any(named: 'vapidKey')),
        ).thenAnswer((_) async => null);

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

    group('saveTokenToFirestore', () {
      test('should get token and save to repository', () async {
        when(
          () => mockClient.getToken(vapidKey: any(named: 'vapidKey')),
        ).thenAnswer((_) async => 'test-token');
        when(
          () => mockTokenRepo.saveToken(
            userId: any(named: 'userId'),
            token: any(named: 'token'),
            platform: any(named: 'platform'),
          ),
        ).thenAnswer((_) async {});

        await service.saveTokenToFirestore('user123');

        verify(
          () => mockTokenRepo.saveToken(
            userId: 'user123',
            token: 'test-token',
            platform: any(named: 'platform'),
          ),
        ).called(1);
      });

      test('should do nothing when token is null', () async {
        when(
          () => mockClient.getToken(vapidKey: any(named: 'vapidKey')),
        ).thenAnswer((_) async => null);

        await service.saveTokenToFirestore('user123');

        verifyNever(
          () => mockTokenRepo.saveToken(
            userId: any(named: 'userId'),
            token: any(named: 'token'),
            platform: any(named: 'platform'),
          ),
        );
      });
    });

    group('deleteTokenFromFirestore', () {
      test('should get token and delete from repository', () async {
        when(
          () => mockClient.getToken(vapidKey: any(named: 'vapidKey')),
        ).thenAnswer((_) async => 'test-token');
        when(
          () => mockTokenRepo.deleteToken(
            userId: any(named: 'userId'),
            token: any(named: 'token'),
          ),
        ).thenAnswer((_) async {});

        await service.deleteTokenFromFirestore('user123');

        verify(
          () =>
              mockTokenRepo.deleteToken(userId: 'user123', token: 'test-token'),
        ).called(1);
      });

      test('should do nothing when token is null', () async {
        when(
          () => mockClient.getToken(vapidKey: any(named: 'vapidKey')),
        ).thenAnswer((_) async => null);

        await service.deleteTokenFromFirestore('user123');

        verifyNever(
          () => mockTokenRepo.deleteToken(
            userId: any(named: 'userId'),
            token: any(named: 'token'),
          ),
        );
      });
    });

    group('listenForTokenRefresh', () {
      test('should save new token to repository on refresh', () async {
        final controller = StreamController<String>.broadcast();
        when(
          () => mockClient.onTokenRefresh,
        ).thenAnswer((_) => controller.stream);
        when(
          () => mockTokenRepo.saveToken(
            userId: any(named: 'userId'),
            token: any(named: 'token'),
            platform: any(named: 'platform'),
          ),
        ).thenAnswer((_) async {});

        final sub = service.listenForTokenRefresh('user123');

        controller.add('refreshed-token');
        await Future.delayed(Duration.zero);

        verify(
          () => mockTokenRepo.saveToken(
            userId: 'user123',
            token: 'refreshed-token',
            platform: any(named: 'platform'),
          ),
        ).called(1);

        sub?.cancel();
        await controller.close();
      });
    });
  });
}
