import '../models/budget.dart';
import '../models/category.dart';
import '../models/transaction_record.dart';
import 'constants.dart';
import 'text_normalizer.dart';

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

  static bool canChangeType(String categoryId, List<TransactionRecord> transactions, List<Budget> budgets) {
    return transactionCount(categoryId, transactions) == 0 && budgetCount(categoryId, budgets) == 0;
  }
}
