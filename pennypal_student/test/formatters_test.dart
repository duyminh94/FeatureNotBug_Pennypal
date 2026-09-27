import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_student/utils/constants.dart';
import 'package:pennypal_student/utils/formatters.dart';

void main() {
  group('Formatters currency support (UI-05)', () {
    tearDown(() {
      // Restore default currency after each test
      Formatters.setCurrency(AppDefaults.currency);
    });

    test('VND formatting matches UI-05 expectations', () {
      Formatters.setCurrency(Currencies.vnd);
      expect(Formatters.activeCurrency, Currencies.vnd);
      expect(Formatters.isUsd, isFalse);
      expect(Formatters.currencySymbol, '₫');
      expect(Formatters.money(1234500), '1.234.500 ₫');
      expect(Formatters.signedMoney(1234500, isIncome: true), '+1.234.500 ₫');
      expect(Formatters.signedMoney(1234500, isIncome: false), '−1.234.500 ₫');
      expect(Formatters.groupDigits(1250000), '1.250.000');
    });

    test('USD formatting matches UI-05 expectations', () {
      Formatters.setCurrency(Currencies.usd);
      expect(Formatters.activeCurrency, Currencies.usd);
      expect(Formatters.isUsd, isTrue);
      expect(Formatters.currencySymbol, r'$');
      expect(Formatters.money(1234.5), r'$1,234.50');
      expect(Formatters.signedMoney(1234.5, isIncome: true), r'+$1,234.50');
      expect(Formatters.signedMoney(1234.5, isIncome: false), r'−$1,234.50');
      expect(Formatters.groupDigits(1250000), '1,250,000');
    });

    test('Explicit currency argument overrides active currency', () {
      Formatters.setCurrency(Currencies.vnd);
      expect(Formatters.money(1234.5, Currencies.usd), r'$1,234.50');
      expect(Formatters.money(1234500, Currencies.vnd), '1.234.500 ₫');
      expect(Formatters.signedMoney(1234.5, isIncome: true, currency: Currencies.usd), r'+$1,234.50');
      expect(Formatters.signedMoney(1234500, isIncome: true, currency: Currencies.vnd), '+1.234.500 ₫');
    });
  });
}
