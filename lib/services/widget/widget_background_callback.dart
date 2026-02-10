import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';
import 'package:todo_app/data/database/app_database.dart';
import 'package:todo_app/data/repositories/local_task_repository.dart';
import 'package:todo_app/services/widget/home_widget_client_impl.dart';
import 'package:todo_app/services/widget/widget_service_impl.dart';

@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  if (uri == null) return;

  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();
  final repository = LocalTaskRepository(database);
  final client = HomeWidgetClientImpl();
  final service = WidgetServiceImpl(client: client, repository: repository);

  await service.handleWidgetAction(uri);

  await database.close();
}

void registerWidgetCallback() {
  HomeWidget.registerInteractivityCallback(widgetBackgroundCallback);
}
