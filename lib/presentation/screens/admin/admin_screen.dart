import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/core/l10n_extension.dart';
import 'package:todo_app/presentation/providers/user_provider.dart';
import 'package:todo_app/services/user_service.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      body: usersAsync.when(
        data: (users) {
          final pending = users.where((u) => !u.approved).length;
          final approved = users.where((u) => u.approved).length;

          return Column(
            children: [
              // Stats
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _StatCard(
                      label: l10n.totalUsers,
                      count: users.length,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: l10n.pendingApproval,
                      count: pending,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: l10n.approvedUsers,
                      count: approved,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // User list grouped by role
              Expanded(
                child: users.isEmpty
                    ? Center(child: Text(l10n.noUsers))
                    : _GroupedUserList(users: users),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _GroupedUserList extends StatelessWidget {
  final List<UserProfile> users;

  const _GroupedUserList({required this.users});

  @override
  Widget build(BuildContext context) {
    final admins = users.where((u) => u.isAdmin).toList();
    final regularUsers = users.where((u) => !u.isAdmin).toList();
    final l10n = context.l10n;

    return ListView(
      children: [
        if (admins.isNotEmpty) ...[
          _SectionHeader(
            title: l10n.admin,
            count: admins.length,
            color: Colors.deepPurple,
          ),
          ...admins.map((u) => _UserTile(user: u)),
        ],
        if (regularUsers.isNotEmpty) ...[
          _SectionHeader(
            title: l10n.user,
            count: regularUsers.length,
            color: Colors.blue,
          ),
          ...regularUsers.map((u) => _UserTile(user: u)),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: color.withValues(alpha: 0.08),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Text(
                '$count',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserTile extends ConsumerWidget {
  final UserProfile user;

  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(userServiceProvider);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: user.approved ? Colors.green : Colors.orange,
        child: Icon(
          user.isAdmin ? Icons.admin_panel_settings : Icons.person,
          color: Colors.white,
        ),
      ),
      title: Text(user.email ?? user.uid),
      subtitle: Text(
        '${user.displayName ?? '-'} / ${_formatDate(user.createdAt)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (user.approved)
            Chip(
              label: Text(
                context.l10n.approved,
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.green.withValues(alpha: 0.1),
              side: const BorderSide(color: Colors.green),
            )
          else ...[
            FilledButton.tonal(
              onPressed: () => service.approveUser(user.uid),
              child: Text(context.l10n.approve),
            ),
            const SizedBox(width: 8),
          ],
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'toggle_approve':
                  if (user.approved) {
                    service.rejectUser(user.uid);
                  } else {
                    service.approveUser(user.uid);
                  }
                case 'toggle_admin':
                  service.toggleAdmin(user.uid, !user.isAdmin);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_approve',
                child: Text(
                  user.approved
                      ? context.l10n.revokeApproval
                      : context.l10n.approve,
                ),
              ),
              PopupMenuItem(
                value: 'toggle_admin',
                child: Text(
                  user.isAdmin
                      ? context.l10n.removeAdmin
                      : context.l10n.makeAdmin,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
