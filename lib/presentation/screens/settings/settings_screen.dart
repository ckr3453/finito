import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/core/l10n_extension.dart';
import 'package:todo_app/presentation/providers/auth_provider.dart';
import 'package:todo_app/presentation/providers/database_provider.dart';
import 'package:todo_app/presentation/providers/locale_provider.dart';
import 'package:todo_app/presentation/providers/notification_provider.dart';
import 'package:todo_app/presentation/providers/sync_providers.dart';
import 'package:todo_app/presentation/providers/theme_provider.dart';
import 'package:todo_app/presentation/providers/user_provider.dart';
import 'package:todo_app/presentation/shared_widgets/user_action_bar.dart';
import 'package:todo_app/services/task_sync_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(appThemeModeProvider);
    final currentLocale = ref.watch(appLocaleProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        actions: [const UserActionBar(), const SizedBox(width: 8)],
      ),
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
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: const Icon(Icons.brightness_auto),
                      label: Text(l10n.themeSystem),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: const Icon(Icons.light_mode),
                      label: Text(l10n.themeLight),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode),
                      label: Text(l10n.themeDark),
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
                SegmentedButton<Locale>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: const Locale('ko'),
                      label: Text(l10n.languageKorean),
                    ),
                    ButtonSegment(
                      value: const Locale('en'),
                      label: Text(l10n.languageEnglish),
                    ),
                  ],
                  selected: {currentLocale ?? const Locale('ko')},
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

          // Notification section (hide on web - not supported)
          if (!kIsWeb) ...[
            _SectionHeader(title: l10n.notifications),
            const _NotificationSection(),
            const Divider(height: 32),
          ],

          // Sync section
          _SectionHeader(title: l10n.sync),
          const _SyncSection(),

          const Divider(height: 32),

          // Admin section (visible only for admins)
          const _AdminSection(),

          // Delete account (only when logged in)
          _DeleteAccountButton(),
        ],
      ),
    );
  }
}

class _DeleteAccountButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(currentUserProvider);

    if (user == null) return const SizedBox.shrink();

    final isEmailUser = user.providerData.any(
      (p) => p.providerId == 'password',
    );

    return ListTile(
      leading: Icon(
        Icons.delete_forever,
        color: Theme.of(context).colorScheme.error,
      ),
      title: Text(
        l10n.deleteAccount,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      onTap: () => _handleDelete(context, ref, isEmailUser),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    bool isEmailUser,
  ) async {
    final l10n = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.deleteAccountConfirm),
            const SizedBox(height: 8),
            Text(
              l10n.deleteAccountWarning,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Reauthenticate
    try {
      final authService = ref.read(authServiceProvider);
      if (isEmailUser) {
        await _reauthEmail(context, ref);
      } else {
        await authService.reauthenticateWithGoogle();
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted && e.code != 'sign-in-cancelled') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.deleteAccountFailed)));
      }
      return;
    }

    if (!context.mounted) return;

    // Execute deletion
    try {
      final authService = ref.read(authServiceProvider);
      final db = ref.read(appDatabaseProvider);
      final userService = ref.read(userServiceProvider);
      final uid = ref.read(currentUserProvider)?.uid;

      // Delete Firestore data (profile + tasks)
      if (uid != null) {
        await userService.deleteUserData(uid);
      }

      // Clear local DB, delete Firebase account
      await db.clearAllData();
      await authService.deleteAccount();

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.accountDeleted)));
        context.go('/login');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.deleteAccountFailed)));
      }
    }
  }

  Future<void> _reauthEmail(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.reauthRequired),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: l10n.email),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? l10n.emailRequired : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: l10n.password),
                obscureText: true,
                validator: (v) =>
                    v == null || v.isEmpty ? l10n.passwordRequired : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: Text(l10n.login),
          ),
        ],
      ),
    );

    final email = emailController.text.trim();
    final password = passwordController.text;
    emailController.dispose();
    passwordController.dispose();

    if (result != true) {
      throw FirebaseAuthException(
        code: 'sign-in-cancelled',
        message: 'Reauthentication cancelled',
      );
    }

    await ref
        .read(authServiceProvider)
        .reauthenticateWithEmail(email: email, password: password);
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

class _AdminSection extends ConsumerWidget {
  const _AdminSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    if (!isAdmin) return const SizedBox.shrink();

    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.admin),
        ListTile(
          leading: const Icon(Icons.admin_panel_settings),
          title: Text(l10n.userManagement),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => GoRouter.of(context).push('/admin'),
        ),
        const Divider(height: 32),
      ],
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
