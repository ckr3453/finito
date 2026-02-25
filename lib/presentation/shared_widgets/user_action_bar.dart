import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/core/l10n_extension.dart';
import 'package:todo_app/presentation/providers/auth_provider.dart';

class UserActionBar extends ConsumerWidget {
  const UserActionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      final l10n = context.l10n;
      return TextButton.icon(
        onPressed: () => context.pushNamed('login'),
        icon: const Icon(Icons.login, size: 18),
        label: Text(l10n.login),
      );
    }

    return const _LoggedInBar();
  }
}

class _LoggedInBar extends ConsumerWidget {
  const _LoggedInBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();

    final displayName = user.displayName ?? user.email ?? '';
    final l10n = context.l10n;
    final photoUrl = user.photoURL;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (photoUrl != null && photoUrl.isNotEmpty)
          CircleAvatar(radius: 12, backgroundImage: NetworkImage(photoUrl))
        else
          const CircleAvatar(radius: 12, child: Icon(Icons.person, size: 16)),
        const SizedBox(width: 6),
        Text(displayName, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 2),
        IconButton(
          tooltip: l10n.logout,
          icon: const Icon(Icons.logout, size: 18),
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
        ),
      ],
    );
  }
}
