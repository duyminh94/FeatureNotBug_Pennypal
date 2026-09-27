import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Rounded progress bar for budgets and goals; value is clamped to 0–1.
class AppProgressBar extends StatelessWidget {
  final double value;
  final Color? color;

  const AppProgressBar({super.key, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final double safeValue = value.isNaN ? 0 : value.clamp(0.0, 1.0);
    // Rounded down like the numbers on screen, so a screen reader never says 100% before the limit or goal is reached.
    final int percent = (safeValue * 100 + 0.0001).floor();

    return Semantics(
      label: '$percent%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: safeValue,
          minHeight: 8,
          color: color ?? Theme.of(context).colorScheme.primary,
          backgroundColor: AppColors.fill,
        ),
      ),
    );
  }
}
