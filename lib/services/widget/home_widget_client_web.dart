import 'package:todo_app/services/widget/home_widget_client.dart';
import 'package:todo_app/services/widget/noop_home_widget_client.dart';

HomeWidgetClient createPlatformHomeWidgetClient() => NoopHomeWidgetClient();
