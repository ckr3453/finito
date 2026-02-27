import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:todo_app/services/notification/fcm_client.dart';

class FcmClientImpl implements FcmClient {
  final FirebaseMessaging _messaging;

  FcmClientImpl({FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  @override
  Future<String?> getToken({String? vapidKey}) =>
      _messaging.getToken(vapidKey: vapidKey);

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }
}
