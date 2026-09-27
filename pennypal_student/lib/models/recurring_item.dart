import '../utils/constants.dart';

/// A fixed monthly income or expense, stored at recurring/{uid}/{itemId}.
class RecurringItem {
  final String id;
  final String type;
  final double amount;
  final String categoryId;
  final String description;
  final String? paymentMode;
  final String? goalId;
  final int dayOfMonth;
  final String lastCreatedMonth;
  final bool isActive;
  final int? createdAt;

  RecurringItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    this.description = '',
    this.paymentMode,
    this.goalId,
    required this.dayOfMonth,
    required this.lastCreatedMonth,
    this.isActive = true,
    this.createdAt,
  });

  factory RecurringItem.fromMap(String id, Map<dynamic, dynamic> map) {
    return RecurringItem(
      id: id,
      type: map[DbFields.type] ?? TransactionTypes.expense,
      amount: (map[DbFields.amount] as num? ?? 0).toDouble(),
      categoryId: map[DbFields.categoryId] ?? CategoryKeys.miscellaneous,
      description: map[DbFields.description] ?? '',
      paymentMode: map[DbFields.paymentMode],
      goalId: map[DbFields.goalId],
      dayOfMonth: map[DbFields.dayOfMonth] ?? 1,
      lastCreatedMonth: map[DbFields.lastCreatedMonth] ?? '',
      isActive: map[DbFields.isActive] ?? true,
      createdAt: map[DbFields.createdAt],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DbFields.type: type,
      DbFields.amount: amount,
      DbFields.categoryId: categoryId,
      DbFields.description: description,
      DbFields.paymentMode: paymentMode,
      DbFields.goalId: goalId,
      DbFields.dayOfMonth: dayOfMonth,
      DbFields.lastCreatedMonth: lastCreatedMonth,
      DbFields.isActive: isActive,
      DbFields.createdAt: createdAt,
    };
  }

  bool get isIncome => type == TransactionTypes.income;

  bool get isGoalContribution => goalId != null;
}
