import 'package:todo_app/services/notification/fcm_client.dart';
import 'package:todo_app/services/notification/fcm_service.dart';

class FcmServiceImpl implements FcmService {
  final FcmClient _client;

  FcmServiceImpl({required FcmClient client}) : _client = client;

  @override
  Future<String?> getToken() => _client.getToken();

  @override
  Stream<String> get onTokenRefresh => _client.onTokenRefresh;

  @override
  Future<bool> requestPermission() => _client.requestPermission();
}
