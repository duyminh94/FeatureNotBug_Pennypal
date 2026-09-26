import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../utils/app_theme.dart';

class SupportStatusBadge extends StatelessWidget {
  final bool isResolved;

  const SupportStatusBadge({super.key, required this.isResolved});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final Color foreground = isResolved ? AppColors.primary : AppColors.honeyText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isResolved ? AppColors.mintSoft : AppColors.honeySoft,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isResolved ? Icons.check : Icons.schedule, size: 16, color: foreground),
          const SizedBox(width: 4),
          Text(
            isResolved ? l10n.supportReplied : l10n.supportWaiting,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: foreground),
          ),
        ],
      ),
    );
  }
}
