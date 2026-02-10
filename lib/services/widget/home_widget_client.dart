abstract class HomeWidgetClient {
  Future<bool?> saveWidgetData<T>(String id, T? data);
  Future<bool?> updateWidget({
    String? androidName,
    String? iOSName,
    String? qualifiedAndroidName,
  });
  Future<void> registerInteractivityCallback(
    Future<void> Function(Uri?) callback,
  );
}
