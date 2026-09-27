import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../models/transaction_record.dart';
import '../utils/app_theme.dart';
import '../utils/category_display.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import 'category_icon.dart';

/// One transaction row: category icon, description, "category · date" (or payment mode) and the signed amount.
class TransactionTile extends StatelessWidget {
  final TransactionRecord transaction;
  final VoidCallback? onTap;
  final bool showPaymentMode;

  const TransactionTile({super.key, required this.transaction, this.onTap, this.showPaymentMode = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String categoryId = transaction.categoryId;
    final bool isIncome = transaction.type == TransactionTypes.income;
    final String categoryName = CategoryDisplay.name(l10n, categoryId);
    final String title = transaction.description.isEmpty ? categoryName : transaction.description;
    final String detailText = showPaymentMode
        ? PaymentModeDisplay.name(l10n, transaction.paymentMode)
        : Formatters.shortDate(transaction.date, todayLabel: l10n.commonToday);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            CategoryIcon(
              iconName: CategoryDisplay.iconName(categoryId),
              color: CategoryDisplay.color(categoryId),
              backgroundColor: CategoryDisplay.softColor(categoryId),
              size: 44,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '$categoryName · $detailText',
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              Formatters.signedMoney(transaction.amount, isIncome: isIncome),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isIncome ? AppColors.income : AppColors.expense,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
