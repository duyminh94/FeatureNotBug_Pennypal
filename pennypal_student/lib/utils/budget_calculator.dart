import '../models/budget.dart';
import '../models/transaction_record.dart';
import 'constants.dart';

enum BudgetStatus { normal, nearLimit, over }

class BudgetCalculator {
  static String monthKey(DateTime month) {
    final String monthText = month.month.toString().padLeft(2, '0');
    return '${month.year}-$monthText';
  }

  static DateTime monthFromKey(String month) {
    final List<String> parts = month.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]));
  }

  static double spent(List<TransactionRecord> transactions, String month, {String? categoryId}) {
    double total = 0;
    for (final TransactionRecord transaction in transactions) {
      final bool isSpending = transaction.type == TransactionTypes.expense && transaction.categoryId != CategoryKeys.savings;
      final bool isInMonth = monthKey(DateTime.fromMillisecondsSinceEpoch(transaction.date)) == month;
      final bool isInCategory = categoryId == null || transaction.categoryId == categoryId;
      if (isSpending && isInMonth && isInCategory) total += transaction.amount;
    }
    return total;
  }

  static int percent(double spent, double limitAmount) {
    if (limitAmount <= 0) return 0;
    return (spent * 100 / limitAmount).floor();
  }

  static double remaining(double spent, double limitAmount) {
    return limitAmount - spent;
  }

  static BudgetStatus status(double spent, double limitAmount, int alertThreshold) {
    final int usedPercent = percent(spent, limitAmount);
    if (usedPercent >= 100) return BudgetStatus.over;
    if (usedPercent >= alertThreshold) return BudgetStatus.nearLimit;
    return BudgetStatus.normal;
  }

  static List<Budget> categoryBudgets(List<Budget> budgets, String month) {
    final List<Budget> result = [];
    for (final Budget budget in budgets) {
      if (budget.month == month && !budget.isTotal) result.add(budget);
    }
    return result;
  }

  static Budget? totalBudget(List<Budget> budgets, String month) {
    for (final Budget budget in budgets) {
      if (budget.month == month && budget.isTotal) return budget;
    }
    return null;
  }

  static double categoryLimitsTotal(List<Budget> budgets, String month) {
    double total = 0;
    for (final Budget budget in categoryBudgets(budgets, month)) {
      total += budget.limitAmount;
    }
    return total;
  }

  static bool isCategoryTotalOverLimit(List<Budget> budgets, String month) {
    final Budget? total = totalBudget(budgets, month);
    if (total == null) return false;
    return categoryLimitsTotal(budgets, month) > total.limitAmount;
  }

  static bool isDuplicate(List<Budget> budgets, String month, String? categoryId, {Budget? editing}) {
    for (final Budget budget in budgets) {
      if (budget == editing) continue;
      if (budget.month == month && budget.categoryId == categoryId) return true;
    }
    return false;
  }
}
