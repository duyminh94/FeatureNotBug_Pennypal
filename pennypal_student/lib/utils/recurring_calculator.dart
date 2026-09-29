import '../models/recurring_item.dart';
import '../models/savings_goal.dart';
import '../models/transaction_record.dart';
import 'budget_calculator.dart';
import 'constants.dart';
import 'goal_calculator.dart';

class RecurringCalculator {
  static DateTime dateInMonth(DateTime month, int dayOfMonth) {
    final int lastDay = DateTime(month.year, month.month + 1, 0).day;
    int day = dayOfMonth;
    if (day < 1) day = 1;
    if (day > lastDay) day = lastDay;
    return DateTime(month.year, month.month, day);
  }

  static List<DateTime> datesToCreate(RecurringItem item, DateTime now) {
    if (!item.isActive) return [];
    if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(item.lastCreatedMonth)) return [];

    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime lastMonth = BudgetCalculator.monthFromKey(item.lastCreatedMonth);
    DateTime month = DateTime(lastMonth.year, lastMonth.month + 1);

    final List<DateTime> dates = [];
    while (true) {
      final DateTime date = dateInMonth(month, item.dayOfMonth);
      if (date.isAfter(today)) break;
      dates.add(date);
      month = DateTime(month.year, month.month + 1);
    }
    return dates;
  }

  static String monthKeyOnResume(RecurringItem item, DateTime now) {
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime thisMonthDate = dateInMonth(DateTime(now.year, now.month), item.dayOfMonth);

    String resumeMonth = BudgetCalculator.monthKey(today);
    if (thisMonthDate.isAfter(today)) resumeMonth = BudgetCalculator.monthKey(DateTime(now.year, now.month - 1));

    if (item.lastCreatedMonth.compareTo(resumeMonth) > 0) return item.lastCreatedMonth;
    return resumeMonth;
  }

  static String transactionId(String itemId, DateTime date) {
    return 'rec_${itemId}_${BudgetCalculator.monthKey(date)}';
  }

  static Map<String, Object?> dueChanges(String uid, List<RecurringItem> items, DateTime now) {
    final Map<String, Object?> changes = {};
    final int createdAt = now.millisecondsSinceEpoch;

    for (final RecurringItem item in items) {
      if (item.isGoalContribution) continue;
      final List<DateTime> dates = datesToCreate(item, now);
      if (dates.isEmpty) continue;

      for (final DateTime date in dates) {
        final TransactionRecord transaction = buildTransaction(item, date, createdAt);
        changes['${DbNodes.transactions}/$uid/${transaction.id}'] = transaction.toMap();
      }
      changes['${DbNodes.recurring}/$uid/${item.id}/${DbFields.lastCreatedMonth}'] = BudgetCalculator.monthKey(dates.last);
    }
    return changes;
  }

  static String goalItemId(String goalId) => 'goal_$goalId';

  static RecurringItem newGoalItem(SavingsGoal goal, String description, DateTime now) {
    return RecurringItem(
      id: goalItemId(goal.id),
      type: TransactionTypes.expense,
      amount: goal.monthlyContribution,
      categoryId: CategoryKeys.savings,
      description: description,
      goalId: goal.id,
      dayOfMonth: now.day,
      lastCreatedMonth: BudgetCalculator.monthKey(now),
      createdAt: now.millisecondsSinceEpoch,
    );
  }

  static Map<String, Object?> goalItemUpdate(RecurringItem existing, SavingsGoal goal, String description, bool wantsAuto, DateTime now) {
    if (!wantsAuto) {
      if (!existing.isActive) return {};
      return {DbFields.isActive: false};
    }

    final Map<String, Object?> fields = {
      DbFields.amount: goal.monthlyContribution,
      DbFields.description: description,
    };
    if (!existing.isActive) {
      fields[DbFields.isActive] = true;
      fields[DbFields.lastCreatedMonth] = monthKeyOnResume(existing, now);
    }
    return fields;
  }

  static GoalAutoContribution goalContributions(RecurringItem item, SavingsGoal? goal, DateTime now) {
    final List<DateTime> dates = datesToCreate(item, now);
    if (dates.isEmpty) return GoalAutoContribution(contributions: [], goal: goal, lastCreatedMonth: item.lastCreatedMonth, stopItem: false);

    final String lastCreatedMonth = BudgetCalculator.monthKey(dates.last);
    if (goal == null || !goal.isActive) {
      return GoalAutoContribution(contributions: [], goal: goal, lastCreatedMonth: lastCreatedMonth, stopItem: true);
    }

    final int createdAt = now.millisecondsSinceEpoch;
    final List<TransactionRecord> contributions = [];
    SavingsGoal updatedGoal = goal;
    for (final DateTime date in dates) {
      if (!updatedGoal.isActive) break;

      double amount = item.amount;
      if (amount > updatedGoal.remainingAmount) amount = updatedGoal.remainingAmount;
      contributions.add(buildTransaction(item, date, createdAt, amount: amount));
      updatedGoal = GoalCalculator.changeCurrentAmount(updatedGoal, amount, createdAt);
    }

    return GoalAutoContribution(
      contributions: contributions,
      goal: updatedGoal,
      lastCreatedMonth: lastCreatedMonth,
      stopItem: !updatedGoal.isActive,
    );
  }

  static TransactionRecord buildTransaction(RecurringItem item, DateTime date, int createdAt, {double? amount}) {
    return TransactionRecord(
      id: transactionId(item.id, date),
      type: item.type,
      amount: amount ?? item.amount,
      categoryId: item.categoryId,
      description: item.description,
      date: date.millisecondsSinceEpoch,
      paymentMode: item.paymentMode,
      goalId: item.goalId,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }
}

class GoalAutoContribution {
  final List<TransactionRecord> contributions;
  final SavingsGoal? goal;
  final String lastCreatedMonth;
  final bool stopItem;

  GoalAutoContribution({required this.contributions, required this.goal, required this.lastCreatedMonth, required this.stopItem});

  double get total => GoalCalculator.contributedTotal(contributions);
}
