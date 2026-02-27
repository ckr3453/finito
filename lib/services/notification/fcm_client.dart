abstract class FcmClient {
  Future<String?> getToken({String? vapidKey});

  Stream<String> get onTokenRefresh;

  Future<bool> requestPermission();
}
