import 'package:todo_app/domain/entities/task_entity.dart';
import 'package:todo_app/domain/enums/enums.dart';
import 'package:todo_app/domain/repositories/task_repository.dart';
import 'package:todo_app/services/widget/home_widget_client.dart';
import 'package:todo_app/services/widget/widget_data_converter.dart';
import 'package:todo_app/services/widget/widget_service.dart';

class WidgetServiceImpl implements WidgetService {
  final HomeWidgetClient _client;
  final WidgetDataConverter _converter;
  final TaskRepository? _repository;

  static const _widgetDataKey = 'widget_data';
  static const _androidSmallWidget = 'TodoSmallWidgetReceiver';
  static const _androidListWidget = 'TodoListWidgetReceiver';
  static const _iOSWidgetName = 'TodoWidget';

  WidgetServiceImpl({
    required HomeWidgetClient client,
    WidgetDataConverter? converter,
    TaskRepository? repository,
  })  : _client = client,
        _converter = converter ?? WidgetDataConverter(),
        _repository = repository;

  @override
  Future<void> updateWidgetData(List<TaskEntity> tasks) async {
    final jsonString = _converter.convertToJsonString(tasks, DateTime.now());
    await _client.saveWidgetData(_widgetDataKey, jsonString);
    await refreshWidget();
  }

  @override
  Future<void> handleWidgetAction(Uri uri) async {
    final action = uri.host;
    if (action != 'toggle_complete') return;

    final taskId = uri.queryParameters['id'];
    if (taskId == null || _repository == null) return;

    final task = await _repository.getTaskById(taskId);
    if (task == null) return;

    final toggled = task.copyWith(
      status: task.status == TaskStatus.completed
          ? TaskStatus.pending
          : TaskStatus.completed,
      completedAt: task.status == TaskStatus.completed
          ? null
          : DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _repository.updateTask(toggled);

    final allTasks = await _repository.watchAllTasks().first;
    await updateWidgetData(allTasks);
  }

  @override
  Future<void> refreshWidget() async {
    await _client.updateWidget(
      androidName: _androidSmallWidget,
      iOSName: _iOSWidgetName,
    );
    await _client.updateWidget(
      androidName: _androidListWidget,
      iOSName: _iOSWidgetName,
    );
  }
}
