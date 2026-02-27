import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/data/database/app_database.dart';
import 'package:todo_app/data/repositories/local_task_repository.dart';
import 'package:todo_app/data/repositories/synced_task_repository.dart';
import 'package:todo_app/presentation/providers/auth_provider.dart';
import 'package:todo_app/presentation/providers/database_provider.dart';
import 'package:todo_app/presentation/providers/repository_providers.dart';
import 'package:todo_app/presentation/providers/sync_providers.dart';
import 'package:todo_app/services/task_sync_service.dart';

class MockLocalTaskRepository extends Mock implements LocalTaskRepository {}

class MockTaskSyncService extends Mock implements TaskSyncService {}

class MockUser extends Mock implements User {}

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late MockLocalTaskRepository mockLocal;
  late MockTaskSyncService mockSyncService;
  late MockAppDatabase mockDb;

  setUp(() {
    mockLocal = MockLocalTaskRepository();
    mockSyncService = MockTaskSyncService();
    mockDb = MockAppDatabase();
    when(() => mockDb.clearAllData()).thenAnswer((_) async {});
  });

  ProviderContainer createContainer({User? user}) {
    return ProviderContainer(
      overrides: [
        localTaskRepositoryProvider.overrideWithValue(mockLocal),
        taskSyncServiceProvider.overrideWithValue(mockSyncService),
        appDatabaseProvider.overrideWithValue(mockDb),
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

    test('로그인 시 clearAllData 후 syncService.start(userId)가 호출된다', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('test-user-123');
      when(() => mockSyncService.start(any())).thenAnswer((_) async {});

      final container = createContainer(user: mockUser);
      addTearDown(container.dispose);

      await container.read(authStateProvider.future);
      container.read(taskRepositoryProvider);

      // clearAllData가 호출되고, 그 후에 start가 호출된다
      verify(() => mockDb.clearAllData()).called(1);

      // clearAllData의 Future가 완료된 후 start가 호출되므로 잠시 대기
      await Future<void>.delayed(Duration.zero);
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
