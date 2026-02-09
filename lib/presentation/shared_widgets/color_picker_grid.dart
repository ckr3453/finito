import 'package:flutter/material.dart';
import 'package:todo_app/core/constants.dart';

class ColorPickerGrid extends StatelessWidget {
  final int selectedColor;
  final ValueChanged<int> onColorSelected;
  final List<int>? colors;

  const ColorPickerGrid({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final palette = colors ?? AppConstants.categoryColors;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: palette.map((colorValue) {
        final isSelected = colorValue == selectedColor;
        return GestureDetector(
          onTap: () => onColorSelected(colorValue),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(colorValue),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 2,
                    )
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
