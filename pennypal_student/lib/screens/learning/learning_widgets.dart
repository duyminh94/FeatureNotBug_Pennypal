import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';

class LearningTag extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;

  const LearningTag({super.key, required this.text, required this.background, required this.foreground});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(99)),
      child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: foreground)),
    );
  }
}

class LevelTag extends StatelessWidget {
  final String text;

  const LevelTag({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return LearningTag(text: text, background: AppColors.mintSoft, foreground: AppColors.primary);
  }
}
