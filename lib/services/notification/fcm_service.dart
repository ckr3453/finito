abstract class FcmService {
  Future<String?> getToken();

  Stream<String> get onTokenRefresh;

  Future<bool> requestPermission();
}
