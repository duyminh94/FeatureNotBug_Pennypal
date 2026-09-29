import '../utils/constants.dart';

class TransactionRecord {
  final String id;
  final String type;
  final double amount;
  final String categoryId;
  final String description;
  final int date;
  final String? paymentMode;
  final String? goalId;
  final String? receiptLocalPath;
  final int? createdAt;
  final int? updatedAt;

  TransactionRecord({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    this.description = '',
    required this.date,
    this.paymentMode,
    this.goalId,
    this.receiptLocalPath,
    this.createdAt,
    this.updatedAt,
  });

  factory TransactionRecord.fromMap(String id, Map<dynamic, dynamic> map) {
    return TransactionRecord(
      id: id,
      type: map[DbFields.type] ?? TransactionTypes.expense,
      amount: (map[DbFields.amount] as num? ?? 0).toDouble(),
      categoryId: map[DbFields.categoryId] ?? CategoryKeys.miscellaneous,
      description: map[DbFields.description] ?? '',
      date: map[DbFields.date] ?? 0,
      paymentMode: map[DbFields.paymentMode],
      goalId: map[DbFields.goalId],
      receiptLocalPath: map[DbFields.receiptLocalPath],
      createdAt: map[DbFields.createdAt],
      updatedAt: map[DbFields.updatedAt],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DbFields.type: type,
      DbFields.amount: amount,
      DbFields.categoryId: categoryId,
      DbFields.description: description,
      DbFields.date: date,
      DbFields.paymentMode: paymentMode,
      DbFields.goalId: goalId,
      DbFields.receiptLocalPath: receiptLocalPath,
      DbFields.createdAt: createdAt,
      DbFields.updatedAt: updatedAt,
    };
  }

  bool get isIncome => type == TransactionTypes.income;

  bool get isGoalContribution => goalId != null;

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(date);
}
