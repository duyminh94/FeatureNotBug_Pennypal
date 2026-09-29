import '../utils/constants.dart';

class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double initialAmount;
  final double currentAmount;
  final int targetDate;
  final double monthlyContribution;
  final String status;
  final Map<String, int> milestones;
  final int? completedAt;
  final int? createdAt;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.initialAmount = 0,
    required this.currentAmount,
    required this.targetDate,
    this.monthlyContribution = 0,
    this.status = GoalStatuses.active,
    this.milestones = const {},
    this.completedAt,
    this.createdAt,
  });

  factory SavingsGoal.fromMap(String id, Map<dynamic, dynamic> map) {
    final Map<dynamic, dynamic> rawMilestones = map[DbFields.milestones] ?? {};
    final Map<String, int> milestones = {};
    rawMilestones.forEach((key, value) {
      milestones[key.toString()] = value as int;
    });

    return SavingsGoal(
      id: id,
      name: map[DbFields.name] ?? '',
      targetAmount: (map[DbFields.targetAmount] as num? ?? 0).toDouble(),
      initialAmount: (map[DbFields.initialAmount] as num? ?? 0).toDouble(),
      currentAmount: (map[DbFields.currentAmount] as num? ?? 0).toDouble(),
      targetDate: map[DbFields.targetDate] ?? 0,
      monthlyContribution:
          (map[DbFields.monthlyContribution] as num? ?? 0).toDouble(),
      status: map[DbFields.status] ?? GoalStatuses.active,
      milestones: milestones,
      completedAt: map[DbFields.completedAt],
      createdAt: map[DbFields.createdAt],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DbFields.name: name,
      DbFields.targetAmount: targetAmount,
      DbFields.initialAmount: initialAmount,
      DbFields.currentAmount: currentAmount,
      DbFields.targetDate: targetDate,
      DbFields.monthlyContribution: monthlyContribution,
      DbFields.status: status,
      DbFields.milestones: milestones.isEmpty ? null : milestones,
      DbFields.completedAt: completedAt,
      DbFields.createdAt: createdAt,
    };
  }

  double get remainingAmount {
    final double remaining = targetAmount - currentAmount;
    return remaining < 0 ? 0 : remaining;
  }

  double get progress {
    if (targetAmount <= 0) return 0;
    final double value = currentAmount / targetAmount;
    return value > 1 ? 1 : value;
  }

  bool get isActive => status == GoalStatuses.active;
}
