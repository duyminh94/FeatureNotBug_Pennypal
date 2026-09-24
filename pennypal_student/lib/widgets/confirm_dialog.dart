import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Shows a Yes / Cancel dialog and returns true only when the user confirms.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String message,
  String? title,
  String? confirmLabel,
  bool isDestructive = false,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final colors = Theme.of(context).colorScheme;

  final bool? result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: title == null ? null : Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: isDestructive
                ? FilledButton.styleFrom(backgroundColor: colors.error)
                : null,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel ?? l10n.commonConfirm),
          ),
        ],
      );
    },
  );

  // Tapping outside the dialog returns null, which means "not confirmed".
  return result ?? false;
}
