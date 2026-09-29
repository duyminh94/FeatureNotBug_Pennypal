import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../models/budget.dart';
import '../../utils/app_theme.dart';
import '../../utils/budget_calculator.dart';
import '../../utils/category_display.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_progress_bar.dart';
import '../../widgets/category_icon.dart';

class BudgetColors {
  static Color bar(BudgetStatus status) {
    return switch (status) {
      BudgetStatus.over => AppColors.expense,
      BudgetStatus.nearLimit => AppColors.honey,
      BudgetStatus.normal => AppColors.mint,
    };
  }

  static Color text(BudgetStatus status) {
    return switch (status) {
      BudgetStatus.over => AppColors.expense,
      BudgetStatus.nearLimit => AppColors.honeyText,
      BudgetStatus.normal => AppColors.primary,
    };
  }
}

class RemainingText extends StatelessWidget {
  final double spent;
  final double limitAmount;
  final BudgetStatus status;

  const RemainingText({super.key, required this.spent, required this.limitAmount, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final double left = BudgetCalculator.remaining(spent, limitAmount);
    String text = l10n.dashBudgetLeft(Formatters.money(left));
    if (left < 0) text = l10n.dashBudgetOver(Formatters.money(-left));

    return Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: BudgetColors.text(status)));
  }
}

class TotalBudgetCard extends StatelessWidget {
  final Budget budget;
  final double spent;
  final VoidCallback onTap;

  const TotalBudgetCard({super.key, required this.budget, required this.spent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final int percent = BudgetCalculator.percent(spent, budget.limitAmount);
    final double left = BudgetCalculator.remaining(spent, budget.limitAmount);
    final BudgetStatus status = BudgetCalculator.status(spent, budget.limitAmount, budget.alertThreshold);
    final bool isOver = left < 0;

    String leftText = l10n.dashBudgetLeft(Formatters.money(left));
    if (isOver) leftText = l10n.dashBudgetOver(Formatters.money(-left));

    return Material(
      color: AppColors.textPrimary,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 96,
                      height: 96,
                      child: CircularProgressIndicator(
                        value: (percent / 100).clamp(0.0, 1.0),
                        strokeWidth: 10,
                        color: BudgetColors.bar(status),
                        backgroundColor: Colors.white24,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.budgetTotal, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textOnDark)),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        Formatters.money(spent),
                        style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                    Text(
                      l10n.budgetOfLimit(Formatters.money(budget.limitAmount)),
                      style: const TextStyle(fontSize: 14, color: AppColors.textOnDark),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOver ? AppColors.expense : AppColors.mint,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        leftText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isOver ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoTotalBudgetCard extends StatelessWidget {
  final VoidCallback onCreate;

  const NoTotalBudgetCard({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
        title: Text(l10n.budgetNoTotal, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        trailing: TextButton(onPressed: onCreate, child: Text(l10n.budgetAdd)),
      ),
    );
  }
}

class CategoryOverTotalWarning extends StatelessWidget {
  final double categoryLimitsTotal;

  const CategoryOverTotalWarning({super.key, required this.categoryLimitsTotal});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.honeySoft, borderRadius: BorderRadius.circular(18)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.honeyText),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.budgetCategoryOverTotal(Formatters.money(categoryLimitsTotal)),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryBudgetCard extends StatelessWidget {
  final Budget budget;
  final double spent;
  final VoidCallback onTap;

  const CategoryBudgetCard({super.key, required this.budget, required this.spent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String categoryId = budget.categoryId!;
    final int percent = BudgetCalculator.percent(spent, budget.limitAmount);
    final BudgetStatus status = BudgetCalculator.status(spent, budget.limitAmount, budget.alertThreshold);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                CategoryDisplay.name(l10n, categoryId),
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                              ),
                            ),
                            if (status != BudgetStatus.normal) _StatusBadge(status: status),
                          ],
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: Formatters.money(spent),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: ' / ${Formatters.money(budget.limitAmount)}',
                                style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppProgressBar(value: percent / 100, color: BudgetColors.bar(status)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: RemainingText(spent: spent, limitAmount: budget.limitAmount, status: status)),
                  Text('$percent%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BudgetStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isOver = status == BudgetStatus.over;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOver ? AppColors.error : AppColors.honeySoft,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 14, color: isOver ? Colors.white : AppColors.honeyText),
          const SizedBox(width: 4),
          Text(
            isOver ? l10n.budgetOverBadge : l10n.budgetNearBadge,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isOver ? Colors.white : AppColors.honeyText),
          ),
        ],
      ),
    );
  }
}
