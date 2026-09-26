import 'package:intl/intl.dart';

/// Turns numbers and dates into text for the current language.
class Formatters {
  /// Number with thousand separators, e.g. 1,250 (EN) or 1.250 (VI).
  static String count(num value, String languageCode) => NumberFormat.decimalPattern(languageCode).format(value);

  /// Date as dd/MM/yyyy.
  static String fullDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  /// Full day title such as "Saturday, September 26, 2026".
  static String dayTitle(DateTime date, String languageCode) {
    final String text = DateFormat.yMMMMEEEEd(languageCode).format(date);
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Month title such as "September 2026".
  static String monthLabel(DateTime month, String languageCode) {
    final String text = DateFormat.yMMMM(languageCode).format(month);
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Avatar letters: first letter of the first and last word, e.g. "PennyPal Admin" -> "PA".
  static String initials(String name) {
    final String trimmedName = name.trim();
    if (trimmedName.isEmpty) return '?';

    final List<String> words = trimmedName.split(RegExp(r'\s+'));
    final String firstLetter = words.first[0];
    final String lastLetter = words.length > 1 ? words.last[0] : '';
    return (firstLetter + lastLetter).toUpperCase();
  }
}
