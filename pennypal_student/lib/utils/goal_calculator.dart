import '../models/savings_goal.dart';
import '../models/transaction_record.dart';
import 'constants.dart';

enum GoalPace { onTrack, behind, unknown }

class GoalCalculator {
  static double remaining(double targetAmount, double currentAmount) {
    final double value = targetAmount - currentAmount;
    if (value < 0) return 0;
    return value;
  }

  static double progress(double targetAmount, double currentAmount) {
    if (targetAmount <= 0) return 0;
    final double value = currentAmount / targetAmount;
    if (value > 1) return 1;
    return value;
  }

  static int? monthsLeft(double remainingAmount, double monthlyContribution) {
    if (remainingAmount <= 0) return 0;
    if (monthlyContribution <= 0) return null;
    return (remainingAmount / monthlyContribution).ceil();
  }

  static DateTime? estimatedDate(int? months, {DateTime? now}) {
    if (months == null) return null;
    final DateTime today = now ?? DateTime.now();
    final DateTime firstDayOfTarget = DateTime(today.year, today.month + months, 1);
    final int lastDay = DateTime(firstDayOfTarget.year, firstDayOfTarget.month + 1, 0).day;

    int day = today.day;
    if (day > lastDay) day = lastDay;
    return DateTime(firstDayOfTarget.year, firstDayOfTarget.month, day);
  }

  static GoalPace pace(DateTime? estimated, DateTime targetDate) {
    if (estimated == null) return GoalPace.unknown;
    if (estimated.isAfter(targetDate)) return GoalPace.behind;
    return GoalPace.onTrack;
  }

  static bool isContributionAllowed(SavingsGoal goal, double amount, {double oldAmount = 0}) {
    final bool isEditing = oldAmount > 0;
    final bool canChangeGoal = goal.isActive || (isEditing && goal.status == GoalStatuses.completed);
    return canChangeGoal && amount > 0 && amount <= goal.remainingAmount + oldAmount;
  }

  static bool isMilestoneReached(String key, double currentAmount, double targetAmount) {
    final int milestonePercent = int.parse(key.substring(1));
    if (targetAmount <= 0) return false;
    return currentAmount * 100 >= targetAmount * milestonePercent;
  }

  static bool canMarkMilestone(SavingsGoal goal, String key) {
    final bool isMarked = goal.milestones.containsKey(key);
    if (goal.status == GoalStatuses.cancelled || isMarked) return false;
    return isMilestoneReached(key, goal.currentAmount, goal.targetAmount);
  }

  static SavingsGoal markMilestone(SavingsGoal goal, String key, int markedAt) {
    final Map<String, int> milestones = Map<String, int>.from(goal.milestones);
    milestones[key] = markedAt;
    return _copyGoal(goal, milestones: milestones, completedAt: goal.completedAt);
  }

  static SavingsGoal changeCurrentAmount(SavingsGoal goal, double change, int now) {
    final double currentAmount = goal.currentAmount + change;
    final bool isReached = currentAmount >= goal.targetAmount;
    if (goal.isActive && isReached) {
      return _copyGoal(goal, currentAmount: currentAmount, status: GoalStatuses.completed, completedAt: now);
    }
    if (goal.status == GoalStatuses.completed && !isReached) {
      return _copyGoal(goal, currentAmount: currentAmount, status: GoalStatuses.active, completedAt: null);
    }
    return _copyGoal(goal, currentAmount: currentAmount, completedAt: goal.completedAt);
  }

  static SavingsGoal cancelGoal(SavingsGoal goal) {
    return _copyGoal(goal, status: GoalStatuses.cancelled, completedAt: goal.completedAt);
  }

  static double contributedTotal(List<TransactionRecord> contributions) {
    double total = 0;
    for (final TransactionRecord contribution in contributions) {
      total += contribution.amount;
    }
    return total;
  }

  static SavingsGoal _copyGoal(
    SavingsGoal goal, {
    double? currentAmount,
    String? status,
    Map<String, int>? milestones,
    required int? completedAt,
  }) {
    return SavingsGoal(
      id: goal.id,
      name: goal.name,
      targetAmount: goal.targetAmount,
      initialAmount: goal.initialAmount,
      currentAmount: currentAmount ?? goal.currentAmount,
      targetDate: goal.targetDate,
      monthlyContribution: goal.monthlyContribution,
      status: status ?? goal.status,
      milestones: milestones ?? goal.milestones,
      completedAt: completedAt,
      createdAt: goal.createdAt,
    );
  }

  static int percentOf(double progress) {
    return (progress * 100 + 0.0001).floor();
  }

  static bool isInitialBelowTarget(double initialAmount, double targetAmount) {
    return initialAmount >= 0 && initialAmount < targetAmount;
  }

  static bool isAfterToday(DateTime date, {DateTime? now}) {
    final DateTime today = now ?? DateTime.now();
    final DateTime endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59, 999);
    return date.isAfter(endOfToday);
  }

  static List<TransactionRecord> contributionsOf(String goalId, List<TransactionRecord> transactions) {
    final List<TransactionRecord> result = [];
    for (final TransactionRecord transaction in transactions) {
      if (transaction.goalId == goalId) result.add(transaction);
    }
    return result;
  }

  static double savedInActiveGoals(List<SavingsGoal> goals) {
    double total = 0;
    for (final SavingsGoal goal in goalsWithStatus(goals, GoalStatuses.active)) {
      total += goal.currentAmount;
    }
    return total;
  }

  static List<SavingsGoal> goalsWithStatus(List<SavingsGoal> goals, String status) {
    final List<SavingsGoal> result = [];
    for (final SavingsGoal goal in goals) {
      if (goal.status == status) result.add(goal);
    }
    return result;
  }
}
