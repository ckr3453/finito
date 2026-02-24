import 'package:todo_app/services/widget/home_widget_client.dart';

class NoopHomeWidgetClient implements HomeWidgetClient {
  @override
  Future<bool?> saveWidgetData<T>(String id, T? data) async => true;

  @override
  Future<bool?> updateWidget({
    String? androidName,
    String? iOSName,
    String? qualifiedAndroidName,
  }) async => true;

  @override
  Future<void> registerInteractivityCallback(
    Future<void> Function(Uri?) callback,
  ) async {}
}
