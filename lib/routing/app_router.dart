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
import 'package:todo_app/presentation/screens/admin/admin_screen.dart';
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
    GoRoute(
      path: '/admin',
      name: 'admin',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const AdminScreen(),
    ),
    // Full-screen routes (outside shell)
    GoRoute(
      path: '/task/:id',
      name: 'taskDetail',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        final isWide = MediaQuery.of(context).size.width > 600;
        if (isWide) {
          return DialogPage(
            builder: (_) => TaskDetailScreen(taskId: id),
          );
        }
        return MaterialPage(child: TaskDetailScreen(taskId: id));
      },
    ),
    GoRoute(
      path: '/task-editor',
      name: 'taskEditor',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) {
        final taskId = state.uri.queryParameters['taskId'];
        final isWide = MediaQuery.of(context).size.width > 600;
        if (isWide) {
          return DialogPage(
            builder: (_) => TaskEditorScreen(taskId: taskId),
          );
        }
        return MaterialPage(child: TaskEditorScreen(taskId: taskId));
      },
    ),
  ],
);

class DialogPage extends Page<void> {
  final WidgetBuilder builder;

  const DialogPage({required this.builder, super.key});

  @override
  Route<void> createRoute(BuildContext context) {
    return DialogRoute(
      context: context,
      settings: this,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
          child: builder(context),
        ),
      ),
    );
  }
}
