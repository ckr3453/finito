# Task 04: Core 유틸리티 + 테마 시스템

## 의존성
- 없음 (독립 실행 가능)

## 목표
앱 전반에서 사용되는 상수, 확장 메서드, 테마 정의, 유틸리티 함수 작성.

## 생성할 파일

### 1. `lib/core/constants.dart`
```dart
class AppConstants {
  AppConstants._();

  static const String appName = 'TODO';
  static const String dbName = 'todo_app.sqlite';

  // Default category colors
  static const List<int> categoryColors = [
    0xFF4CAF50, // Green
    0xFF2196F3, // Blue
    0xFFFF9800, // Orange
    0xFFE91E63, // Pink
    0xFF9C27B0, // Purple
    0xFF00BCD4, // Cyan
    0xFFFF5722, // Deep Orange
    0xFF607D8B, // Blue Grey
  ];

  // Default tag colors
  static const List<int> tagColors = [
    0xFFEF5350,
    0xFFAB47BC,
    0xFF42A5F5,
    0xFF26A69A,
    0xFFFFCA28,
    0xFFFF7043,
  ];
}
```

### 2. `lib/core/extensions.dart`
```dart
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
```

### 3. `lib/core/theme.dart`
```dart
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _seedColor = Color(0xFF4CAF50);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
```

### 4. `lib/core/core.dart` (barrel export)
```dart
export 'constants.dart';
export 'extensions.dart';
export 'theme.dart';
```

## 완료 조건
- 모든 파일 작성
- `flutter analyze` 경고/에러 없음
