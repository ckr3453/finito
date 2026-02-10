abstract class FcmClient {
  Future<String?> getToken();

  Stream<String> get onTokenRefresh;

  Future<bool> requestPermission();
}
