import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../utils/app_theme.dart';

String supportDate(int? millis, String languageCode) {
  if (millis == null) return '';
  return DateFormat('dd MMM, HH:mm', languageCode).format(DateTime.fromMillisecondsSinceEpoch(millis));
}

class SupportStatusBadge extends StatelessWidget {
  final bool isResolved;

  const SupportStatusBadge({super.key, required this.isResolved});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final Color color = isResolved ? AppColors.primary : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isResolved ? AppColors.primarySoft : const Color(0xFFFFF3C4),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isResolved ? Icons.check : Icons.schedule, size: 16, color: color),
          const SizedBox(width: 4),
          Text(isResolved ? l10n.supportResolved : l10n.supportOpen, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
