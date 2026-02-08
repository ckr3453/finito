# Task 06: GoRouter 라우팅 + main.dart

## 의존성
- **Task 04** (테마)
- **Task 05** (Providers) — Provider import 필요

## 목표
GoRouter 설정 + main.dart 엔트리포인트 구성. 앱 셸 구조 (BottomNavigationBar 또는 NavigationRail) 정의.

## 생성할 파일

### 1. `lib/routing/app_router.dart`
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/presentation/screens/home/home_screen.dart';
import 'package:todo_app/presentation/screens/task_editor/task_editor_screen.dart';
import 'package:todo_app/presentation/screens/task_detail/task_detail_screen.dart';
import 'package:todo_app/presentation/screens/categories/categories_screen.dart';
import 'package:todo_app/presentation/screens/search/search_screen.dart';
import 'package:todo_app/presentation/screens/settings/settings_screen.dart';
import 'app_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/categories',
          name: 'categories',
          builder: (context, state) => const CategoriesScreen(),
        ),
        GoRoute(
          path: '/search',
          name: 'search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    // Full-screen routes (outside shell)
    GoRoute(
      path: '/task/:id',
      name: 'taskDetail',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TaskDetailScreen(taskId: id);
      },
    ),
    GoRoute(
      path: '/task-editor',
      name: 'taskEditor',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final taskId = state.uri.queryParameters['taskId'];
        return TaskEditorScreen(taskId: taskId);
      },
    ),
  ],
);
```

### 2. `lib/routing/app_shell.dart`
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/categories')) return 1;
    if (location.startsWith('/search')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: index,
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: (i) => _onTap(context, i),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('홈')),
                NavigationRailDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: Text('카테고리')),
                NavigationRailDestination(icon: Icon(Icons.search), label: Text('검색')),
                NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('설정')),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => _onTap(context, i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: '홈'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: '카테고리'),
          NavigationDestination(icon: Icon(Icons.search), label: '검색'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.goNamed('home');
      case 1: context.goNamed('categories');
      case 2: context.goNamed('search');
      case 3: context.goNamed('settings');
    }
  }
}
```

### 3. `lib/main.dart` (기존 파일 교체)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/core/theme.dart';
import 'package:todo_app/presentation/providers/theme_provider.dart';
import 'package:todo_app/routing/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: TodoApp()));
}

class TodoApp extends ConsumerWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeMode_Provider);

    return MaterialApp.router(
      title: 'TODO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
```

## 완료 조건
- 라우터, 셸, main.dart 작성
- 반응형 레이아웃 (모바일: BottomNav, 데스크탑: NavigationRail)
- `dart run build_runner build` 후 컴파일 에러 없음
- UI 화면 파일이 없어도 placeholder로 빌드 가능하게 할 것

## 주의사항
- 아직 각 Screen이 없을 수 있으므로, 없는 경우 placeholder `Scaffold(body: Center(child: Text('Screen Name')))` 사용
- `themeMode_Provider`는 riverpod_generator가 `ThemeMode_` 클래스에서 생성하는 이름
