import '../models/savings_goal.dart';
import '../models/transaction_record.dart';
import 'constants.dart';

/// Whether the student will reach a goal by its target date at the planned monthly amount.
enum GoalPace { onTrack, behind, unknown }

/// Savings goal rules: progress, time left, contributions, milestones and cancelling.
class GoalCalculator {
  /// Money still needed; never below 0 even if the student saved more than the target.
  static double remaining(double targetAmount, double currentAmount) {
    final double value = targetAmount - currentAmount;
    if (value < 0) return 0;
    return value;
  }

  /// Progress from 0.0 to 1.0 for the progress bar; capped at 1.0 (100%).
  static double progress(double targetAmount, double currentAmount) {
    if (targetAmount <= 0) return 0;
    final double value = currentAmount / targetAmount;
    if (value > 1) return 1;
    return value;
  }

  /// Months needed at the planned monthly amount, rounded up.
  /// Null when there is no monthly plan, because the time cannot be estimated.
  static int? monthsLeft(double remainingAmount, double monthlyContribution) {
    if (remainingAmount <= 0) return 0;
    if (monthlyContribution <= 0) return null;
    return (remainingAmount / monthlyContribution).ceil();
  }

  /// Estimated finish date: today moved forward [months] months.
  /// The 31st becomes the last day of a shorter month (e.g. 31 Jan + 1 month -> 28/29 Feb).
  static DateTime? estimatedDate(int? months, {DateTime? now}) {
    if (months == null) return null;
    final DateTime today = now ?? DateTime.now();
    final DateTime firstDayOfTarget = DateTime(today.year, today.month + months, 1);
    final int lastDay = DateTime(firstDayOfTarget.year, firstDayOfTarget.month + 1, 0).day;

    int day = today.day;
    if (day > lastDay) day = lastDay;
    return DateTime(firstDayOfTarget.year, firstDayOfTarget.month, day);
  }

  /// Behind when the estimated finish is after the target date.
  static GoalPace pace(DateTime? estimated, DateTime targetDate) {
    if (estimated == null) return GoalPace.unknown;
    if (estimated.isAfter(targetDate)) return GoalPace.behind;
    return GoalPace.onTrack;
  }

  /// A contribution must be more than 0 and not more than what is still missing.
  /// When editing an old contribution its amount is given back first ([oldAmount]),
  /// so a completed goal may still have a contribution edited.
  static bool isContributionAllowed(SavingsGoal goal, double amount, {double oldAmount = 0}) {
    final bool isEditing = oldAmount > 0;
    final bool canChangeGoal = goal.isActive || (isEditing && goal.status == GoalStatuses.completed);
    return canChangeGoal && amount > 0 && amount <= goal.remainingAmount + oldAmount;
  }

  /// Milestone keys are "m25", "m50", "m75", "m100"; reached when saved money covers that percent.
  static bool isMilestoneReached(String key, double currentAmount, double targetAmount) {
    final int milestonePercent = int.parse(key.substring(1));
    if (targetAmount <= 0) return false;
    return currentAmount * 100 >= targetAmount * milestonePercent;
  }

  /// The student can mark a milestone once it is reached, if it is not marked yet and the goal is not cancelled.
  static bool canMarkMilestone(SavingsGoal goal, String key) {
    final bool isMarked = goal.milestones.containsKey(key);
    if (goal.status == GoalStatuses.cancelled || isMarked) return false;
    return isMilestoneReached(key, goal.currentAmount, goal.targetAmount);
  }

  /// Copy of the goal with one more milestone marked at [markedAt].
  static SavingsGoal markMilestone(SavingsGoal goal, String key, int markedAt) {
    final Map<String, int> milestones = Map<String, int>.from(goal.milestones);
    milestones[key] = markedAt;
    return _copyGoal(goal, milestones: milestones, completedAt: goal.completedAt);
  }

  /// Adds [change] (negative when a contribution is removed) to the saved money.
  /// Reaching the target completes the goal; dropping below it again reopens a completed goal.
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

  /// Marks the goal as cancelled and keeps its history ("keep history" choice when cancelling).
  static SavingsGoal cancelGoal(SavingsGoal goal) {
    return _copyGoal(goal, status: GoalStatuses.cancelled, completedAt: goal.completedAt);
  }

  /// Total money of a list of contributions.
  static double contributedTotal(List<TransactionRecord> contributions) {
    double total = 0;
    for (final TransactionRecord contribution in contributions) {
      total += contribution.amount;
    }
    return total;
  }

  /// Copy of a goal where only the given fields change.
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

  /// Whole percent for display. The tiny 0.0001 fixes rounding like 0.29 * 100 = 28.999…
  static int percentOf(double progress) {
    return (progress * 100 + 0.0001).floor();
  }

  /// The money already saved when creating a goal must be 0 or more and below the target.
  static bool isInitialBelowTarget(double initialAmount, double targetAmount) {
    return initialAmount >= 0 && initialAmount < targetAmount;
  }

  /// The target date must be after today (any time today still counts as today).
  static bool isAfterToday(DateTime date, {DateTime? now}) {
    final DateTime today = now ?? DateTime.now();
    final DateTime endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59, 999);
    return date.isAfter(endOfToday);
  }

  /// Contributions of one goal; they are saving transactions linked by goalId.
  static List<TransactionRecord> contributionsOf(String goalId, List<TransactionRecord> transactions) {
    final List<TransactionRecord> result = [];
    for (final TransactionRecord transaction in transactions) {
      if (transaction.goalId == goalId) result.add(transaction);
    }
    return result;
  }

  /// Goals with one status (active, completed or cancelled).
  static List<SavingsGoal> goalsWithStatus(List<SavingsGoal> goals, String status) {
    final List<SavingsGoal> result = [];
    for (final SavingsGoal goal in goals) {
      if (goal.status == status) result.add(goal);
    }
    return result;
  }
}
