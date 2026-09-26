import '../models/budget.dart';
import '../models/transaction_record.dart';
import 'constants.dart';

/// Color state of a budget bar: normal, close to the limit (warning) or over the limit.
enum BudgetStatus { normal, nearLimit, over }

/// Budget rules: how much was spent in a month, how much is left and when to warn.
class BudgetCalculator {
  /// Month key used in the database, e.g. September 2026 -> "2026-09".
  static String monthKey(DateTime month) {
    final String monthText = month.month.toString().padLeft(2, '0');
    return '${month.year}-$monthText';
  }

  /// Turns a key like "2026-09" back into the first day of that month.
  static DateTime monthFromKey(String month) {
    final List<String> parts = month.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]));
  }

  /// Money spent in [month]. Only expenses count; money put into savings goals is not spending.
  /// With [categoryId] only that category is counted, without it the whole month is counted.
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

  /// Percent of the limit already spent, rounded. A limit of 0 gives 0 instead of dividing by zero.
  static int percent(double spent, double limitAmount) {
    if (limitAmount <= 0) return 0;
    return (spent / limitAmount * 100).round();
  }

  /// Money left before the limit; negative means the student is over budget.
  static double remaining(double spent, double limitAmount) {
    return limitAmount - spent;
  }

  /// Over at 100% or more, warning from the student's alert threshold (80% by default), otherwise normal.
  static BudgetStatus status(double spent, double limitAmount, int alertThreshold) {
    final int usedPercent = percent(spent, limitAmount);
    if (usedPercent >= 100) return BudgetStatus.over;
    if (usedPercent >= alertThreshold) return BudgetStatus.nearLimit;
    return BudgetStatus.normal;
  }

  /// Budgets set per category in [month] (the monthly total budget is left out).
  static List<Budget> categoryBudgets(List<Budget> budgets, String month) {
    final List<Budget> result = [];
    for (final Budget budget in budgets) {
      if (budget.month == month && !budget.isTotal) result.add(budget);
    }
    return result;
  }

  /// The total budget of [month], or null when the student has not set one.
  static Budget? totalBudget(List<Budget> budgets, String month) {
    for (final Budget budget in budgets) {
      if (budget.month == month && budget.isTotal) return budget;
    }
    return null;
  }

  /// Sum of all category limits in [month].
  static double categoryLimitsTotal(List<Budget> budgets, String month) {
    double total = 0;
    for (final Budget budget in categoryBudgets(budgets, month)) {
      total += budget.limitAmount;
    }
    return total;
  }

  /// True when the category limits add up to more than the total budget, so the screen can warn.
  static bool isCategoryTotalOverLimit(List<Budget> budgets, String month) {
    final Budget? total = totalBudget(budgets, month);
    if (total == null) return false;
    return categoryLimitsTotal(budgets, month) > total.limitAmount;
  }

  /// Only one budget per category (and one total) per month.
  /// When editing, the budget being edited does not count as a duplicate of itself.
  static bool isDuplicate(List<Budget> budgets, String month, String? categoryId, {Budget? editing}) {
    for (final Budget budget in budgets) {
      if (budget == editing) continue;
      if (budget.month == month && budget.categoryId == categoryId) return true;
    }
    return false;
  }
}
