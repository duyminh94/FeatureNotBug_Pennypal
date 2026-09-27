import 'budget.dart';
import 'savings_goal.dart';
import 'transaction_record.dart';

/// Aggregated data displayed on the Dashboard tab.
class DashboardData {
  final String userName;
  final String? announcement;
  final double balance;
  final double monthIncome;
  final double monthExpense;
  final double monthSavings;
  final Budget? totalBudget;
  final SavingsGoal? activeGoal;
  final List<TransactionRecord> recentTransactions;

  const DashboardData({
    required this.userName,
    this.announcement,
    required this.balance,
    required this.monthIncome,
    required this.monthExpense,
    required this.monthSavings,
    this.totalBudget,
    this.activeGoal,
    required this.recentTransactions,
  });

  static DashboardData empty({String userName = ''}) {
    return DashboardData(
      userName: userName,
      balance: 0,
      monthIncome: 0,
      monthExpense: 0,
      monthSavings: 0,
      recentTransactions: const [],
    );
  }
}
