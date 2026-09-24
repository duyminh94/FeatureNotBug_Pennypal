import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_student/models/app_settings.dart';
import 'package:pennypal_student/models/budget.dart';
import 'package:pennypal_student/models/category.dart';
import 'package:pennypal_student/models/savings_goal.dart';
import 'package:pennypal_student/models/transaction_record.dart';
import 'package:pennypal_student/utils/constants.dart';

void main() {
  group('TransactionRecord', () {
    test('toMap then fromMap keeps every field', () {
      final original = TransactionRecord(
        id: '-Nabc',
        type: TransactionTypes.expense,
        amount: 45000,
        categoryId: CategoryKeys.food,
        description: 'Lunch',
        date: 1790000000000,
        paymentMode: PaymentModes.cash,
      );

      final copy = TransactionRecord.fromMap('-Nabc', original.toMap());

      expect(copy.type, TransactionTypes.expense);
      expect(copy.amount, 45000);
      expect(copy.categoryId, CategoryKeys.food);
      expect(copy.description, 'Lunch');
      expect(copy.date, 1790000000000);
      expect(copy.paymentMode, PaymentModes.cash);
      expect(copy.goalId, isNull);
      expect(copy.isIncome, isFalse);
    });

    test('int amount from the database is read as double', () {
      final record = TransactionRecord.fromMap(
          '-N1', {'amount': 50000, 'type': 'income', 'date': 1});
      expect(record.amount, isA<double>());
      expect(record.amount, 50000.0);
      expect(record.isIncome, isTrue);
    });

    test('missing fields use safe defaults', () {
      final record = TransactionRecord.fromMap('-N2', {});
      expect(record.amount, 0);
      expect(record.description, '');
      expect(record.type, TransactionTypes.expense);
    });
  });

  group('Budget', () {
    test('overall budget has no category and uses the "total" key', () {
      final budget = Budget.fromMap('2026-09', {'limitAmount': 3000000});
      expect(budget.isTotal, isTrue);
      expect(budget.budgetKey, DbNodes.budgetTotalKey);
      expect(budget.alertThreshold, AppDefaults.alertThreshold);
      expect(budget.alertLevel, AlertLevels.none);
    });

    test('category budget round trip', () {
      final original = Budget(
          month: '2026-09',
          categoryId: CategoryKeys.food,
          limitAmount: 1500000,
          alertThreshold: 90);
      final copy = Budget.fromMap('2026-09', original.toMap());
      expect(copy.budgetKey, CategoryKeys.food);
      expect(copy.limitAmount, 1500000);
      expect(copy.alertThreshold, 90);
    });
  });

  group('SavingsGoal', () {
    test('round trip keeps milestones', () {
      final original = SavingsGoal(
        id: '-Ngoal',
        name: 'Laptop',
        targetAmount: 20000000,
        currentAmount: 10000000,
        targetDate: 1800000000000,
        milestones: {
          MilestoneKeys.m25: 1790000000000,
          MilestoneKeys.m50: 1791000000000
        },
      );

      final copy = SavingsGoal.fromMap('-Ngoal', original.toMap());

      expect(copy.name, 'Laptop');
      expect(copy.milestones.length, 2);
      expect(copy.milestones[MilestoneKeys.m50], 1791000000000);
      expect(copy.progress, 0.5);
      expect(copy.remainingAmount, 10000000);
    });

    test('no milestones is written as null so RTDB removes the field', () {
      final goal = SavingsGoal(
          id: '-N',
          name: 'Trip',
          targetAmount: 100,
          currentAmount: 0,
          targetDate: 1);
      expect(goal.toMap()[DbFields.milestones], isNull);
    });

    test('progress stays between 0 and 1', () {
      final overTarget = SavingsGoal(
          id: '-N',
          name: 'A',
          targetAmount: 100,
          currentAmount: 150,
          targetDate: 1);
      final zeroTarget = SavingsGoal(
          id: '-N',
          name: 'B',
          targetAmount: 0,
          currentAmount: 10,
          targetDate: 1);
      expect(overTarget.progress, 1);
      expect(overTarget.remainingAmount, 0);
      expect(zeroTarget.progress, 0);
    });
  });

  group('Category', () {
    test('default and custom categories read from different nodes', () {
      final food = Category.fromDefaultMap(
          'food', {'type': 'expense', 'icon': 'restaurant', 'sortOrder': 1});
      final custom = Category.fromCustomMap('-Ncat',
          {'name': 'Gym', 'type': 'expense', 'icon': 'fitness_center'});

      expect(food.isDefault, isTrue);
      expect(food.name, isNull);
      expect(custom.isDefault, isFalse);
      expect(custom.name, 'Gym');
      expect(custom.sortOrder, AppDefaults.customCategorySortOrder);
    });
  });

  group('AppSettings', () {
    test('empty node falls back to defaults', () {
      final settings = AppSettings.fromMap({});
      expect(settings.defaultAlertThreshold, AppDefaults.alertThreshold);
      expect(settings.announcementFor('vi'), '');
    });

    test('announcement is shown only when active', () {
      final settings = AppSettings.fromMap({
        'announcement_en': 'Hello',
        'announcement_vi': 'Xin chào',
        'announcementActive': true,
      });
      expect(settings.announcementFor('vi'), 'Xin chào');
      expect(settings.announcementFor('en'), 'Hello');
    });
  });
}
