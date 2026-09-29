import '../utils/constants.dart';

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

  Map<String, dynamic> toMap() {
    return {
      DbFields.categoryId: categoryId,
      DbFields.limitAmount: limitAmount,
      DbFields.alertThreshold: alertThreshold,
      DbFields.alertLevel: alertLevel,
      DbFields.createdAt: createdAt,
    };
  }

  bool get isTotal => categoryId == null;

  String get budgetKey => categoryId ?? DbNodes.budgetTotalKey;
}
