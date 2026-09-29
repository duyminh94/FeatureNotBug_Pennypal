import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../utils/constants.dart';

class Formatters {
  static final NumberFormat _vndFormat = NumberFormat('#,##0', 'vi');
  static final NumberFormat _usdFormat = NumberFormat.currency(locale: 'en_US', symbol: r'$');
  static final NumberFormat _usdGroupFormat = NumberFormat('#,##0', 'en_US');

  static String activeCurrency = AppDefaults.currency;

  static void setCurrency(String currency) {
    activeCurrency = currency;
  }

  static bool get isUsd => activeCurrency == Currencies.usd;

  static String get currencySymbol => isUsd ? r'$' : '₫';

  static String money(double amount, [String? currency]) {
    final String curr = currency ?? activeCurrency;
    if (curr == Currencies.usd) {
      return _usdFormat.format(amount);
    }
    return '${_vndFormat.format(amount.round())} ₫';
  }

  static String signedMoney(double amount, {required bool isIncome, String? currency}) {
    final String sign = isIncome ? '+' : '−';
    final String curr = currency ?? activeCurrency;
    final String formatted = money(amount.abs(), curr);
    return '$sign$formatted';
  }

  static String shortDate(int millis, {required String todayLabel, DateTime? now}) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(millis);
    final DateTime today = now ?? DateTime.now();
    final bool isToday = date.year == today.year && date.month == today.month && date.day == today.day;
    return isToday ? todayLabel : DateFormat('dd/MM').format(date);
  }

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

  static String fullDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  static String groupDigits(double amount, [String? currency]) {
    final String curr = currency ?? activeCurrency;
    if (curr == Currencies.usd) {
      return _usdGroupFormat.format(amount.round());
    }
    return _vndFormat.format(amount.round());
  }
}

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
