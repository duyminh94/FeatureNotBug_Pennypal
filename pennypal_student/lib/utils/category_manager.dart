import '../models/budget.dart';
import '../models/category.dart';
import '../models/transaction_record.dart';
import 'constants.dart';
import 'text_normalizer.dart';

class MergeResult {
  final List<TransactionRecord> transactions;
  final List<Budget> budgets;
  final int movedTransactions;
  final int movedBudgets;
  final List<String> keptTargetMonths;

  const MergeResult({
    required this.transactions,
    required this.budgets,
    required this.movedTransactions,
    required this.movedBudgets,
    required this.keptTargetMonths,
  });
}

class CategoryManager {
  static const int nameMin = 2;
  static const int nameMax = 30;

  static List<String> defaultKeys(String type) {
    return type == TransactionTypes.income ? CategoryKeys.income : CategoryKeys.selectableExpense;
  }

  static bool isValidNameLength(String name) {
    final int length = name.trim().length;
    return length >= nameMin && length <= nameMax;
  }

  static bool isDuplicateName({
    required String name,
    required String type,
    required List<String> defaultNames,
    required List<Category> customCategories,
    String? editingId,
  }) {
    final String wanted = TextNormalizer.normalize(name.trim());
    final bool matchesDefault = defaultNames.any((defaultName) => TextNormalizer.normalize(defaultName) == wanted);
    final bool matchesCustom = customCategories.any((category) =>
        category.id != editingId && category.type == type && TextNormalizer.normalize(category.name ?? '') == wanted);
    return matchesDefault || matchesCustom;
  }

  static int transactionCount(String categoryId, List<TransactionRecord> transactions) {
    return transactions.where((transaction) => transaction.categoryId == categoryId).length;
  }

  static int budgetCount(String categoryId, List<Budget> budgets) {
    return budgets.where((budget) => budget.categoryId == categoryId).length;
  }

  static bool canChangeType(String categoryId, List<TransactionRecord> transactions) {
    return transactionCount(categoryId, transactions) == 0;
  }

  static List<String> mergeTargets(Category deleting, List<Category> customCategories) {
    final List<String> customIds = customCategories
        .where((category) => category.type == deleting.type && category.id != deleting.id)
        .map((category) => category.id)
        .toList();
    return [...defaultKeys(deleting.type), ...customIds];
  }

  static MergeResult merge({
    required String fromId,
    required String toId,
    required List<TransactionRecord> transactions,
    required List<Budget> budgets,
  }) {
    int movedTransactions = 0;
    final List<TransactionRecord> newTransactions = transactions.map((transaction) {
      if (transaction.categoryId != fromId) return transaction;
      movedTransactions++;
      return _withCategory(transaction, toId);
    }).toList();

    final Set<String> targetMonths =
        budgets.where((budget) => budget.categoryId == toId).map((budget) => budget.month).toSet();
    final List<String> keptTargetMonths = [];
    int movedBudgets = 0;
    final List<Budget> newBudgets = [];
    for (final Budget budget in budgets) {
      if (budget.categoryId != fromId) {
        newBudgets.add(budget);
      } else if (targetMonths.contains(budget.month)) {
        keptTargetMonths.add(budget.month);
      } else {
        movedBudgets++;
        newBudgets.add(Budget(
          month: budget.month,
          categoryId: toId,
          limitAmount: budget.limitAmount,
          alertThreshold: budget.alertThreshold,
          alertLevel: AlertLevels.none,
          createdAt: budget.createdAt,
        ));
      }
    }

    return MergeResult(
      transactions: newTransactions,
      budgets: newBudgets,
      movedTransactions: movedTransactions,
      movedBudgets: movedBudgets,
      keptTargetMonths: keptTargetMonths,
    );
  }

  static TransactionRecord _withCategory(TransactionRecord transaction, String categoryId) {
    return TransactionRecord(
      id: transaction.id,
      type: transaction.type,
      amount: transaction.amount,
      categoryId: categoryId,
      description: transaction.description,
      date: transaction.date,
      paymentMode: transaction.paymentMode,
      goalId: transaction.goalId,
      receiptLocalPath: transaction.receiptLocalPath,
      createdAt: transaction.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
