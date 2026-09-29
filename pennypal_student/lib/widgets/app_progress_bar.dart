import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class AppProgressBar extends StatelessWidget {
  final double value;
  final Color? color;

  const AppProgressBar({super.key, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final double safeValue = value.isNaN ? 0 : value.clamp(0.0, 1.0);
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
