import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/services/connectivity_service.dart';
import 'package:todo_app/services/connectivity_service_impl.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity mockConnectivity;
  late ConnectivityService service;

  setUp(() {
    mockConnectivity = MockConnectivity();
    service = ConnectivityServiceImpl(mockConnectivity);
  });

  group('isOnline', () {
    test('returns true when connected via wifi', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      expect(await service.isOnline, isTrue);
    });

    test('returns true when connected via mobile', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);

      expect(await service.isOnline, isTrue);
    });

    test('returns true when connected via ethernet', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.ethernet]);

      expect(await service.isOnline, isTrue);
    });

    test('returns false when no connectivity', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      expect(await service.isOnline, isFalse);
    });

    test('returns true when multiple results include a real connection',
        () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi, ConnectivityResult.mobile]);

      expect(await service.isOnline, isTrue);
    });
  });

  group('onConnectivityChanged', () {
    test('emits true when connectivity changes to wifi', () async {
      final controller = StreamController<List<ConnectivityResult>>();
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => controller.stream);

      final stream = service.onConnectivityChanged;

      controller.add([ConnectivityResult.wifi]);

      expect(await stream.first, isTrue);

      await controller.close();
    });

    test('emits false when connectivity changes to none', () async {
      final controller = StreamController<List<ConnectivityResult>>();
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => controller.stream);

      final stream = service.onConnectivityChanged;

      controller.add([ConnectivityResult.none]);

      expect(await stream.first, isFalse);

      await controller.close();
    });

    test('emits sequential changes', () async {
      final controller = StreamController<List<ConnectivityResult>>();
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => controller.stream);

      final results = <bool>[];
      final sub = service.onConnectivityChanged.listen(results.add);

      controller.add([ConnectivityResult.wifi]);
      controller.add([ConnectivityResult.none]);
      controller.add([ConnectivityResult.mobile]);

      // Allow microtasks to complete
      await Future<void>.delayed(Duration.zero);

      expect(results, [true, false, true]);

      await sub.cancel();
      await controller.close();
    });
  });
}
