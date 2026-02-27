import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/data/database/app_database.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import 'package:todo_app/presentation/providers/auth_provider.dart';
import 'package:todo_app/presentation/providers/database_provider.dart';
import 'package:todo_app/presentation/providers/sync_providers.dart';
import 'package:todo_app/presentation/shared_widgets/user_action_bar.dart';
import 'package:todo_app/services/auth_service.dart';
import 'package:todo_app/services/task_sync_service.dart';

class MockUser extends Mock implements User {}

class MockAuthService extends Mock implements AuthService {}

class MockTaskSyncService extends Mock implements TaskSyncService {}

class MockAppDatabase extends Mock implements AppDatabase {}

class MockUserInfo extends Mock implements UserInfo {}

Widget buildSubject({required List<Override> overrides}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('ko'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        appBar: AppBar(
          actions: const [UserActionBar(), SizedBox(width: 8)],
        ),
      ),
    ),
  );
}

void main() {
  late MockUser mockUser;
  late MockAuthService mockAuthService;
  late MockTaskSyncService mockSyncService;
  late MockAppDatabase mockDb;

  setUp(() {
    mockUser = MockUser();
    mockAuthService = MockAuthService();
    mockSyncService = MockTaskSyncService();
    mockDb = MockAppDatabase();

    when(() => mockUser.displayName).thenReturn('Test User');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockUser.photoURL).thenReturn(null);
    when(() => mockUser.uid).thenReturn('test-uid');
    when(() => mockUser.providerData).thenReturn([]);
    when(() => mockDb.clearAllData()).thenAnswer((_) async {});
    when(() => mockAuthService.signOut()).thenAnswer((_) async {});
  });

  group('UserActionBar', () {
    testWidgets('비로그인 시 로그인 버튼을 표시한다', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => Stream<User?>.value(null),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('로그인'), findsOneWidget);
      expect(find.byIcon(Icons.login), findsOneWidget);
    });

    testWidgets('로그인 시 사용자 이름과 로그아웃 버튼을 표시한다', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => Stream<User?>.value(mockUser),
            ),
            authServiceProvider.overrideWithValue(mockAuthService),
            taskSyncServiceProvider.overrideWithValue(mockSyncService),
            appDatabaseProvider.overrideWithValue(mockDb),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test User'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('로그아웃 버튼 클릭 시 확인 다이얼로그를 표시한다', (tester) async {
      when(() => mockSyncService.currentUnsyncedCount).thenReturn(0);

      await tester.pumpWidget(
        buildSubject(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => Stream<User?>.value(mockUser),
            ),
            authServiceProvider.overrideWithValue(mockAuthService),
            taskSyncServiceProvider.overrideWithValue(mockSyncService),
            appDatabaseProvider.overrideWithValue(mockDb),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(find.text('로그아웃'), findsNWidgets(2)); // title + button
      expect(find.text('로그아웃 하시겠습니까?'), findsOneWidget);
    });

    testWidgets('미동기화 항목이 있으면 경고 메시지를 표시한다', (tester) async {
      when(() => mockSyncService.currentUnsyncedCount).thenReturn(3);

      await tester.pumpWidget(
        buildSubject(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => Stream<User?>.value(mockUser),
            ),
            authServiceProvider.overrideWithValue(mockAuthService),
            taskSyncServiceProvider.overrideWithValue(mockSyncService),
            appDatabaseProvider.overrideWithValue(mockDb),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('동기화되지 않은 변경사항이 3건'),
        findsOneWidget,
      );
    });

    testWidgets('로그아웃 확인 시 clearAllData와 signOut이 호출된다', (tester) async {
      when(() => mockSyncService.currentUnsyncedCount).thenReturn(0);

      await tester.pumpWidget(
        buildSubject(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => Stream<User?>.value(mockUser),
            ),
            authServiceProvider.overrideWithValue(mockAuthService),
            taskSyncServiceProvider.overrideWithValue(mockSyncService),
            appDatabaseProvider.overrideWithValue(mockDb),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // 로그아웃 버튼 클릭
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      // 다이얼로그에서 로그아웃 확인 (FilledButton)
      await tester.tap(find.widgetWithText(FilledButton, '로그아웃'));
      await tester.pumpAndSettle();

      verify(() => mockDb.clearAllData()).called(1);
      verify(() => mockAuthService.signOut()).called(1);
    });

    testWidgets('로그아웃 취소 시 clearAllData와 signOut이 호출되지 않는다',
        (tester) async {
      when(() => mockSyncService.currentUnsyncedCount).thenReturn(0);

      await tester.pumpWidget(
        buildSubject(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => Stream<User?>.value(mockUser),
            ),
            authServiceProvider.overrideWithValue(mockAuthService),
            taskSyncServiceProvider.overrideWithValue(mockSyncService),
            appDatabaseProvider.overrideWithValue(mockDb),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // 로그아웃 버튼 클릭
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      // 다이얼로그에서 취소
      await tester.tap(find.widgetWithText(TextButton, '취소'));
      await tester.pumpAndSettle();

      verifyNever(() => mockDb.clearAllData());
      verifyNever(() => mockAuthService.signOut());
    });

    testWidgets('displayName이 없으면 email을 표시한다', (tester) async {
      when(() => mockUser.displayName).thenReturn(null);

      await tester.pumpWidget(
        buildSubject(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => Stream<User?>.value(mockUser),
            ),
            authServiceProvider.overrideWithValue(mockAuthService),
            taskSyncServiceProvider.overrideWithValue(mockSyncService),
            appDatabaseProvider.overrideWithValue(mockDb),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('test@example.com'), findsOneWidget);
    });
  });
}
