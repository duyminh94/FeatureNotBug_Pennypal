import '../models/recurring_item.dart';
import '../models/savings_goal.dart';
import '../models/transaction_record.dart';
import 'budget_calculator.dart';
import 'constants.dart';
import 'goal_calculator.dart';

/// Works out which months of a fixed income or expense still need a transaction.
class RecurringCalculator {
  // The 31st becomes the last day of a shorter month: 31 -> 28 Feb, 30 Apr.
  static DateTime dateInMonth(DateTime month, int dayOfMonth) {
    final int lastDay = DateTime(month.year, month.month + 1, 0).day;
    int day = dayOfMonth;
    if (day < 1) day = 1;
    if (day > lastDay) day = lastDay;
    return DateTime(month.year, month.month, day);
  }

  // Every month after lastCreatedMonth whose date has come (today counts), oldest first.
  // A month the student deleted is never created again, because lastCreatedMonth has already passed it.
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

  // Turning an item back on continues from now: the months while it was stopped are not created.
  // If this month's day has not come yet, this month is still created. The month never moves backwards.
  static String monthKeyOnResume(RecurringItem item, DateTime now) {
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime thisMonthDate = dateInMonth(DateTime(now.year, now.month), item.dayOfMonth);

    String resumeMonth = BudgetCalculator.monthKey(today);
    if (thisMonthDate.isAfter(today)) resumeMonth = BudgetCalculator.monthKey(DateTime(now.year, now.month - 1));

    if (item.lastCreatedMonth.compareTo(resumeMonth) > 0) return item.lastCreatedMonth;
    return resumeMonth;
  }

  // Same id for the same item and month, so two phones opening the app together write one transaction, not two.
  static String transactionId(String itemId, DateTime date) {
    return 'rec_${itemId}_${BudgetCalculator.monthKey(date)}';
  }

  // Everything to write when the app opens: the new transactions and each item's new lastCreatedMonth.
  // Written in one update, so a month is either fully done or not done at all.
  static Map<String, Object?> dueChanges(String uid, List<RecurringItem> items, DateTime now) {
    final Map<String, Object?> changes = {};
    final int createdAt = now.millisecondsSinceEpoch;

    for (final RecurringItem item in items) {
      // Goal contributions also change the goal's saved money, see goalContributions.
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

  // One auto contribution item per goal, found again from the goal id when the goal is edited.
  static String goalItemId(String goalId) => 'goal_$goalId';

  // Starts next month: this month counts as done, because the student usually enters current savings when creating the goal.
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

  // Fields to change on an existing goal item after the goal form is saved; empty means nothing to change.
  // lastCreatedMonth is only written when a stopped item is turned back on, so the app-open claim is never undone.
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

  // Monthly contributions of an item linked to a savings goal.
  // The last one is only what is still missing (BR-38). A goal that is completed, cancelled or deleted
  // gets nothing and the item is stopped.
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
