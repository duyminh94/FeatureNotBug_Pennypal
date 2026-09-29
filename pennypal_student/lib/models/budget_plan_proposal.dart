class BudgetPlanItem {
  final String categoryId;
  final String categoryName;
  double amount;
  final String? note;

  BudgetPlanItem({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    this.note,
  });

  Map<String, dynamic> toMap() => {
    'categoryId': categoryId,
    'categoryName': categoryName,
    'amount': amount,
    'note': note,
  };

  factory BudgetPlanItem.fromMap(Map<String, dynamic> map) => BudgetPlanItem(
    categoryId: map['categoryId']?.toString() ?? '',
    categoryName: map['categoryName']?.toString() ?? '',
    amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : 0.0,
    note: map['note']?.toString(),
  );
}

class BudgetPlanProposal {
  final String month;
  final double estimatedIncome;
  final double fixedExpensesTotal;
  final double savingsTotal;
  final List<BudgetPlanItem> items;
  bool isApplied;

  BudgetPlanProposal({
    required this.month,
    required this.estimatedIncome,
    required this.fixedExpensesTotal,
    required this.savingsTotal,
    required this.items,
    this.isApplied = false,
  });

  double get totalPlanned => items.fold(0.0, (sum, item) => sum + item.amount);
  bool get isDeficit => estimatedIncome > 0 && estimatedIncome < fixedExpensesTotal;
  double get deficitAmount => (fixedExpensesTotal - estimatedIncome).clamp(0.0, double.infinity);

  Map<String, dynamic> toMap() => {
    'month': month,
    'estimatedIncome': estimatedIncome,
    'fixedExpensesTotal': fixedExpensesTotal,
    'savingsTotal': savingsTotal,
    'items': items.map((i) => i.toMap()).toList(),
    'isApplied': isApplied,
  };

  factory BudgetPlanProposal.fromMap(Map<String, dynamic> map) => BudgetPlanProposal(
    month: map['month']?.toString() ?? '',
    estimatedIncome: (map['estimatedIncome'] is num) ? (map['estimatedIncome'] as num).toDouble() : 0.0,
    fixedExpensesTotal: (map['fixedExpensesTotal'] is num) ? (map['fixedExpensesTotal'] as num).toDouble() : 0.0,
    savingsTotal: (map['savingsTotal'] is num) ? (map['savingsTotal'] as num).toDouble() : 0.0,
    items: (map['items'] as List?)
            ?.map((i) => BudgetPlanItem.fromMap(Map<String, dynamic>.from(i as Map)))
            .toList() ??
        [],
    isApplied: map['isApplied'] == true,
  );
}
