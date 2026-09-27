import '../models/app_notification.dart';
import '../models/app_settings.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';
import '../models/support_query.dart';
import '../models/transaction_record.dart';
import '../models/user_profile.dart';
import 'constants.dart';

/// Temporary demo data for the static UI; replaced by Firebase data later.
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

  static DashboardData sample() {
    final DateTime now = DateTime.now();

    return DashboardData(
      userName: 'Minh An',
      announcement: 'Financial literacy week! 3 new budgeting lessons in the Learning corner.',
      balance: 4235000,
      monthIncome: 5500000,
      monthExpense: 3100000,
      monthSavings: 500000,
      totalBudget: Budget(month: '${now.year}-${now.month.toString().padLeft(2, '0')}', limitAmount: 4000000),
      activeGoal: SampleData.goals().first,
      recentTransactions: SampleData.transactions().take(5).toList(),
    );
  }

  static DashboardData empty() {
    return const DashboardData(
      userName: 'Minh An',
      balance: 0,
      monthIncome: 0,
      monthExpense: 0,
      monthSavings: 0,
      recentTransactions: [],
    );
  }
}

/// Temporary list of transactions for the History screen, newest first.
class SampleData {
  static UserProfile profile() {
    return UserProfile(
      uid: 'demo_student',
      fullName: 'Minh An',
      email: 'minhan@student.edu.vn',
      mobileNumber: '0912345678',
      studentStatus: StudentStatuses.undergraduate,
    );
  }

