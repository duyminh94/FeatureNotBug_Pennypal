import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class ErrorBanner extends StatelessWidget {
  final String message;

  const ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.expenseSoft, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class ButtonProgress extends StatelessWidget {
  const ButtonProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white));
  }
}
