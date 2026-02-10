import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/data/repositories/local_task_repository.dart';
import 'package:todo_app/data/repositories/synced_task_repository.dart';
import 'package:todo_app/presentation/providers/auth_provider.dart';
import 'package:todo_app/presentation/providers/repository_providers.dart';
import 'package:todo_app/presentation/providers/sync_providers.dart';
import 'package:todo_app/services/task_sync_service.dart';

class MockLocalTaskRepository extends Mock implements LocalTaskRepository {}

class MockTaskSyncService extends Mock implements TaskSyncService {}

class MockUser extends Mock implements User {}

void main() {
  late MockLocalTaskRepository mockLocal;
  late MockTaskSyncService mockSyncService;

  setUp(() {
    mockLocal = MockLocalTaskRepository();
    mockSyncService = MockTaskSyncService();
  });

  ProviderContainer createContainer({User? user}) {
    return ProviderContainer(
      overrides: [
        localTaskRepositoryProvider.overrideWithValue(mockLocal),
        taskSyncServiceProvider.overrideWithValue(mockSyncService),
        authStateProvider.overrideWith(
          (ref) => user == null
              ? Stream<User?>.value(null)
              : Stream<User?>.value(user),
        ),
      ],
    );
  }

  group('taskRepositoryProvider', () {
    test('비로그인 시 LocalTaskRepository를 반환한다', () async {
      final container = createContainer(user: null);
      addTearDown(container.dispose);

      // authStateProvider가 Stream이므로 값이 전파될 때까지 대기
      await container.read(authStateProvider.future);

      final repository = container.read(taskRepositoryProvider);

      expect(repository, isA<LocalTaskRepository>());
      expect(repository, same(mockLocal));
    });

    test('로그인 시 SyncedTaskRepository를 반환한다', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('test-user-123');
      when(() => mockSyncService.start(any())).thenAnswer((_) async {});

      final container = createContainer(user: mockUser);
      addTearDown(container.dispose);

      await container.read(authStateProvider.future);

      final repository = container.read(taskRepositoryProvider);

      expect(repository, isA<SyncedTaskRepository>());
    });

    test('로그인 시 syncService.start(userId)가 호출된다', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('test-user-123');
      when(() => mockSyncService.start(any())).thenAnswer((_) async {});

      final container = createContainer(user: mockUser);
      addTearDown(container.dispose);

      await container.read(authStateProvider.future);
      container.read(taskRepositoryProvider);

      verify(() => mockSyncService.start('test-user-123')).called(1);
    });

    test('SyncedTaskRepository가 올바른 local과 syncService를 갖는다', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('test-user-123');
      when(() => mockSyncService.start(any())).thenAnswer((_) async {});

      final container = createContainer(user: mockUser);
      addTearDown(container.dispose);

      await container.read(authStateProvider.future);

      final repository =
          container.read(taskRepositoryProvider) as SyncedTaskRepository;

      expect(repository.syncService, same(mockSyncService));
    });
  });

  group('localTaskRepositoryProvider', () {
    test('항상 LocalTaskRepository 인스턴스를 반환한다', () {
      final container = ProviderContainer(
        overrides: [localTaskRepositoryProvider.overrideWithValue(mockLocal)],
      );
      addTearDown(container.dispose);

      final repository = container.read(localTaskRepositoryProvider);

      expect(repository, isA<LocalTaskRepository>());
      expect(repository, same(mockLocal));
    });
  });
}
