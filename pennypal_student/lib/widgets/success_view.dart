import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../utils/constants.dart';

class SuccessView extends StatelessWidget {
  final String title;
  final String message;
  final Widget? extra;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  const SuccessView({
    super.key,
    required this.title,
    required this.message,
    this.extra,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final Widget? extraWidget = extra;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            children: [
              Center(
                child: SizedBox(
                  width: 190,
                  height: 190,
                  child: Stack(
                    children: [
                      Container(
                        width: 190,
                        height: 190,
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(color: AppColors.mintSoft, shape: BoxShape.circle),
                        child: Image.asset(AppAssets.pig, fit: BoxFit.contain),
                      ),
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.mint,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.surface, width: 4),
                          ),
                          child: const Icon(Icons.check, size: 30, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
              if (extraWidget != null) ...[
                const SizedBox(height: 20),
                extraWidget,
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              children: [
                FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
                const SizedBox(height: 10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    side: const BorderSide(color: AppColors.border, width: 1.5),
                  ),
                  onPressed: onSecondary,
                  child: Text(secondaryLabel),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
