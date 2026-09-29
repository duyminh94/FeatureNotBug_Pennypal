import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../utils/app_theme.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String message,
  String? title,
  String? confirmLabel,
  bool isDestructive = false,
  IconData? icon,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final Color mainColor = isDestructive ? AppColors.expense : AppColors.textPrimary;

  final bool? result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: icon == null
            ? null
            : Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDestructive ? AppColors.expenseSoft : AppColors.fill,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: mainColor),
                ),
              ),
        title: title == null
            ? null
            : Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 22, fontWeight: FontWeight.w800),
              ),
        content: Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.border, width: 1.5)),
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.commonCancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: mainColor),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(confirmLabel ?? l10n.commonConfirm),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );

  return result ?? false;
}
