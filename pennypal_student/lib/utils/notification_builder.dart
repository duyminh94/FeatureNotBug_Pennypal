import '../models/app_notification.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';
import '../models/support_query.dart';
import '../models/transaction_record.dart';
import 'budget_calculator.dart';
import 'constants.dart';

class NotificationBuilder {
  static List<AppNotification> build({
    required List<TransactionRecord> transactions,
    required List<Budget> budgets,
    required List<SavingsGoal> goals,
    List<SupportQuery> supportQueries = const [],
    Set<String> readIds = const {},
  }) {
    final List<AppNotification> notifications = [];
    for (final Budget budget in budgets) {
      final AppNotification? alert = _budgetAlert(budget, transactions, readIds);
      if (alert != null) notifications.add(alert);
    }
    for (final SavingsGoal goal in goals) {
      notifications.addAll(_goalNotifications(goal, transactions, readIds));
    }
    for (final SupportQuery query in supportQueries) {
      final String response = query.adminResponse ?? '';
      if (!query.isResolved || response.isEmpty) continue;

      final String id = 'support_${query.id}';
      notifications.add(AppNotification(
        id: id,
        type: NotificationTypes.supportReplied,
        params: {'subject': query.subject},
        isRead: readIds.contains(id),
        createdAt: query.respondedAt ?? query.submittedAt,
      ));
    }

    notifications.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    return notifications;
  }

  static List<SupportQuery> supportRepliesToAnnounce(List<SupportQuery> supportQueries) {
    final List<SupportQuery> result = [];
    for (final SupportQuery query in supportQueries) {
      final String response = query.adminResponse ?? '';
      if (query.isResolved && response.isNotEmpty && !query.studentNotified) result.add(query);
    }
    return result;
  }

  static AppNotification? _budgetAlert(Budget budget, List<TransactionRecord> transactions, Set<String> readIds) {
    final List<TransactionRecord> spending = _spendingOf(transactions, budget.month, budget.categoryId);
    double spent = 0;
    for (final TransactionRecord transaction in spending) {
      spent += transaction.amount;
    }

    final int percent = BudgetCalculator.percent(spent, budget.limitAmount);
    String type;
    int levelPercent;
    Map<String, dynamic> params;
    if (percent >= 100) {
      type = NotificationTypes.budgetExceeded;
      levelPercent = 100;
      params = {'category': budget.budgetKey, 'amount': spent - budget.limitAmount};
    } else if (percent >= budget.alertThreshold) {
      type = NotificationTypes.budgetWarning;
      levelPercent = budget.alertThreshold;
      params = {'category': budget.budgetKey, 'percent': percent};
    } else {
      return null;
    }

    final double levelAmount = budget.limitAmount * levelPercent / 100;
    int? createdAt = _timeAmountReached(spending, 0, levelAmount);
    if (createdAt == null && spending.isNotEmpty) createdAt = spending.last.date;
    final int budgetCreatedAt = budget.createdAt ?? 0;
    if (createdAt == null || budgetCreatedAt > createdAt) createdAt = budgetCreatedAt;

    final String id = 'budget_${budget.month}_${budget.budgetKey}_$type';
    return AppNotification(id: id, type: type, params: params, isRead: readIds.contains(id), createdAt: createdAt);
  }

  static List<TransactionRecord> _spendingOf(List<TransactionRecord> transactions, String month, String? categoryId) {
    final List<TransactionRecord> result = [];
    for (final TransactionRecord transaction in transactions) {
      final bool isSpending = transaction.type == TransactionTypes.expense && transaction.categoryId != CategoryKeys.savings;
      final bool isInMonth = BudgetCalculator.monthKey(DateTime.fromMillisecondsSinceEpoch(transaction.date)) == month;
      final bool isInCategory = categoryId == null || transaction.categoryId == categoryId;
      if (isSpending && isInMonth && isInCategory) result.add(transaction);
    }
    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  static List<AppNotification> _goalNotifications(SavingsGoal goal, List<TransactionRecord> transactions, Set<String> readIds) {
    final List<AppNotification> result = [];
    if (goal.status == GoalStatuses.cancelled || goal.targetAmount <= 0) return result;

    final List<TransactionRecord> contributions = [];
    for (final TransactionRecord transaction in transactions) {
      if (transaction.goalId == goal.id) contributions.add(transaction);
    }
    contributions.sort((a, b) => a.date.compareTo(b.date));

    for (final String key in MilestoneKeys.values) {
      final int percent = int.parse(key.substring(1));
      final bool isReached = goal.currentAmount * 100 >= goal.targetAmount * percent;
      if (!isReached) continue;

      final bool isCompleted = key == MilestoneKeys.m100;
      final String type = isCompleted ? NotificationTypes.goalCompleted : NotificationTypes.goalMilestone;
      final String id = 'goal_${goal.id}_$key';

      int? createdAt = goal.milestones[key];
      if (isCompleted && goal.completedAt != null) createdAt = goal.completedAt;
      createdAt ??= _timeAmountReached(contributions, goal.initialAmount, goal.targetAmount * percent / 100);
      createdAt ??= goal.createdAt;

      result.add(AppNotification(
        id: id,
        type: type,
        params: {'goal': goal.name, 'percent': percent},
        isRead: readIds.contains(id),
        createdAt: createdAt,
      ));
    }
    return result;
  }

  static int? _timeAmountReached(List<TransactionRecord> sortedTransactions, double startAmount, double amount) {
    if (startAmount >= amount) return null;
    double total = startAmount;
    for (final TransactionRecord transaction in sortedTransactions) {
      total += transaction.amount;
      if (total >= amount) return transaction.date;
    }
    return null;
  }
}
