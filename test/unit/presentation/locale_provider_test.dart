import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/presentation/providers/locale_provider.dart';

void main() {
  group('AppLocale', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is null (system locale)', () {
      final locale = container.read(appLocaleProvider);
      expect(locale, isNull);
    });

    test('setLocale updates state to Korean', () async {
      final notifier = container.read(appLocaleProvider.notifier);
      await notifier.setLocale(const Locale('ko'));

      expect(container.read(appLocaleProvider), const Locale('ko'));
    });

    test('setLocale updates state to English', () async {
      final notifier = container.read(appLocaleProvider.notifier);
      await notifier.setLocale(const Locale('en'));

      expect(container.read(appLocaleProvider), const Locale('en'));
    });

    test('setLocale(null) resets to system', () async {
      final notifier = container.read(appLocaleProvider.notifier);
      await notifier.setLocale(const Locale('ko'));
      await notifier.setLocale(null);

      expect(container.read(appLocaleProvider), isNull);
    });

    test('setLocale persists to SharedPreferences', () async {
      final notifier = container.read(appLocaleProvider.notifier);
      await notifier.setLocale(const Locale('en'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), 'en');
    });

    test('setLocale(null) removes from SharedPreferences', () async {
      final notifier = container.read(appLocaleProvider.notifier);
      await notifier.setLocale(const Locale('ko'));
      await notifier.setLocale(null);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), isNull);
    });

    test('loadSavedLocale restores persisted locale', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'en'});
      final freshContainer = ProviderContainer();
      addTearDown(freshContainer.dispose);

      final notifier = freshContainer.read(appLocaleProvider.notifier);
      await notifier.loadSavedLocale();

      expect(freshContainer.read(appLocaleProvider), const Locale('en'));
    });

    test('loadSavedLocale does nothing when no persisted value', () async {
      SharedPreferences.setMockInitialValues({});
      final freshContainer = ProviderContainer();
      addTearDown(freshContainer.dispose);

      final notifier = freshContainer.read(appLocaleProvider.notifier);
      await notifier.loadSavedLocale();

      expect(freshContainer.read(appLocaleProvider), isNull);
    });
  });
}
