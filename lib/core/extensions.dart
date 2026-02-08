import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  String toFormattedDate() => DateFormat('yyyy-MM-dd').format(this);
  String toFormattedDateTime() => DateFormat('yyyy-MM-dd HH:mm').format(this);
  String toRelative() {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inDays == 0) return '오늘';
    if (diff.inDays == 1) return '어제';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return toFormattedDate();
  }

  bool get isOverdue => isBefore(DateTime.now());
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

extension ColorX on int {
  Color get color => Color(this);
}

extension StringX on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
