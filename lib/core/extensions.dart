import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/l10n/app_localizations.dart';

extension DateTimeX on DateTime {
  String toFormattedDate() => DateFormat('yyyy-MM-dd').format(this);
  String toFormattedDateTime() => DateFormat('yyyy-MM-dd HH:mm').format(this);
  String toRelative(AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inDays == 0) return l10n.relativeToday;
    if (diff.inDays == 1) return l10n.relativeYesterday;
    if (diff.inDays < 7) return l10n.relativeDaysAgo(diff.inDays);
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
