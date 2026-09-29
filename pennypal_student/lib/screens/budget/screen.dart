import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../models/budget.dart';
import '../../models/transaction_record.dart';
import '../../utils/app_theme.dart';
import '../../utils/budget_calculator.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/month_picker.dart';
import 'cards.dart';
import 'form_screen.dart';

class BudgetScreen extends StatefulWidget {
  final List<Budget>? initialBudgets;

  final List<TransactionRecord>? transactions;

  const BudgetScreen({super.key, this.initialBudgets, this.transactions});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  List<Budget> _budgets = [];

  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _budgets = _copyBudgets();
  }

  @override
  void didUpdateWidget(covariant BudgetScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialBudgets != oldWidget.initialBudgets) {
      _budgets = _copyBudgets();
    }
  }

  List<Budget> _copyBudgets() {
    final List<Budget>? budgets = widget.initialBudgets;
    if (budgets == null) return [];
    return List.of(budgets);
  }

  List<TransactionRecord> get _transactions {
    return widget.transactions ?? const [];
  }

  String get _monthKey {
    return BudgetCalculator.monthKey(_month);
  }

  double _spentFor(Budget budget) {
    return BudgetCalculator.spent(_transactions, budget.month, categoryId: budget.categoryId);
  }

  Future<void> _openForm({Budget? budget}) async {
    final Object? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BudgetFormScreen(
          month: _month,
          budgets: _budgets,
          transactions: _transactions,
          initial: budget,
        ),
      ),
    );
    if (!mounted || result == null) return;

    setState(() {
      if (result == FormResults.deleted && budget != null) {
        _removeSameKey(budget);
      } else if (result is Budget) {
        _removeSameKey(result);
        _budgets.add(result);
        _month = BudgetCalculator.monthFromKey(result.month);
      }
    });
  }

  void _removeSameKey(Budget target) {
    final List<Budget> kept = [];
    for (final Budget item in _budgets) {
      final bool isSameKey = item.month == target.month && item.categoryId == target.categoryId;
      if (!isSameKey) kept.add(item);
    }
    _budgets = kept;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final Budget? totalBudget = BudgetCalculator.totalBudget(_budgets, _monthKey);
    final List<Budget> categoryBudgets = BudgetCalculator.categoryBudgets(_budgets, _monthKey);
    final Map<Budget, double> spentByBudget = {};
    for (final Budget budget in categoryBudgets) {
      spentByBudget[budget] = _spentFor(budget);
    }
    categoryBudgets.sort((a, b) {
      final int percentA = BudgetCalculator.percent(spentByBudget[a]!, a.limitAmount);
      final int percentB = BudgetCalculator.percent(spentByBudget[b]!, b.limitAmount);
      return percentB.compareTo(percentA);
    });
    final bool isEmpty = totalBudget == null && categoryBudgets.isEmpty;

    Widget totalCard;
    if (totalBudget == null) {
      totalCard = NoTotalBudgetCard(onCreate: () => _openForm());
    } else {
      totalCard = TotalBudgetCard(
        budget: totalBudget,
        spent: _spentFor(totalBudget),
        onTap: () => _openForm(budget: totalBudget),
      );
    }

    final List<Widget> categoryCards = [];
    for (final Budget budget in categoryBudgets) {
      categoryCards.add(Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: CategoryBudgetCard(
          budget: budget,
          spent: spentByBudget[budget]!,
          onTap: () => _openForm(budget: budget),
        ),
      ));
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.navBudget,
                    style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 32, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(52, 52),
                  ),
                  tooltip: l10n.budgetAdd,
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            MonthPicker(
              month: _month,
              onChanged: (month) {
                setState(() {
                  _month = month;
                });
              },
            ),
            const SizedBox(height: 16),
            if (isEmpty)
              EmptyState(
                icon: Icons.account_balance_wallet_outlined,
                message: l10n.budgetEmpty,
                actionLabel: l10n.budgetCreateFirst,
                onAction: () => _openForm(),
              )
            else ...[
              totalCard,
              if (BudgetCalculator.isCategoryTotalOverLimit(_budgets, _monthKey)) ...[
                const SizedBox(height: 12),
                CategoryOverTotalWarning(categoryLimitsTotal: BudgetCalculator.categoryLimitsTotal(_budgets, _monthKey)),
              ],
              if (categoryBudgets.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  l10n.budgetByCategory,
                  style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                ...categoryCards,
              ],
            ],
          ],
        ),
      ),
    );
  }
}
