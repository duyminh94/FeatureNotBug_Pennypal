import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../models/budget.dart';
import '../../models/savings_goal.dart';
import '../../utils/app_theme.dart';
import '../../utils/budget_calculator.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../utils/goal_calculator.dart';
import '../../widgets/app_progress_bar.dart';
import '../budget/cards.dart';

/// Dark card with the all-time balance and the mascot.
class BalanceCard extends StatelessWidget {
  final double balance;
  final bool hasData;

  const BalanceCard({super.key, required this.balance, required this.hasData});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isNegative = balance < 0;
    final String hint = !hasData ? l10n.dashBalanceEmptyHint : (isNegative ? l10n.dashBalanceNegativeHint : l10n.dashBalanceHint);

    return Container(
      constraints: const BoxConstraints(minHeight: 150),
      decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -6,
            top: 8,
            child: Image.asset(AppAssets.pig, width: 132, height: 122, fit: BoxFit.contain),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, color: AppColors.mint, size: 18),
                    const SizedBox(width: 6),
                    Text(l10n.dashBalance, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  Formatters.money(balance),
                  style: TextStyle(
                    fontFamily: AppFonts.heading,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: isNegative ? AppColors.pink : AppColors.mint,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(right: 110),
                  child: Text(
                    hint,
                    style: TextStyle(color: isNegative ? AppColors.pink : AppColors.textOnDark, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// White card with the monthly total budget and how much is used.
class BudgetCard extends StatelessWidget {
  final Budget budget;
  final double spent;
  final DateTime month;
  final VoidCallback onTap;

  /// Category name when the card shows a category budget; null shows "{month} budget" for the total.
  final String? title;

  const BudgetCard({super.key, required this.budget, required this.spent, required this.month, required this.onTap, this.title});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String languageCode = Localizations.localeOf(context).languageCode;
    final int usedPercent = BudgetCalculator.percent(spent, budget.limitAmount);
    final double usedRatio = usedPercent / 100;
    final double left = BudgetCalculator.remaining(spent, budget.limitAmount);
    final bool isOver = left < 0;
    final Color barColor = BudgetColors.bar(BudgetCalculator.status(spent, budget.limitAmount, budget.alertThreshold));

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _IconBox(icon: Icons.account_balance_wallet_outlined, color: AppColors.primary, background: AppColors.mintSoft),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title ?? l10n.dashBudgetTitle(DateFormat.MMMM(languageCode).format(month)),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
              const SizedBox(height: 14),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: Formatters.money(spent),
                      style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    TextSpan(
                      text: ' / ${Formatters.money(budget.limitAmount)}',
                      style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppProgressBar(value: usedRatio, color: barColor),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isOver ? l10n.dashBudgetOver(Formatters.money(-left)) : l10n.dashBudgetLeft(Formatters.money(left)),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isOver ? AppColors.expense : AppColors.primary,
                      ),
                    ),
                  ),
                  Text(l10n.dashBudgetUsed(usedPercent), style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card shown when the month has no budget yet.
class NoBudgetCard extends StatelessWidget {
  final VoidCallback onCreate;

  const NoBudgetCard({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _IconBox(icon: Icons.account_balance_wallet_outlined, color: AppColors.honeyText, background: AppColors.honeySoft),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.dashNoBudgetTitle, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      Text(l10n.dashNoBudgetBody, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.mintSoft,
                foregroundColor: AppColors.primaryDark,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: onCreate,
              child: Text(l10n.dashCreateBudget),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card with the progress ring of one active savings goal.
class GoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback onTap;

  const GoalCard({super.key, required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Same rounding as the Goals tab (down), so 99.6% is 99% on both screens and 100% only when the goal is done.
    final int percent = GoalCalculator.percentOf(goal.progress);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(
                        value: goal.progress,
                        strokeWidth: 7,
                        color: AppColors.pink,
                        backgroundColor: AppColors.expenseSoft,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text('$percent%', style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 16, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: Formatters.money(goal.currentAmount),
                            style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: ' / ${Formatters.money(goal.targetAmount)}',
                            style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      l10n.dashGoalDeadline(Formatters.monthYear(goal.targetDate)),
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
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

/// One square button of the Shortcuts grid.
class ShortcutButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const ShortcutButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Card shown when the student has no transactions yet.
class NoTransactionsCard extends StatelessWidget {
  final VoidCallback onAddExpense;

  const NoTransactionsCard({super.key, required this.onAddExpense});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.asset(AppAssets.pig, width: 96, height: 88, fit: BoxFit.contain),
            const SizedBox(height: 10),
            Text(
              l10n.dashNoTxTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.dashNoTxBody,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: onAddExpense,
              child: Text(l10n.dashAddExpense),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;

  const _IconBox({required this.icon, required this.color, required this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
