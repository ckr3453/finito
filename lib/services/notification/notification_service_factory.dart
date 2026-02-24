import 'package:todo_app/services/notification/notification_service.dart';
import 'package:todo_app/services/notification/notification_service_native.dart'
    if (dart.library.html) 'package:todo_app/services/notification/noop_notification_service.dart';

NotificationService createNotificationService() =>
    createPlatformNotificationService();
