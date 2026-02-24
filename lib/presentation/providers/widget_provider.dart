import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/presentation/providers/repository_providers.dart';
import 'package:todo_app/services/widget/home_widget_client_factory.dart';
import 'package:todo_app/services/widget/widget_service.dart';
import 'package:todo_app/services/widget/widget_service_impl.dart';

part 'widget_provider.g.dart';

@Riverpod(keepAlive: true)
WidgetService widgetService(Ref ref) {
  final service = WidgetServiceImpl(
    client: createHomeWidgetClient(),
    repository: ref.watch(taskRepositoryProvider),
  );
  return service;
}

@Riverpod(keepAlive: true)
Stream<void> widgetAutoUpdate(Ref ref) async* {
  final widgetSvc = ref.watch(widgetServiceProvider);
  final repo = ref.watch(taskRepositoryProvider);

  await for (final tasks in repo.watchAllTasks()) {
    await widgetSvc.updateWidgetData(tasks);
    yield null;
  }
}
