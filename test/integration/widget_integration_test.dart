import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/domain/entities/task_entity.dart';
import 'package:todo_app/domain/enums/enums.dart';
import 'package:todo_app/domain/repositories/task_repository.dart';
import 'package:todo_app/services/widget/home_widget_client.dart';
import 'package:todo_app/services/widget/widget_data_converter.dart';
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
    DateTime? dueDate,
  }) {
    final now = DateTime(2026, 2, 10);
    return TaskEntity(
      id: id,
      title: title,
      status: status,
      priority: priority,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('E2E: Task CRUD → Widget 갱신 흐름', () {
    test('태스크 리스트 업데이트 시 위젯 데이터가 올바르게 변환되어 저장된다', () async {
      final tasks = [
        makeTask(
          id: '1',
          title: 'High task',
          priority: Priority.high,
          dueDate: DateTime(2026, 2, 10),
        ),
        makeTask(id: '2', title: 'Medium task', priority: Priority.medium),
        makeTask(id: '3', title: 'Low task', priority: Priority.low),
        makeTask(id: '4', title: 'Completed', status: TaskStatus.completed),
      ];

      await service.updateWidgetData(tasks);

      final captured = verify(
        () => mockClient.saveWidgetData<String>('widget_data', captureAny()),
      ).captured;
      final jsonString = captured.first as String;

      expect(jsonString, contains('"todayCount":1'));
      expect(jsonString, contains('"High task"'));
      expect(jsonString, contains('"Medium task"'));
      expect(jsonString, contains('"Low task"'));
      expect(jsonString, isNot(contains('"Completed"')));
    });

    test('위젯 체크박스 토글 → DB 업데이트 → 위젯 갱신 전체 흐름', () async {
      final task = makeTask(id: 'task-1', title: 'Do something');

      when(
        () => mockRepository.getTaskById('task-1'),
      ).thenAnswer((_) async => task);
      when(() => mockRepository.updateTask(any())).thenAnswer((_) async {});
      when(() => mockRepository.watchAllTasks()).thenAnswer(
        (_) => Stream.value([
          task.copyWith(
            status: TaskStatus.completed,
            completedAt: DateTime.now(),
          ),
        ]),
      );

      // 1. 위젯에서 토글 액션 수신
      await service.handleWidgetAction(
        Uri.parse('todoapp://toggle_complete?id=task-1'),
      );

      // 2. DB에 업데이트 호출 확인
      final updatedTask =
          verify(() => mockRepository.updateTask(captureAny())).captured.first
              as TaskEntity;
      expect(updatedTask.status, TaskStatus.completed);

      // 3. 위젯 데이터 갱신 호출 확인
      verify(
        () => mockClient.saveWidgetData('widget_data', any<String>()),
      ).called(1);

      // 4. 위젯 UI 갱신 트리거 확인
      verify(
        () => mockClient.updateWidget(
          androidName: 'TodoSmallWidgetReceiver',
          iOSName: 'TodoWidget',
        ),
      ).called(1);
    });

    test('WidgetDataConverter 변환 결과가 위젯 JSON 스펙과 일치한다', () {
      final converter = WidgetDataConverter();
      final now = DateTime(2026, 2, 10, 14, 30);
      final tasks = [
        makeTask(
          id: 'uuid-1',
          title: '프로젝트 보고서 작성',
          priority: Priority.high,
          dueDate: DateTime(2026, 2, 10),
        ),
        makeTask(
          id: 'uuid-2',
          title: '팀 미팅 준비',
          priority: Priority.medium,
          dueDate: DateTime(2026, 2, 10),
        ),
      ];

      final result = converter.convert(tasks, now);

      expect(result['todayCount'], 2);
      expect((result['tasks'] as List).length, 2);

      final first = (result['tasks'] as List)[0];
      expect(first['id'], 'uuid-1');
      expect(first['title'], '프로젝트 보고서 작성');
      expect(first['priority'], 'high');
      expect(first['dueDate'], '2026-02-10');
      expect(first['completed'], false);

      expect(result['lastUpdated'], '2026-02-10T14:30:00.000');
    });
  });
}
