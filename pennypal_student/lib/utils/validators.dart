import 'category_display.dart';
import 'constants.dart';

class Validators {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _letterPattern = RegExp(r'[A-Za-z]');
  static final RegExp _digitPattern = RegExp(r'[0-9]');
  static final RegExp _mobilePattern = RegExp(r'^[0-9]{9,15}$');

  static bool isEmpty(String? value) => (value ?? '').trim().isEmpty;

  static bool isValidEmail(String? value) => _emailPattern.hasMatch((value ?? '').trim());

  static bool isValidPassword(String? value) {
    final String password = value ?? '';
    return password.length >= 8 && _letterPattern.hasMatch(password) && _digitPattern.hasMatch(password);
  }

  static bool isValidMobile(String? value) => _mobilePattern.hasMatch((value ?? '').trim());

  static double? parseAmount(String? value) {
    final String digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? null : double.parse(digits);
  }

  static bool isLengthBetween(String? value, int min, int max) {
    final int length = (value ?? '').trim().length;
    return length >= min && length <= max;
  }

  static bool isPositiveAmount(double? amount) => amount != null && amount > 0;

  static bool isWithinMaxAmount(double amount) => amount <= AppDefaults.maxAmount;

  static bool isNotFutureDate(DateTime date, {DateTime? now}) {
    final DateTime today = now ?? DateTime.now();
    final DateTime endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59, 999);
    return !date.isAfter(endOfToday);
  }

  static bool isCategoryAllowed(String? categoryId, String type) {
    if (categoryId == null) return false;
    return CategoryDisplay.selectableIds(type).contains(categoryId);
  }
}
