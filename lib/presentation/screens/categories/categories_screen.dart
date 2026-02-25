import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/core/l10n_extension.dart';
import 'package:todo_app/domain/entities/entities.dart';
import 'package:todo_app/presentation/providers/category_providers.dart';
import 'package:todo_app/presentation/providers/filter_providers.dart';
import 'package:todo_app/presentation/providers/repository_providers.dart';
import 'package:todo_app/presentation/screens/categories/category_editor_dialog.dart';
import 'package:todo_app/presentation/shared_widgets/empty_state.dart';
import 'package:todo_app/presentation/shared_widgets/sync_disabled_banner.dart';
import 'package:todo_app/presentation/shared_widgets/user_action_bar.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categories),
        actions: [const UserActionBar(), const SizedBox(width: 8)],
      ),
      body: Column(
        children: [
          const SyncDisabledBanner(),
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return EmptyState(
                    icon: Icons.folder_off,
                    message: l10n.emptyCategoryMessage,
                    actionLabel: l10n.addCategory,
                    onAction: () => _showEditorDialog(context),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _CategoryTile(category: category);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text(l10n.errorOccurred(error.toString()))),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditorDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CategoryEditorDialog(),
    );
  }
}

class _CategoryTile extends ConsumerWidget {
  final CategoryEntity category;

  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Color(category.colorValue).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          categoryIconData(category.iconName),
          color: Color(category.colorValue),
        ),
      ),
      title: Text(category.name),
      trailing: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: Color(category.colorValue),
          shape: BoxShape.circle,
        ),
      ),
      onTap: () {
        ref.read(taskFilterProvider.notifier).setCategoryId(category.id);
        context.goNamed('home');
      },
      onLongPress: () => _showOptions(context, ref),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(l10n.edit),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) =>
                        CategoryEditorDialog(category: category),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  l10n.delete,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, ref);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCategoryTitle),
        content: Text(l10n.deleteCategoryConfirm(category.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(categoryRepositoryProvider).deleteCategory(category.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
