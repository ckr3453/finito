import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/core/extensions.dart';

void main() {
  group('DateTimeX', () {
    test('toFormattedDate returns yyyy-MM-dd format', () {
      final date = DateTime(2025, 3, 15);
      expect(date.toFormattedDate(), '2025-03-15');
    });

    test('toFormattedDateTime returns yyyy-MM-dd HH:mm format', () {
      final date = DateTime(2025, 3, 15, 14, 30);
      expect(date.toFormattedDateTime(), '2025-03-15 14:30');
    });

    test('toRelative returns 오늘 for today', () {
      final now = DateTime.now();
      expect(now.toRelative(), '오늘');
    });

    test('toRelative returns 어제 for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(yesterday.toRelative(), '어제');
    });

    test('toRelative returns N일 전 for 2-6 days ago', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      expect(threeDaysAgo.toRelative(), '3일 전');
    });

    test('toRelative returns formatted date for 7+ days ago', () {
      final date = DateTime.now().subtract(const Duration(days: 10));
      expect(date.toRelative(), date.toFormattedDate());
    });

    test('isOverdue returns true for past date', () {
      final past = DateTime.now().subtract(const Duration(hours: 1));
      expect(past.isOverdue, isTrue);
    });

    test('isOverdue returns false for future date', () {
      final future = DateTime.now().add(const Duration(hours: 1));
      expect(future.isOverdue, isFalse);
    });

    test('isToday returns true for today', () {
      final now = DateTime.now();
      expect(now.isToday, isTrue);
    });

    test('isToday returns false for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(yesterday.isToday, isFalse);
    });
  });

  group('ColorX', () {
    test('int.color converts to Color', () {
      const value = 0xFF4CAF50;
      expect(value.color, const Color(0xFF4CAF50));
    });
  });

  group('StringX', () {
    test('capitalize uppercases first character', () {
      expect('hello'.capitalize, 'Hello');
    });

    test('capitalize returns empty string for empty input', () {
      expect(''.capitalize, '');
    });

    test('capitalize handles single character', () {
      expect('a'.capitalize, 'A');
    });

    test('capitalize keeps already capitalized string', () {
      expect('Hello'.capitalize, 'Hello');
    });
  });
}
