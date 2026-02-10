import 'package:home_widget/home_widget.dart';
import 'package:todo_app/services/widget/home_widget_client.dart';

class HomeWidgetClientImpl implements HomeWidgetClient {
  @override
  Future<bool?> saveWidgetData<T>(String id, T? data) {
    return HomeWidget.saveWidgetData(id, data);
  }

  @override
  Future<bool?> updateWidget({
    String? androidName,
    String? iOSName,
    String? qualifiedAndroidName,
  }) {
    return HomeWidget.updateWidget(
      androidName: androidName,
      iOSName: iOSName,
      qualifiedAndroidName: qualifiedAndroidName,
    );
  }

  @override
  Future<void> registerInteractivityCallback(
    Future<void> Function(Uri?) callback,
  ) async {
    HomeWidget.registerInteractivityCallback(callback);
  }
}
