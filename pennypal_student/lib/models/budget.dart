import '../utils/constants.dart';

/// A monthly spending limit, stored at budgets/{uid}/{month}/{budgetKey}.
class Budget {
  final String month;
  final String? categoryId;
  final double limitAmount;
  final int alertThreshold;
  final String alertLevel;
  final int? createdAt;

  Budget({
    required this.month,
    this.categoryId,
    required this.limitAmount,
    this.alertThreshold = AppDefaults.alertThreshold,
    this.alertLevel = AlertLevels.none,
    this.createdAt,
  });

  /// Builds a budget from budgets/{uid}/{month}/{budgetKey}.
  factory Budget.fromMap(String month, Map<dynamic, dynamic> map) {
    return Budget(
      month: month,
      categoryId: map[DbFields.categoryId],
      limitAmount: (map[DbFields.limitAmount] as num? ?? 0).toDouble(),
      alertThreshold:
          map[DbFields.alertThreshold] ?? AppDefaults.alertThreshold,
      alertLevel: map[DbFields.alertLevel] ?? AlertLevels.none,
      createdAt: map[DbFields.createdAt],
    );
  }

  /// Converts the budget to a map for writing.
  Map<String, dynamic> toMap() {
    return {
      DbFields.categoryId: categoryId,
      DbFields.limitAmount: limitAmount,
      DbFields.alertThreshold: alertThreshold,
      DbFields.alertLevel: alertLevel,
      DbFields.createdAt: createdAt,
    };
  }

  /// True for the overall budget of the month.
  bool get isTotal => categoryId == null;

  /// Node key under the month: the category id or "total".
  String get budgetKey => categoryId ?? DbNodes.budgetTotalKey;
}
