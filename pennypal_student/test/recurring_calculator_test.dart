import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_student/models/recurring_item.dart';
import 'package:pennypal_student/models/transaction_record.dart';
import 'package:pennypal_student/utils/constants.dart';
import 'package:pennypal_student/utils/recurring_calculator.dart';

RecurringItem rent({int day = 5, String lastCreatedMonth = '2026-09', bool isActive = true}) {
  return RecurringItem(
    id: 'rent',
    type: TransactionTypes.expense,
    amount: 2000000,
    categoryId: CategoryKeys.miscellaneous,
    description: 'Room rent',
    paymentMode: PaymentModes.bankTransfer,
    dayOfMonth: day,
    lastCreatedMonth: lastCreatedMonth,
    isActive: isActive,
  );
}

void main() {
  group('RecurringCalculator.datesToCreate', () {
    test('before the day of the month nothing is created', () {
      expect(RecurringCalculator.datesToCreate(rent(), DateTime(2026, 10, 4, 23, 59)), isEmpty);
    });

    test('on the day itself the month is created', () {
      expect(RecurringCalculator.datesToCreate(rent(), DateTime(2026, 10, 5, 8)), [DateTime(2026, 10, 5)]);
    });

    test('app not opened for months: every missing month is created, oldest first', () {
      final List<DateTime> dates = RecurringCalculator.datesToCreate(rent(lastCreatedMonth: '2026-07'), DateTime(2026, 10, 10));
      expect(dates, [DateTime(2026, 8, 5), DateTime(2026, 9, 5), DateTime(2026, 10, 5)]);
    });

    test('the 31st becomes the last day of February and April', () {
      final List<DateTime> dates = RecurringCalculator.datesToCreate(rent(day: 31, lastCreatedMonth: '2027-01'), DateTime(2027, 4, 30));
      expect(dates, [DateTime(2027, 2, 28), DateTime(2027, 3, 31), DateTime(2027, 4, 30)]);
    });

    test('leap year: the 31st becomes 29 February', () {
      final List<DateTime> dates = RecurringCalculator.datesToCreate(rent(day: 31, lastCreatedMonth: '2028-01'), DateTime(2028, 2, 29));
      expect(dates, [DateTime(2028, 2, 29)]);
    });

    test('new year: December to January', () {
      final List<DateTime> dates = RecurringCalculator.datesToCreate(rent(day: 1, lastCreatedMonth: '2026-12'), DateTime(2027, 1, 1));
      expect(dates, [DateTime(2027, 1, 1)]);
    });

    test('a month already created (even if the student deleted it) is not created again', () {
      expect(RecurringCalculator.datesToCreate(rent(lastCreatedMonth: '2026-10'), DateTime(2026, 10, 20)), isEmpty);
    });

    test('a stopped item creates nothing', () {
      expect(RecurringCalculator.datesToCreate(rent(isActive: false, lastCreatedMonth: '2026-07'), DateTime(2026, 10, 10)), isEmpty);
    });

    test('empty or broken lastCreatedMonth creates nothing instead of crashing', () {
      expect(RecurringCalculator.datesToCreate(rent(lastCreatedMonth: ''), DateTime(2026, 10, 10)), isEmpty);
      expect(RecurringCalculator.datesToCreate(rent(lastCreatedMonth: 'abc'), DateTime(2026, 10, 10)), isEmpty);
    });
  });

  group('RecurringCalculator transactions', () {
    test('the id only depends on the item and the month', () {
      expect(RecurringCalculator.transactionId('rent', DateTime(2026, 10, 5)), 'rec_rent_2026-10');
      expect(RecurringCalculator.transactionId('rent', DateTime(2026, 10, 28)), 'rec_rent_2026-10');
    });

    test('the transaction copies amount, type, category, note and payment mode', () {
      final TransactionRecord transaction = RecurringCalculator.buildTransaction(rent(), DateTime(2026, 10, 5), 111);
      expect(transaction.id, 'rec_rent_2026-10');
      expect(transaction.type, TransactionTypes.expense);
      expect(transaction.amount, 2000000);
      expect(transaction.categoryId, CategoryKeys.miscellaneous);
      expect(transaction.description, 'Room rent');
      expect(transaction.paymentMode, PaymentModes.bankTransfer);
      expect(transaction.date, DateTime(2026, 10, 5).millisecondsSinceEpoch);
      expect(transaction.goalId, isNull);
      expect(transaction.createdAt, 111);
    });
  });

  group('RecurringItem map', () {
    test('toMap and fromMap give back the same item', () {
      final RecurringItem item = RecurringItem.fromMap('rent', rent().toMap());
      expect(item.id, 'rent');
      expect(item.amount, 2000000);
      expect(item.dayOfMonth, 5);
      expect(item.lastCreatedMonth, '2026-09');
      expect(item.isActive, isTrue);
      expect(item.paymentMode, PaymentModes.bankTransfer);
    });

    test('missing fields get safe defaults', () {
      final RecurringItem item = RecurringItem.fromMap('x', {});
      expect(item.type, TransactionTypes.expense);
      expect(item.amount, 0);
      expect(item.dayOfMonth, 1);
      expect(item.lastCreatedMonth, '');
      expect(item.isActive, isTrue);
    });
  });
}
