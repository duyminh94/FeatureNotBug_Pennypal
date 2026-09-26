import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formats money and dates the same way on every screen.
class Formatters {
  static final NumberFormat _vndFormat = NumberFormat('#,##0', 'vi');

  /// 4235000 -> "4.235.000 ₫"
  static String money(double amount) => '${_vndFormat.format(amount.round())} ₫';

  /// Adds "+" for income and "−" for expense: "+3.000.000 ₫", "−45.000 ₫".
  static String signedMoney(double amount, {required bool isIncome}) {
    return '${isIncome ? '+' : '−'}${money(amount.abs())}';
  }

  /// Returns todayLabel when the date is today, otherwise "dd/MM".
  static String shortDate(int millis, {required String todayLabel, DateTime? now}) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(millis);
    final DateTime today = now ?? DateTime.now();
    final bool isToday = date.year == today.year && date.month == today.month && date.day == today.day;
    return isToday ? todayLabel : DateFormat('dd/MM').format(date);
  }

  /// "03/2027"
  static String monthYear(int millis) => DateFormat('MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(millis));

  static String initials(String name) {
    final List<String> words = name.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    final String last = words.length > 1 ? words.last[0] : '';
    return (words.first[0] + last).toUpperCase();
  }

  static String givenName(String fullName) {
    final List<String> words = fullName.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
    return words.isEmpty ? '' : words.last;
  }

  static String monthLabel(DateTime month, String languageCode) {
    final String text = DateFormat.yMMMM(languageCode).format(month);
    return text[0].toUpperCase() + text.substring(1);
  }

  /// "22/09/2026"
  static String fullDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  /// 1250000 -> "1.250.000" (no currency sign, used inside the amount field).
  static String groupDigits(double amount) => _vndFormat.format(amount.round());
}

/// Keeps only digits while typing and adds dots between thousands: "1250000" -> "1.250.000".
class ThousandsInputFormatter extends TextInputFormatter {
  static const int _maxDigits = 12;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    if (digits.length > _maxDigits) return oldValue;

    final String formatted = Formatters.groupDigits(double.parse(digits));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