  static List<AppNotification> notifications() {
    final DateTime now = DateTime.now();
    int ago(Duration duration) => now.subtract(duration).millisecondsSinceEpoch;

    return [
      AppNotification(
        id: 'nt_over',
        type: NotificationTypes.budgetExceeded,
        params: {'category': CategoryKeys.entertainment, 'amount': 150000},
        createdAt: ago(const Duration(minutes: 10)),
      ),
      AppNotification(
        id: 'nt_warning',
        type: NotificationTypes.budgetWarning,
        params: {'category': CategoryKeys.food, 'percent': 90},
        createdAt: ago(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 'nt_support',
        type: NotificationTypes.supportReplied,
        params: {'subject': 'Currency does not change'},
        createdAt: ago(const Duration(days: 1)),
      ),
      AppNotification(
        id: 'nt_milestone',
        type: NotificationTypes.goalMilestone,
        params: {'goal': 'Trip to Da Lat', 'percent': 25},
        isRead: true,
        createdAt: ago(const Duration(days: 18)),
      ),
      AppNotification(
        id: 'nt_completed',
        type: NotificationTypes.goalCompleted,
        params: {'goal': 'New headphones'},
        isRead: true,
        createdAt: ago(const Duration(days: 35)),
      ),
    ];
  }

  static AppSettings appSettings() => AppSettings(supportEmail: 'support@pennypal.app');

  static List<SupportQuery> supportQueries() {
    final DateTime now = DateTime.now();
    int daysAgo(int days) => now.subtract(Duration(days: days)).millisecondsSinceEpoch;

    return [
      SupportQuery(
        id: 'sq_export',
        userEmail: 'minhan@student.edu.vn',
        subject: 'Export reports to Excel',
        message: 'Can I export my monthly report to an Excel file to share with my parents?',
        submittedAt: daysAgo(3),
      ),
      SupportQuery(
        id: 'sq_currency',
        userEmail: 'minhan@student.edu.vn',
        subject: 'Currency does not change',
        message: 'I switched to USD in Settings but my old amounts look the same.',
        status: SupportStatuses.resolved,
        adminResponse: 'Hi An, changing the currency only changes how amounts are shown. Your saved numbers stay the same.',
        submittedAt: daysAgo(5),
        respondedAt: daysAgo(4),
        studentNotified: true,
      ),
    ];
  }

  static List<Budget> budgets() {
    final DateTime now = DateTime.now();
    final String month = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    return [
      Budget(month: month, limitAmount: 900000),
      Budget(month: month, categoryId: CategoryKeys.entertainment, limitAmount: 100000),
      Budget(month: month, categoryId: CategoryKeys.food, limitAmount: 80000),
      Budget(month: month, categoryId: CategoryKeys.shopping, limitAmount: 400000),
      Budget(month: month, categoryId: CategoryKeys.education, limitAmount: 200000),
      Budget(month: month, categoryId: CategoryKeys.transport, limitAmount: 150000),
    ];
  }

  static List<TransactionRecord> transactions() {
    final DateTime now = DateTime.now();
    int daysAgo(int days, int hour) {
      final DateTime day = now.subtract(Duration(days: days));
      return DateTime(day.year, day.month, day.day, hour).millisecondsSinceEpoch;
    }

    TransactionRecord expense(String id, double amount, String categoryId, String description, int date,
        {String paymentMode = PaymentModes.cash}) {
      return TransactionRecord(
        id: id,
        type: TransactionTypes.expense,
        amount: amount,
        categoryId: categoryId,
        description: description,
        date: date,
        paymentMode: paymentMode,
      );
    }

    TransactionRecord contribution(String id, double amount, String goalId, String goalName, int date) {
      return TransactionRecord(
        id: id,
        type: TransactionTypes.expense,
        amount: amount,
        categoryId: CategoryKeys.savings,
        description: 'Goal contribution: $goalName',
        date: date,
        paymentMode: PaymentModes.bankTransfer,
        goalId: goalId,
      );
    }

    return [
      expense('t1', 45000, CategoryKeys.food, 'Lunch', daysAgo(0, 12)),
      expense('t2', 32000, CategoryKeys.transport, 'Grab to class', daysAgo(0, 8), paymentMode: PaymentModes.eWallet),
      TransactionRecord(
        id: 't3',
        type: TransactionTypes.income,
        amount: 3000000,
        categoryId: CategoryKeys.partTime,
        description: 'Part-time salary',
        date: daysAgo(2, 18),
        paymentMode: PaymentModes.bankTransfer,
      ),
      expense('t4', 120000, CategoryKeys.education, 'Microeconomics textbook', daysAgo(3, 10)),
      expense('t5', 70000, CategoryKeys.entertainment, 'Netflix', daysAgo(4, 21), paymentMode: PaymentModes.bankTransfer),
      TransactionRecord(
        id: 't6',
        type: TransactionTypes.expense,
        amount: 500000,
        categoryId: CategoryKeys.savings,
        description: 'Goal contribution: New laptop',
        date: daysAgo(4, 9),
        paymentMode: PaymentModes.bankTransfer,
        goalId: 'goal_laptop',
      ),
      expense('t7', 35000, CategoryKeys.entertainment, 'Bubble tea with friends', daysAgo(5, 16)),
      expense('t8', 250000, CategoryKeys.shopping, 'New T-shirt', daysAgo(6, 19), paymentMode: PaymentModes.eWallet),
      expense('t9', 180000, CategoryKeys.bills, 'Phone bill', daysAgo(7, 9), paymentMode: PaymentModes.bankTransfer),
      TransactionRecord(
        id: 't10',
        type: TransactionTypes.income,
        amount: 2500000,
        categoryId: CategoryKeys.allowance,
        description: 'Allowance from parents',
        date: daysAgo(8, 8),
        paymentMode: PaymentModes.bankTransfer,
      ),
      expense('t11', 25000, CategoryKeys.food, 'Breakfast bread', daysAgo(9, 7)),
      contribution('t12', 500000, 'goal_headphones', 'New headphones', daysAgo(35, 20)),
      contribution('t13', 300000, 'goal_ielts', 'IELTS course', daysAgo(60, 20)),
      contribution('t14', 300000, 'goal_ielts', 'IELTS course', daysAgo(90, 20)),
    ];
  }

  static List<TransactionRecord> pastMonthsTransactions() {
    final DateTime now = DateTime.now();
    const List<double> partTimePay = [2500000, 2800000, 3000000, 2600000, 3200000];
    const List<double> foodSpending = [1200000, 1400000, 1100000, 1500000, 1300000];
    const List<double> funSpending = [400000, 650000, 300000, 700000, 500000];
    final List<TransactionRecord> result = [];

    for (int back = 1; back <= 5; back++) {
      final int date = DateTime(now.year, now.month - back, 10, 12).millisecondsSinceEpoch;
      TransactionRecord record(String name, String type, double amount, String categoryId) {
        return TransactionRecord(id: 'past_${back}_$name', type: type, amount: amount, categoryId: categoryId, date: date);
      }

      result.addAll([
        record('allowance', TransactionTypes.income, 2500000, CategoryKeys.allowance),
        record('part_time', TransactionTypes.income, partTimePay[back - 1], CategoryKeys.partTime),
        record('food', TransactionTypes.expense, foodSpending[back - 1], CategoryKeys.food),
        record('transport', TransactionTypes.expense, 400000, CategoryKeys.transport),
        record('fun', TransactionTypes.expense, funSpending[back - 1], CategoryKeys.entertainment),
        record('bills', TransactionTypes.expense, 180000, CategoryKeys.bills),
      ]);
    }
    return result;
  }

  static List<SavingsGoal> goals() {
    final DateTime now = DateTime.now();
    int daysAgo(int days) => now.subtract(Duration(days: days)).millisecondsSinceEpoch;
    int firstDayIn(int months) => DateTime(now.year, now.month + months, 1).millisecondsSinceEpoch;

    return [
      SavingsGoal(
        id: 'goal_laptop',
        name: 'New laptop',
        targetAmount: 20000000,
        initialAmount: 7500000,
        currentAmount: 8000000,
        targetDate: firstDayIn(8),
        monthlyContribution: 2000000,
        createdAt: daysAgo(30),
      ),
      SavingsGoal(
        id: 'goal_dalat',
        name: 'Trip to Da Lat',
        targetAmount: 3000000,
        initialAmount: 1800000,
        currentAmount: 1800000,
        targetDate: firstDayIn(3),
        monthlyContribution: 300000,
        milestones: {MilestoneKeys.m25: daysAgo(18)},
        createdAt: daysAgo(20),
      ),
      SavingsGoal(
        id: 'goal_headphones',
        name: 'New headphones',
        targetAmount: 1500000,
        initialAmount: 1000000,
        currentAmount: 1500000,
        targetDate: firstDayIn(1),
        monthlyContribution: 500000,
        status: GoalStatuses.completed,
        milestones: {
          MilestoneKeys.m25: daysAgo(50),
          MilestoneKeys.m50: daysAgo(50),
          MilestoneKeys.m75: daysAgo(35),
          MilestoneKeys.m100: daysAgo(35),
        },
        completedAt: daysAgo(35),
        createdAt: daysAgo(50),
      ),
      SavingsGoal(
        id: 'goal_ielts',
        name: 'IELTS course',
        targetAmount: 2000000,
        currentAmount: 600000,
        targetDate: firstDayIn(2),
        monthlyContribution: 300000,
        status: GoalStatuses.cancelled,
        milestones: {MilestoneKeys.m25: daysAgo(60)},
        createdAt: daysAgo(100),
      ),
    ];
  }
}
