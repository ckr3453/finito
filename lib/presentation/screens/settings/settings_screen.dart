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

          // Notification section (hide on web - not supported)
          if (!kIsWeb) ...[
            _SectionHeader(title: l10n.notifications),
            const _NotificationSection(),
            const Divider(height: 32),
          ] else
            const Divider(height: 0),

          // Sync section
          _SectionHeader(title: l10n.sync),
          const _SyncSection(),

          const Divider(height: 32),

          // Admin section (visible only for admins)
          const _AdminSection(),

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
    final isVerified = ref.watch(isEmailVerifiedProvider);
    final isAnonymous = ref.watch(isAnonymousProvider);
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

    if (isAnonymous) {
      return Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.anonymousUser),
            subtitle: Text(l10n.anonymousDesc),
          ),
          _UpgradeAccountSection(),
        ],
      );
    }

    final isEmailUser = user.providerData.any(
      (p) => p.providerId == 'password',
    );

    return Column(
      children: [
        ListTile(
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
        ),
        if (isEmailUser && !isVerified) _EmailVerificationBanner(),
        _DeleteAccountButton(),
      ],
    );
  }
}

class _EmailVerificationBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.emailNotVerified,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.emailNotVerifiedDesc,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                FilledButton.tonal(
                  onPressed: () async {
                    try {
                      await ref
                          .read(authServiceProvider)
                          .sendEmailVerification();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.verificationEmailSent)),
                        );
                      }
                    } catch (_) {}
                  },
                  child: Text(l10n.sendVerificationEmail),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () async {
                    try {
                      await ref.read(authServiceProvider).reloadUser();
                      ref.invalidate(authStateProvider);
                      if (context.mounted) {
                        final verified = ref
                            .read(authServiceProvider)
                            .isEmailVerified;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              verified
                                  ? l10n.emailVerified
                                  : l10n.emailNotYetVerified,
                            ),
                          ),
                        );
                      }
                    } catch (_) {}
                  },
                  child: Text(l10n.checkVerification),
                ),
              ],
            ),
          ],
        ),
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

class _UpgradeAccountSection extends ConsumerWidget {
  String _mapLinkError(String code, dynamic l10n) {
    return switch (code) {
      'credential-already-in-use' => l10n.firebaseCredentialInUse as String,
      'provider-already-linked' => l10n.firebaseProviderAlreadyLinked as String,
      'invalid-email' => l10n.firebaseInvalidEmail as String,
      'weak-password' => l10n.firebaseWeakPassword as String,
      _ => l10n.accountLinkFailed as String,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.upgradeAccount,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(l10n.upgradeAccountDesc),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => _showLinkEmailDialog(context, ref),
                    child: Text(l10n.linkEmail),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _linkWithGoogle(context, ref),
                    child: Text(l10n.linkGoogle),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLinkEmailDialog(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.linkEmailTitle),
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
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.passwordRequired;
                  if (v.length < 6) return l10n.passwordTooShort;
                  return null;
                },
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
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await ref
            .read(authServiceProvider)
            .linkWithEmail(
              email: emailController.text.trim(),
              password: passwordController.text,
            );
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.accountLinked)));
        }
      } on FirebaseAuthException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(_mapLinkError(e.code, l10n))));
        }
      }
    }

    emailController.dispose();
    passwordController.dispose();
  }

  Future<void> _linkWithGoogle(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    try {
      await ref.read(authServiceProvider).linkWithGoogle();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.accountLinked)));
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted && e.code != 'sign-in-cancelled') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_mapLinkError(e.code, l10n))));
      }
    }
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
