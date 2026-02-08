import 'package:flutter/material.dart';
import 'package:todo_app/domain/enums/enums.dart';

class PriorityIndicator extends StatelessWidget {
  final Priority priority;
  final double width;
  final double height;

  const PriorityIndicator({
    super.key,
    required this.priority,
    this.width = 4,
    this.height = double.infinity,
  });

  static Color colorFor(Priority priority) {
    return switch (priority) {
      Priority.high => Colors.red,
      Priority.medium => Colors.orange,
      Priority.low => Colors.grey,
    };
  }

  static String labelFor(Priority priority) {
    return switch (priority) {
      Priority.high => '높음',
      Priority.medium => '보통',
      Priority.low => '낮음',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorFor(priority),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
