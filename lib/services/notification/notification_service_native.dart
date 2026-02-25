import 'package:todo_app/services/notification/local_notification_client_impl.dart';
import 'package:todo_app/services/notification/notification_service.dart';
import 'package:todo_app/services/notification/notification_service_impl.dart';

NotificationService createPlatformNotificationService() =>
    NotificationServiceImpl(client: LocalNotificationClientImpl());
