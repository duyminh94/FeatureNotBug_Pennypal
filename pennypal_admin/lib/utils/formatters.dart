import 'package:intl/intl.dart';

class Formatters {
  static String count(num value, String languageCode) => NumberFormat.decimalPattern(languageCode).format(value);

  static String fullDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  static String dayTitle(DateTime date, String languageCode) {
    final String text = DateFormat.yMMMMEEEEd(languageCode).format(date);
    return text[0].toUpperCase() + text.substring(1);
  }

  static String monthLabel(DateTime month, String languageCode) {
    final String text = DateFormat.yMMMM(languageCode).format(month);
    return text[0].toUpperCase() + text.substring(1);
  }

  static String initials(String name) {
    final List<String> words = name.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    final String last = words.length > 1 ? words.last[0] : '';
    return (words.first[0] + last).toUpperCase();
  }
}
