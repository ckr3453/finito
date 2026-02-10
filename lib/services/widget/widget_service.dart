import 'package:todo_app/domain/entities/task_entity.dart';

abstract class WidgetService {
  Future<void> updateWidgetData(List<TaskEntity> tasks);
  Future<void> handleWidgetAction(Uri uri);
  Future<void> refreshWidget();
}
