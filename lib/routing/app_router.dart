import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/presentation/screens/home/home_screen.dart';
import 'package:todo_app/presentation/screens/task_editor/task_editor_screen.dart';
import 'package:todo_app/presentation/screens/task_detail/task_detail_screen.dart';
import 'package:todo_app/presentation/screens/categories/categories_screen.dart';
import 'package:todo_app/presentation/screens/search/search_screen.dart';
import 'package:todo_app/presentation/screens/settings/settings_screen.dart';
import 'package:todo_app/presentation/screens/auth/login_screen.dart';
import 'package:todo_app/presentation/screens/auth/register_screen.dart';
import 'package:todo_app/routing/app_shell.dart';

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
    // Auth routes (outside shell - no bottom nav)
    GoRoute(
      path: '/login',
      name: 'login',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const RegisterScreen(),
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
