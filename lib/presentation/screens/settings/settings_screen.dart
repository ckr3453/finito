import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/presentation/providers/auth_provider.dart';
import 'package:todo_app/presentation/providers/theme_provider.dart';

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

          // Sync section (placeholder)
          const _SectionHeader(title: '동기화'),
          const ListTile(
            leading: Icon(Icons.sync),
            title: Text('동기화 설정'),
            subtitle: Text('준비 중입니다'),
            enabled: false,
          ),

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
