import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:todo_app/core/theme.dart';
import 'package:todo_app/firebase_options.dart';
import 'package:todo_app/presentation/providers/widget_provider.dart';
import 'package:todo_app/routing/app_router.dart';
import 'package:todo_app/services/widget/widget_background_callback.dart';

// Temporary StateProvider for theme mode until theme_provider.dart is generated
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('Running in local-only mode.');
  }

  registerWidgetCallback();

  runApp(const ProviderScope(child: TodoApp()));
}

class TodoApp extends ConsumerStatefulWidget {
  const TodoApp({super.key});

  @override
  ConsumerState<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends ConsumerState<TodoApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _handleWidgetDeepLink();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final widgetSvc = ref.read(widgetServiceProvider);
      widgetSvc.refreshWidget();
    }
  }

  Future<void> _handleWidgetDeepLink() async {
    final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (uri != null) _navigateFromUri(uri);

    HomeWidget.widgetClicked.listen((uri) {
      if (uri != null) _navigateFromUri(uri);
    });
  }

  void _navigateFromUri(Uri uri) {
    final host = uri.host;
    if (host == 'task') {
      final taskId = uri.queryParameters['id'];
      if (taskId != null) {
        appRouter.push('/task/$taskId');
      }
    } else {
      appRouter.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    ref.watch(widgetAutoUpdateProvider);

    return MaterialApp.router(
      title: 'Finito',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
