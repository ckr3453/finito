import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/core/l10n_extension.dart';
import 'package:todo_app/presentation/providers/auth_provider.dart';
import 'package:todo_app/presentation/providers/locale_provider.dart';
import 'package:todo_app/presentation/providers/notification_provider.dart';
import 'package:todo_app/presentation/providers/sync_providers.dart';
import 'package:todo_app/presentation/providers/theme_provider.dart';
import 'package:todo_app/services/task_sync_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(appThemeModeProvider);
    final currentLocale = ref.watch(appLocaleProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          // Appearance section
          _SectionHeader(title: l10n.appearance),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.theme, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(l10n.themeSystem),
                      icon: const Icon(Icons.settings_suggest),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(l10n.themeLight),
                      icon: const Icon(Icons.light_mode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(l10n.themeDark),
                      icon: const Icon(Icons.dark_mode),
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

          // Language section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.language,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SegmentedButton<Locale?>(
                  segments: [
                    ButtonSegment(
                      value: null,
                      label: Text(l10n.languageSystem),
                      icon: const Icon(Icons.settings_suggest),
                    ),
                    ButtonSegment(
                      value: const Locale('ko'),
                      label: Text(l10n.languageKorean),
                    ),
                    ButtonSegment(
                      value: const Locale('en'),
                      label: Text(l10n.languageEnglish),
                    ),
                  ],
                  selected: {currentLocale},
                  onSelectionChanged: (selected) {
                    ref
                        .read(appLocaleProvider.notifier)
                        .setLocale(selected.first);
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 32),

          // Notification section
          _SectionHeader(title: l10n.notifications),
          const _NotificationSection(),

          const Divider(height: 32),

          // Sync section
          _SectionHeader(title: l10n.sync),
          const _SyncSection(),

          const Divider(height: 32),

          // Account section
          _SectionHeader(title: l10n.account),
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
    final l10n = context.l10n;

    if (user == null) {
      return ListTile(
        leading: const Icon(Icons.login),
        title: Text(l10n.login),
        subtitle: Text(l10n.loginPrompt),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/login'),
      );
    }

    return ListTile(
      leading: const Icon(Icons.person),
      title: Text(user.email ?? l10n.user),
      subtitle: Text(l10n.loggedIn),
      trailing: TextButton(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.logout),
              content: Text(l10n.logoutConfirm),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.logout),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            await ref.read(authServiceProvider).signOut();
          }
        },
        child: Text(l10n.logout),
      ),
    );
  }
}

class _SyncSection extends ConsumerWidget {
  const _SyncSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isAuthenticatedProvider);
    final l10n = context.l10n;

    if (!isLoggedIn) {
      return ListTile(
        leading: const Icon(Icons.sync_disabled),
        title: Text(l10n.sync),
        subtitle: Text(l10n.syncDisabledMessage),
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
          title: Text(l10n.syncStatus),
          subtitle: Text(_labelForStatus(status, l10n)),
          trailing: TextButton.icon(
            onPressed: isSyncing
                ? null
                : () => ref.read(taskSyncServiceProvider).syncNow(),
            icon: const Icon(Icons.sync, size: 18),
            label: Text(l10n.syncNow),
          ),
        ),
        if (unsyncedCount > 0)
          ListTile(
            leading: const Icon(Icons.assignment_late),
            title: Text(l10n.syncPending),
            subtitle: Text(l10n.syncPendingCount(unsyncedCount)),
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

  String _labelForStatus(SyncStatus status, dynamic l10n) {
    return switch (status) {
      SyncStatus.idle => l10n.syncIdle as String,
      SyncStatus.syncing => l10n.syncing as String,
      SyncStatus.error => l10n.syncError as String,
      SyncStatus.offline => l10n.syncOffline as String,
    };
  }
}

class _NotificationSection extends ConsumerWidget {
  const _NotificationSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return ListTile(
      leading: const Icon(Icons.notifications),
      title: Text(l10n.notificationPermission),
      subtitle: Text(l10n.notificationPermissionDesc),
      trailing: FilledButton.tonal(
        onPressed: () async {
          final notifSvc = ref.read(notificationServiceProvider);
          final granted = await notifSvc.requestPermission();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  granted ? l10n.permissionGranted : l10n.permissionDenied,
                ),
              ),
            );
          }
        },
        child: Text(l10n.requestPermission),
      ),
    );
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
