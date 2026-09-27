import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_student/models/recurring_item.dart';
import 'package:pennypal_student/models/savings_goal.dart';
import 'package:pennypal_student/utils/constants.dart';
import 'package:pennypal_student/utils/recurring_calculator.dart';

RecurringItem saveForLaptop({double amount = 1000000, String lastCreatedMonth = '2026-09', bool isActive = true}) {
  return RecurringItem(
    id: 'auto1',
    type: TransactionTypes.expense,
    amount: amount,
    categoryId: CategoryKeys.savings,
    description: 'Save for Laptop',
    goalId: 'laptop',
    dayOfMonth: 5,
    lastCreatedMonth: lastCreatedMonth,
    isActive: isActive,
  );
}

SavingsGoal laptop({double current = 2000000, double target = 10000000, String status = GoalStatuses.active}) {
  return SavingsGoal(id: 'laptop', name: 'Laptop', targetAmount: target, currentAmount: current, targetDate: 0, status: status);
}

void main() {
  group('RecurringCalculator.goalContributions', () {
    test('one month due: one savings contribution linked to the goal', () {
      final GoalAutoContribution result = RecurringCalculator.goalContributions(saveForLaptop(), laptop(), DateTime(2026, 10, 5));

      expect(result.contributions.length, 1);
      final contribution = result.contributions.single;
      expect(contribution.id, 'rec_auto1_2026-10');
      expect(contribution.amount, 1000000);
      expect(contribution.categoryId, CategoryKeys.savings);
      expect(contribution.goalId, 'laptop');
      expect(result.total, 1000000);
      expect(result.goal!.currentAmount, 3000000);
      expect(result.lastCreatedMonth, '2026-10');
      expect(result.stopItem, isFalse);
    });

    test('three missed months are all contributed', () {
      final GoalAutoContribution result = RecurringCalculator.goalContributions(saveForLaptop(lastCreatedMonth: '2026-07'), laptop(), DateTime(2026, 10, 20));
      expect(result.contributions.map((c) => c.id), ['rec_auto1_2026-08', 'rec_auto1_2026-09', 'rec_auto1_2026-10']);
      expect(result.total, 3000000);
      expect(result.goal!.currentAmount, 5000000);
    });

    test('the last contribution is only what is missing, then the goal is completed and the item stops', () {
      final GoalAutoContribution result = RecurringCalculator.goalContributions(
        saveForLaptop(lastCreatedMonth: '2026-07'),
        laptop(current: 8500000),
        DateTime(2026, 10, 20),
      );
      expect(result.contributions.map((c) => c.amount), [1000000, 500000]);
      expect(result.goal!.currentAmount, 10000000);
      expect(result.goal!.status, GoalStatuses.completed);
      expect(result.stopItem, isTrue);
      expect(result.lastCreatedMonth, '2026-10');
    });

    test('a completed, cancelled or deleted goal gets nothing and the item stops', () {
      for (final SavingsGoal? goal in [laptop(status: GoalStatuses.completed), laptop(status: GoalStatuses.cancelled), null]) {
        final GoalAutoContribution result = RecurringCalculator.goalContributions(saveForLaptop(), goal, DateTime(2026, 10, 5));
        expect(result.contributions, isEmpty);
        expect(result.stopItem, isTrue);
        expect(result.lastCreatedMonth, '2026-10');
      }
    });

    test('nothing due: nothing changes', () {
      final GoalAutoContribution result = RecurringCalculator.goalContributions(saveForLaptop(), laptop(), DateTime(2026, 10, 4));
      expect(result.contributions, isEmpty);
      expect(result.stopItem, isFalse);
      expect(result.lastCreatedMonth, '2026-09');
    });
  });

  group('Goal form: what is saved for auto contribution', () {
    final SavingsGoal goal = SavingsGoal(
      id: 'laptop',
      name: 'Laptop',
      targetAmount: 10000000,
      currentAmount: 2000000,
      targetDate: 0,
      monthlyContribution: 1500000,
    );

    test('a new item uses the monthly amount, today as its day, and starts next month', () {
      final RecurringItem item = RecurringCalculator.newGoalItem(goal, 'Save for Laptop', DateTime(2026, 9, 27));
      expect(item.id, 'goal_laptop');
      expect(item.goalId, 'laptop');
      expect(item.amount, 1500000);
      expect(item.categoryId, CategoryKeys.savings);
      expect(item.type, TransactionTypes.expense);
      expect(item.dayOfMonth, 27);
      expect(item.lastCreatedMonth, '2026-09');
      expect(RecurringCalculator.datesToCreate(item, DateTime(2026, 9, 30)), isEmpty);
      expect(RecurringCalculator.datesToCreate(item, DateTime(2026, 10, 27)), [DateTime(2026, 10, 27)]);
    });

    test('running item, still wanted: only amount and name change, never lastCreatedMonth', () {
      final Map<String, Object?> fields = RecurringCalculator.goalItemUpdate(saveForLaptop(), goal, 'Save for Laptop', true, DateTime(2026, 9, 27));
      expect(fields, {DbFields.amount: 1500000.0, DbFields.description: 'Save for Laptop'});
    });

    test('stopped item turned back on: isActive and a resume month are written', () {
      final Map<String, Object?> fields = RecurringCalculator.goalItemUpdate(saveForLaptop(isActive: false), goal, 'Save for Laptop', true, DateTime(2026, 12, 10));
      expect(fields[DbFields.isActive], isTrue);
      expect(fields[DbFields.lastCreatedMonth], '2026-12');
    });

    test('switch turned off: running item stops, stopped item is left alone', () {
      expect(RecurringCalculator.goalItemUpdate(saveForLaptop(), goal, 'x', false, DateTime(2026, 9, 27)), {DbFields.isActive: false});
      expect(RecurringCalculator.goalItemUpdate(saveForLaptop(isActive: false), goal, 'x', false, DateTime(2026, 9, 27)), isEmpty);
    });
  });

  test('plain items and goal items are handled apart: dueChanges skips goal items', () {
    expect(RecurringCalculator.dueChanges('u1', [saveForLaptop()], DateTime(2026, 10, 5)), isEmpty);
  });
}
