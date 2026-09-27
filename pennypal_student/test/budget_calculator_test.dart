import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_student/models/app_notification.dart';
import 'package:pennypal_student/models/budget.dart';
import 'package:pennypal_student/models/transaction_record.dart';
import 'package:pennypal_student/utils/budget_calculator.dart';
import 'package:pennypal_student/utils/constants.dart';
import 'package:pennypal_student/utils/notification_builder.dart';

void main() {
  group('BudgetCalculator.percent (BR-24)', () {
    test('rounds down so 995k of 1M is 99%, not 100%', () {
      expect(BudgetCalculator.percent(995000, 1000000), 99);
    });

    test('no floating error: 290k of 1M is 29%', () {
      expect(BudgetCalculator.percent(290000, 1000000), 29);
    });

    test('exactly the limit is 100% and more is above 100%', () {
      expect(BudgetCalculator.percent(1000000, 1000000), 100);
      expect(BudgetCalculator.percent(1500000, 1000000), 150);
    });

    test('a limit of 0 gives 0 instead of dividing by zero', () {
      expect(BudgetCalculator.percent(50000, 0), 0);
    });
  });

  group('BudgetCalculator.status (BR-26)', () {
    test('995k of 1M is near the limit, not over', () {
      expect(BudgetCalculator.status(995000, 1000000, 80), BudgetStatus.nearLimit);
    });

    test('the warning starts exactly at the threshold', () {
      expect(BudgetCalculator.status(795000, 1000000, 80), BudgetStatus.normal);
      expect(BudgetCalculator.status(800000, 1000000, 80), BudgetStatus.nearLimit);
    });

    test('spending the whole limit is over', () {
      expect(BudgetCalculator.status(1000000, 1000000, 80), BudgetStatus.over);
    });
  });

  group('Budget notifications', () {
    final DateTime now = DateTime.now();
    final String month = BudgetCalculator.monthKey(now);

    List<AppNotification> alertsFor(double spent) {
      final TransactionRecord expense = TransactionRecord(
        id: 'tx1',
        type: TransactionTypes.expense,
        amount: spent,
        categoryId: CategoryKeys.food,
        date: now.millisecondsSinceEpoch,
      );
      final Budget foodBudget = Budget(month: month, categoryId: CategoryKeys.food, limitAmount: 1000000, alertThreshold: 80);
      return NotificationBuilder.build(transactions: [expense], budgets: [foodBudget], goals: []);
    }

    test('995k of 1M gives a warning with 99%, never "over by -5,000"', () {
      final List<AppNotification> alerts = alertsFor(995000);
      expect(alerts.single.type, NotificationTypes.budgetWarning);
      expect(alerts.single.params['percent'], 99);
    });

    test('1,005,000 of 1M is over by 5,000', () {
      final List<AppNotification> alerts = alertsFor(1005000);
      expect(alerts.single.type, NotificationTypes.budgetExceeded);
      expect(alerts.single.params['amount'], 5000);
    });

    test('795k with an 80% threshold gives no alert', () {
      expect(alertsFor(795000), isEmpty);
    });
  });
}
