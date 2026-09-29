import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';
import 'package:pennypal_student/models/transaction_record.dart';
import 'package:pennypal_student/utils/chatbot_engine.dart';
import 'package:pennypal_student/utils/constants.dart';

TransactionRecord expense(String id, double amount, DateTime date, {String categoryId = CategoryKeys.food}) {
  return TransactionRecord(
    id: id,
    type: TransactionTypes.expense,
    amount: amount,
    categoryId: categoryId,
    date: date.millisecondsSinceEpoch,
  );
}

ChatbotEngine engineFor(List<TransactionRecord> transactions, DateTime now, {String languageCode = 'en'}) {
  final ChatbotData data = ChatbotData(userName: 'Minh', transactions: transactions, budgets: [], goals: [], customCategories: []);
  return ChatbotEngine(data: data, l10n: lookupAppLocalizations(Locale(languageCode)), languageCode: languageCode, now: now);
}

void main() {
  setUpAll(() => initializeDateFormatting());

  final DateTime september5 = DateTime(2026, 9, 5, 12);
  final List<TransactionRecord> thisMonthOnly = [expense('t1', 150000, DateTime(2026, 9, 2))];

  group('Questions about last month', () {
    test('"last month" does not get this month\'s numbers', () {
      final String answer = engineFor(thisMonthOnly, september5).reply('How much did I spend on food last month?').text;
      expect(answer, contains('open Reports'));
      expect(answer, isNot(contains('150')));
    });

    test('"tháng trước" in Vietnamese, with or without accents', () {
      final ChatbotEngine engine = engineFor(thisMonthOnly, september5, languageCode: 'vi');
      expect(engine.reply('Tháng trước chi bao nhiêu?').text, contains('mở mục Báo cáo'));
      expect(engine.reply('thang truoc chi bao nhieu').text, contains('mở mục Báo cáo'));
    });

    test('"this month" still answers with this month\'s numbers', () {
      final String answer = engineFor(thisMonthOnly, september5).reply('How much did I spend this month?').text;
      expect(answer, isNot(contains('open Reports')));
    });
  });

  group('Compare with last month (same days)', () {
    test('on the 5th only days 1-5 of last month are counted', () {
      final List<TransactionRecord> transactions = [
        ...thisMonthOnly,
        expense('a1', 100000, DateTime(2026, 8, 3)),
        expense('a2', 900000, DateTime(2026, 8, 20)),
      ];
      final String answer = engineFor(transactions, september5).reply('Compare with last month').text;
      expect(answer, contains('50.0% more'));
    });

    test('equal spending says "the same", not "0.0% less. Nice!"', () {
      final List<TransactionRecord> transactions = [
        expense('t1', 100000, DateTime(2026, 9, 2)),
        expense('a1', 100000, DateTime(2026, 8, 4)),
      ];
      final String answer = engineFor(transactions, september5).reply('Compare with last month').text;
      expect(answer, contains('the same'));
      expect(answer, isNot(contains('0.0%')));
    });

    test('on the 31st a 30-day last month is counted in full', () {
      final List<TransactionRecord> transactions = [
        expense('t1', 100000, DateTime(2026, 10, 5)),
        expense('s1', 200000, DateTime(2026, 9, 30)),
      ];
      final String answer = engineFor(transactions, DateTime(2026, 10, 31, 12)).reply('Compare with last month').text;
      expect(answer, contains('50.0% less'));
    });

    test('goal contributions are not spending', () {
      final List<TransactionRecord> transactions = [
        ...thisMonthOnly,
        expense('a1', 100000, DateTime(2026, 8, 3)),
        expense('g1', 500000, DateTime(2026, 8, 4), categoryId: CategoryKeys.savings),
      ];
      final String answer = engineFor(transactions, september5).reply('Compare with last month').text;
      expect(answer, contains('50.0% more'));
    });
  });
}
