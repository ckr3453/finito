import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/domain/entities/task_entity.dart';
import 'package:todo_app/domain/enums/enums.dart';
import 'package:todo_app/domain/repositories/task_repository.dart';
import 'package:todo_app/services/widget/home_widget_client.dart';
import 'package:todo_app/services/widget/widget_service_impl.dart';

class MockHomeWidgetClient extends Mock implements HomeWidgetClient {}

class MockTaskRepository extends Mock implements TaskRepository {}

class FakeTaskEntity extends Fake implements TaskEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTaskEntity());
  });
  late MockHomeWidgetClient mockClient;
  late MockTaskRepository mockRepository;
  late WidgetServiceImpl service;

  setUp(() {
    mockClient = MockHomeWidgetClient();
    mockRepository = MockTaskRepository();
    service = WidgetServiceImpl(client: mockClient, repository: mockRepository);

    when(
      () => mockClient.saveWidgetData(any(), any<String>()),
    ).thenAnswer((_) async => true);
    when(
      () => mockClient.updateWidget(
        androidName: any(named: 'androidName'),
        iOSName: any(named: 'iOSName'),
        qualifiedAndroidName: any(named: 'qualifiedAndroidName'),
      ),
    ).thenAnswer((_) async => true);
  });

  TaskEntity makeTask({
    required String id,
    required String title,
    TaskStatus status = TaskStatus.pending,
    Priority priority = Priority.medium,
  }) {
    final now = DateTime(2026, 2, 10);
    return TaskEntity(
      id: id,
      title: title,
      status: status,
      priority: priority,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('updateWidgetData', () {
    test('공유 저장소에 JSON 데이터를 저장한다', () async {
      final tasks = [makeTask(id: '1', title: 'Test')];

      await service.updateWidgetData(tasks);

      verify(
        () => mockClient.saveWidgetData('widget_data', any<String>()),
      ).called(1);
    });

    test('저장 후 위젯 갱신을 트리거한다', () async {
      await service.updateWidgetData([]);

      verify(
        () => mockClient.updateWidget(
          androidName: 'TodoSmallWidgetReceiver',
          iOSName: 'TodoWidget',
        ),
      ).called(1);
      verify(
        () => mockClient.updateWidget(
          androidName: 'TodoListWidgetReceiver',
          iOSName: 'TodoWidget',
        ),
      ).called(1);
    });
  });

  group('refreshWidget', () {
    test('Android Small + List 위젯, iOS 위젯 갱신을 요청한다', () async {
      await service.refreshWidget();

      verify(
        () => mockClient.updateWidget(
          androidName: 'TodoSmallWidgetReceiver',
          iOSName: 'TodoWidget',
        ),
      ).called(1);
      verify(
        () => mockClient.updateWidget(
          androidName: 'TodoListWidgetReceiver',
          iOSName: 'TodoWidget',
        ),
      ).called(1);
    });
  });

  group('handleWidgetAction', () {
    test('toggle_complete 액션으로 pending → completed 전환한다', () async {
      final task = makeTask(id: 'task-1', title: 'Test');
      when(
        () => mockRepository.getTaskById('task-1'),
      ).thenAnswer((_) async => task);
      when(() => mockRepository.updateTask(any())).thenAnswer((_) async {});
      when(
        () => mockRepository.watchAllTasks(),
      ).thenAnswer((_) => Stream.value([]));

      final uri = Uri.parse('todoapp://toggle_complete?id=task-1');
      await service.handleWidgetAction(uri);

      final captured = verify(
        () => mockRepository.updateTask(captureAny()),
      ).captured;
      final updated = captured.first as TaskEntity;
      expect(updated.status, TaskStatus.completed);
      expect(updated.completedAt, isNotNull);
    });

    test('toggle_complete 액션으로 completed → pending 전환한다', () async {
      final task = makeTask(
        id: 'task-1',
        title: 'Test',
        status: TaskStatus.completed,
      );
      when(
        () => mockRepository.getTaskById('task-1'),
      ).thenAnswer((_) async => task);
      when(() => mockRepository.updateTask(any())).thenAnswer((_) async {});
      when(
        () => mockRepository.watchAllTasks(),
      ).thenAnswer((_) => Stream.value([]));

      final uri = Uri.parse('todoapp://toggle_complete?id=task-1');
      await service.handleWidgetAction(uri);

      final captured = verify(
        () => mockRepository.updateTask(captureAny()),
      ).captured;
      final updated = captured.first as TaskEntity;
      expect(updated.status, TaskStatus.pending);
      expect(updated.completedAt, isNull);
    });

    test('알 수 없는 액션은 무시한다', () async {
      final uri = Uri.parse('todoapp://unknown_action?id=task-1');
      await service.handleWidgetAction(uri);

      verifyNever(() => mockRepository.getTaskById(any()));
    });

    test('id 파라미터가 없으면 무시한다', () async {
      final uri = Uri.parse('todoapp://toggle_complete');
      await service.handleWidgetAction(uri);

      verifyNever(() => mockRepository.getTaskById(any()));
    });

    test('존재하지 않는 태스크는 무시한다', () async {
      when(
        () => mockRepository.getTaskById('not-found'),
      ).thenAnswer((_) async => null);

      final uri = Uri.parse('todoapp://toggle_complete?id=not-found');
      await service.handleWidgetAction(uri);

      verifyNever(() => mockRepository.updateTask(any()));
    });

    test('토글 후 위젯 데이터를 갱신한다', () async {
      final task = makeTask(id: 'task-1', title: 'Test');
      when(
        () => mockRepository.getTaskById('task-1'),
      ).thenAnswer((_) async => task);
      when(() => mockRepository.updateTask(any())).thenAnswer((_) async {});
      when(
        () => mockRepository.watchAllTasks(),
      ).thenAnswer((_) => Stream.value([task]));

      final uri = Uri.parse('todoapp://toggle_complete?id=task-1');
      await service.handleWidgetAction(uri);

      verify(
        () => mockClient.saveWidgetData('widget_data', any<String>()),
      ).called(1);
    });
  });
}
