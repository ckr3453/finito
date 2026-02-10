import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/presentation/providers/auth_provider.dart';
import 'package:todo_app/presentation/providers/sync_providers.dart';
import 'package:todo_app/presentation/providers/theme_provider.dart';
import 'package:todo_app/services/task_sync_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(appThemeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          // Appearance section
          const _SectionHeader(title: '외관'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('테마', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('시스템'),
                      icon: Icon(Icons.settings_suggest),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('라이트'),
                      icon: Icon(Icons.light_mode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('다크'),
                      icon: Icon(Icons.dark_mode),
                    ),
                  ],
                  selected: {currentThemeMode},
                  onSelectionChanged: (selected) {
                    ref
                        .read(appThemeModeProvider.notifier)
                        .setThemeMode(selected.first);
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 32),

          // Sync section
          const _SectionHeader(title: '동기화'),
          const _SyncSection(),

          const Divider(height: 32),

          // Account section
          const _SectionHeader(title: '계정'),
          _AccountSection(),
        ],
      ),
    );
  }
}

class _AccountSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return ListTile(
        leading: const Icon(Icons.login),
        title: const Text('로그인'),
        subtitle: const Text('로그인하여 데이터를 동기화하세요'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/login'),
      );
    }

    return ListTile(
      leading: const Icon(Icons.person),
      title: Text(user.email ?? '사용자'),
      subtitle: const Text('로그인됨'),
      trailing: TextButton(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('로그아웃'),
              content: const Text('로그아웃 하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('취소'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('로그아웃'),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            await ref.read(authServiceProvider).signOut();
          }
        },
        child: const Text('로그아웃'),
      ),
    );
  }
}

class _SyncSection extends ConsumerWidget {
  const _SyncSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isAuthenticatedProvider);

    if (!isLoggedIn) {
      return const ListTile(
        leading: Icon(Icons.sync_disabled),
        title: Text('동기화'),
        subtitle: Text('로그인하면 동기화를 사용할 수 있습니다'),
        enabled: false,
      );
    }

    final statusAsync = ref.watch(syncStatusProvider);
    final unsyncedAsync = ref.watch(unsyncedCountProvider);

    final status =
        statusAsync.valueOrNull ??
        ref.read(taskSyncServiceProvider).currentStatus;
    final unsyncedCount =
        unsyncedAsync.valueOrNull ??
        ref.read(taskSyncServiceProvider).currentUnsyncedCount;

    final isSyncing = status == SyncStatus.syncing;

    return Column(
      children: [
        ListTile(
          leading: Icon(_iconForStatus(status)),
          title: const Text('동기화 상태'),
          subtitle: Text(_labelForStatus(status)),
          trailing: TextButton.icon(
            onPressed: isSyncing
                ? null
                : () => ref.read(taskSyncServiceProvider).syncNow(),
            icon: const Icon(Icons.sync, size: 18),
            label: const Text('지금 동기화'),
          ),
        ),
        if (unsyncedCount > 0)
          ListTile(
            leading: const Icon(Icons.assignment_late),
            title: const Text('동기화 대기'),
            subtitle: Text('$unsyncedCount개 항목이 동기화되지 않았습니다'),
          ),
      ],
    );
  }

  IconData _iconForStatus(SyncStatus status) {
    return switch (status) {
      SyncStatus.idle => Icons.cloud_done,
      SyncStatus.syncing => Icons.sync,
      SyncStatus.error => Icons.cloud_off,
      SyncStatus.offline => Icons.wifi_off,
    };
  }

  String _labelForStatus(SyncStatus status) {
    return switch (status) {
      SyncStatus.idle => '동기화 완료',
      SyncStatus.syncing => '동기화 중...',
      SyncStatus.error => '동기화 오류',
      SyncStatus.offline => '오프라인',
    };
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
