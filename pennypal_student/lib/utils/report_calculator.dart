import '../models/transaction_record.dart';
import 'budget_calculator.dart';
import 'constants.dart';

class CategoryTotal {
  final String categoryId;
  final double amount;
  final double percent;

  const CategoryTotal({required this.categoryId, required this.amount, required this.percent});
}

class MonthTotal {
  final DateTime month;
  final double income;
  final double spending;

  const MonthTotal({required this.month, required this.income, required this.spending});
}

class MonthSummary {
  final double income;
  final double spending;
  final double savings;

  const MonthSummary({required this.income, required this.spending, required this.savings});

  bool get isEmpty => income == 0 && spending == 0 && savings == 0;
}

class ReportCalculator {
  static const int trendMonths = 6;

  static String _monthOf(TransactionRecord transaction) {
    return BudgetCalculator.monthKey(DateTime.fromMillisecondsSinceEpoch(transaction.date));
  }

  static bool _isSpending(TransactionRecord transaction) {
    return transaction.type == TransactionTypes.expense && transaction.categoryId != CategoryKeys.savings;
  }

  static MonthSummary summary(List<TransactionRecord> transactions, DateTime month) {
    final String key = BudgetCalculator.monthKey(month);
    double income = 0;
    double spending = 0;
    double savings = 0;
    for (final TransactionRecord transaction in transactions) {
      if (_monthOf(transaction) != key) continue;
      if (transaction.type == TransactionTypes.income) {
        income += transaction.amount;
      } else if (_isSpending(transaction)) {
        spending += transaction.amount;
      } else {
        savings += transaction.amount;
      }
    }
    return MonthSummary(income: income, spending: spending, savings: savings);
  }

  static List<CategoryTotal> spendingByCategory(List<TransactionRecord> transactions, DateTime month) {
    final String key = BudgetCalculator.monthKey(month);
    final Map<String, double> amounts = {};
    for (final TransactionRecord transaction in transactions) {
      if (_monthOf(transaction) != key || !_isSpending(transaction)) continue;
      amounts[transaction.categoryId] = (amounts[transaction.categoryId] ?? 0) + transaction.amount;
    }
    return _shares(amounts);
  }

  static List<CategoryTotal> incomeByCategory(List<TransactionRecord> transactions, DateTime month) {
    final String key = BudgetCalculator.monthKey(month);
    final Map<String, double> amounts = {};
    for (final TransactionRecord transaction in transactions) {
      if (_monthOf(transaction) != key || transaction.type != TransactionTypes.income) continue;
      amounts[transaction.categoryId] = (amounts[transaction.categoryId] ?? 0) + transaction.amount;
    }
    return _shares(amounts);
  }

  static List<CategoryTotal> _shares(Map<String, double> amounts) {
    double total = 0;
    for (final double amount in amounts.values) {
      total += amount;
    }
    if (total == 0) return [];

    final List<CategoryTotal> result = [];
    for (final MapEntry<String, double> entry in amounts.entries) {
      result.add(CategoryTotal(categoryId: entry.key, amount: entry.value, percent: entry.value / total * 100));
    }
    result.sort((a, b) => b.amount.compareTo(a.amount));
    return result;
  }

  static List<DateTime> lastMonths(DateTime month, {int count = trendMonths}) {
    return [for (int back = count - 1; back >= 0; back--) DateTime(month.year, month.month - back)];
  }

  static List<MonthTotal> monthlyTotals(List<TransactionRecord> transactions, DateTime month) {
    final List<DateTime> months = lastMonths(month);
    final Map<String, double> incomeByMonth = {for (final DateTime item in months) BudgetCalculator.monthKey(item): 0};
    final Map<String, double> spendingByMonth = {...incomeByMonth};

    for (final TransactionRecord transaction in transactions) {
      final String key = _monthOf(transaction);
      if (!incomeByMonth.containsKey(key)) continue;
      if (transaction.type == TransactionTypes.income) {
        incomeByMonth[key] = incomeByMonth[key]! + transaction.amount;
      } else if (_isSpending(transaction)) {
        spendingByMonth[key] = spendingByMonth[key]! + transaction.amount;
      }
    }

    return months.map((item) {
      final String key = BudgetCalculator.monthKey(item);
      return MonthTotal(month: item, income: incomeByMonth[key]!, spending: spendingByMonth[key]!);
    }).toList();
  }
}
