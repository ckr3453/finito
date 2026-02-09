import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:todo_app/services/connectivity_service.dart';

class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityServiceImpl(this._connectivity);

  @override
  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_hasConnection);
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }
}
