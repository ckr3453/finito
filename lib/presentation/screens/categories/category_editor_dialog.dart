import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:todo_app/core/constants.dart';
import 'package:todo_app/core/l10n_extension.dart';
import 'package:todo_app/domain/entities/entities.dart';
import 'package:todo_app/presentation/providers/repository_providers.dart';
import 'package:todo_app/presentation/shared_widgets/color_picker_grid.dart';

class CategoryEditorDialog extends ConsumerStatefulWidget {
  final CategoryEntity? category;

  const CategoryEditorDialog({super.key, this.category});

  @override
  ConsumerState<CategoryEditorDialog> createState() =>
      _CategoryEditorDialogState();
}

class _CategoryEditorDialogState extends ConsumerState<CategoryEditorDialog> {
  late final TextEditingController _nameController;
  late int _selectedColor;
  late String _selectedIcon;

  static const _iconOptions = <String, IconData>{
    'folder': Icons.folder,
    'work': Icons.work,
    'home_icon': Icons.home,
    'shopping_cart': Icons.shopping_cart,
    'health': Icons.favorite,
    'study': Icons.school,
    'sports': Icons.sports_soccer,
    'music': Icons.music_note,
    'travel': Icons.flight,
    'food': Icons.restaurant,
    'code': Icons.code,
    'star': Icons.star,
  };

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedColor =
        widget.category?.colorValue ?? AppConstants.categoryColors.first;
    _selectedIcon = widget.category?.iconName ?? 'folder';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(_isEditing ? l10n.editCategory : l10n.addCategory),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.categoryName,
                hintText: l10n.categoryNameHint,
                border: const OutlineInputBorder(),
              ),
              autofocus: !_isEditing,
            ),
            const SizedBox(height: 16),
            Text(l10n.color, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ColorPickerGrid(
              selectedColor: _selectedColor,
              onColorSelected: (color) {
                setState(() => _selectedColor = color);
              },
            ),
            const SizedBox(height: 16),
            Text(l10n.icon, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            _buildIconSelector(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }

  Widget _buildIconSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _iconOptions.entries.map((entry) {
        final isSelected = entry.key == _selectedIcon;
        return GestureDetector(
          onTap: () {
            setState(() => _selectedIcon = entry.key);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: Icon(
              entry.value,
              size: 20,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final repo = ref.read(categoryRepositoryProvider);
    final now = DateTime.now();

    if (_isEditing) {
      final updated = widget.category!.copyWith(
        name: name,
        colorValue: _selectedColor,
        iconName: _selectedIcon,
        updatedAt: now,
      );
      await repo.updateCategory(updated);
    } else {
      final category = CategoryEntity(
        id: const Uuid().v4(),
        name: name,
        colorValue: _selectedColor,
        iconName: _selectedIcon,
        createdAt: now,
        updatedAt: now,
      );
      await repo.createCategory(category);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

/// Helper to map icon name strings to IconData.
IconData categoryIconData(String iconName) {
  const iconMap = <String, IconData>{
    'folder': Icons.folder,
    'work': Icons.work,
    'home_icon': Icons.home,
    'shopping_cart': Icons.shopping_cart,
    'health': Icons.favorite,
    'study': Icons.school,
    'sports': Icons.sports_soccer,
    'music': Icons.music_note,
    'travel': Icons.flight,
    'food': Icons.restaurant,
    'code': Icons.code,
    'star': Icons.star,
  };
  return iconMap[iconName] ?? Icons.folder;
}
