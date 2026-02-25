import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/core/l10n_extension.dart';
import 'package:todo_app/presentation/providers/auth_provider.dart';

class SyncDisabledBanner extends ConsumerWidget {
  const SyncDisabledBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    if (isAuthenticated) return const SizedBox.shrink();

    final l10n = context.l10n;
    return MaterialBanner(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(
        Icons.cloud_off,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      content: Text(
        l10n.syncDisabledMessage,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      actions: const [SizedBox.shrink()],
    );
  }
}
