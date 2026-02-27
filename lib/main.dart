import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:todo_app/core/theme.dart';
import 'package:todo_app/firebase_options.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import 'package:todo_app/presentation/providers/locale_provider.dart';
import 'package:todo_app/presentation/providers/notification_provider.dart';
import 'package:todo_app/presentation/providers/theme_provider.dart';
import 'package:todo_app/presentation/providers/widget_provider.dart';
import 'package:todo_app/routing/app_router.dart';
import 'package:todo_app/services/notification/fcm_background_handler.dart';
import 'package:todo_app/services/splash/splash_stub.dart'
    if (dart.library.io) 'package:todo_app/services/splash/splash_native.dart';
import 'package:todo_app/services/widget/widget_callback_stub.dart'
    if (dart.library.io) 'package:todo_app/services/widget/widget_background_callback.dart';
import 'package:todo_app/services/widget/home_widget_deeplink_stub.dart'
    if (dart.library.io) 'package:todo_app/services/widget/home_widget_deeplink.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    preserveSplash(widgetsBinding);
  }

  tz.initializeTimeZones();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Register FCM background handler (Android only, web uses service worker)
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('Running in local-only mode.');
  }

  if (!kIsWeb) {
    registerWidgetCallback();
    removeSplash();
  }

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
    if (!kIsWeb) {
      handleWidgetDeepLink(onUri: _navigateFromUri);
    }
    _initNotifications();
    ref.read(appLocaleProvider.notifier).loadSavedLocale();
    ref.read(appThemeModeProvider.notifier).loadSavedTheme();
  }

  Future<void> _initNotifications() async {
    final notifSvc = ref.read(notificationServiceProvider);
    await notifSvc.initialize(
      onNotificationTap: (payload) {
        if (payload != null) {
          appRouter.push('/task/$payload');
        }
      },
    );

    // Setup FCM message handlers for push notification taps
    final fcmSvc = ref.read(fcmServiceProvider);
    await fcmSvc.setupMessageHandlers(
      onNotificationTap: (taskId) {
        if (taskId != null) {
          appRouter.push('/task/$taskId');
        }
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!kIsWeb && state == AppLifecycleState.resumed) {
      final widgetSvc = ref.read(widgetServiceProvider);
      widgetSvc.refreshWidget();
    }
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
    final themeMode = ref.watch(appThemeModeProvider);
    final locale = ref.watch(appLocaleProvider);
    ref.watch(widgetAutoUpdateProvider);
    ref.watch(reminderAutoRescheduleProvider);
    ref.watch(fcmTokenAutoSaveProvider);

    return MaterialApp.router(
      title: 'Finito',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
    );
  }
}
