import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/presentation/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeMode_Provider);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          // Appearance section
          _SectionHeader(title: '외관'),
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
                        .read(themeMode_Provider.notifier)
                        .setThemeMode(selected.first);
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 32),

          // Sync section (placeholder)
          _SectionHeader(title: '동기화'),
          const ListTile(
            leading: Icon(Icons.sync),
            title: Text('동기화 설정'),
            subtitle: Text('준비 중입니다'),
            enabled: false,
          ),

          const Divider(height: 32),

          // Account section (placeholder)
          _SectionHeader(title: '계정'),
          const ListTile(
            leading: Icon(Icons.person),
            title: Text('계정 관리'),
            subtitle: Text('준비 중입니다'),
            enabled: false,
          ),
        ],
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
