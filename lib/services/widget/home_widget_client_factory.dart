import 'package:todo_app/services/widget/home_widget_client.dart';
import 'package:todo_app/services/widget/home_widget_client_native.dart'
    if (dart.library.html) 'package:todo_app/services/widget/home_widget_client_web.dart';

HomeWidgetClient createHomeWidgetClient() => createPlatformHomeWidgetClient();
