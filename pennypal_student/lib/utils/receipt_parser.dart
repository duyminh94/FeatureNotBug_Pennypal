import '../models/receipt_scan_result.dart';
import 'category_keywords.dart';
import 'constants.dart';
import 'text_normalizer.dart';

/// Turns the text read from a receipt into form values (BR-91 to BR-95). Pure Dart, no ML Kit here.
class ReceiptParser {
  /// Longer phrases first, compared after removing accents (words.md section 10).
  static const List<String> _totalKeywords = [
    'can thanh toan',
    'grand total',
    'amount due',
    'tong cong',
    'tong tien',
    'thanh toan',
    'thanh tien',
    'total',
    'amount',
    'tong',
  ];

  /// Header words printed on almost every receipt; they are not a description or a category hint.
  static const List<String> _headerWords = ['hoa don', 'receipt', 'invoice', 'phieu tinh tien', 'phieu thanh toan'];

  static final RegExp _datePattern = RegExp(r'\b(\d{1,2})[/.-](\d{1,2})[/.-](\d{2,4})\b');
  static final RegExp _timePattern = RegExp(r'\b\d{1,2}:\d{2}(:\d{2})?\b');
  static final RegExp _numberPattern = RegExp(r'\d[\d.,]*');
  static final RegExp _letterPattern = RegExp(r'[a-z]');
  static final RegExp _digitPattern = RegExp(r'[0-9]');

  static ReceiptScanResult parse(String text, {DateTime? now}) {
    final DateTime today = now ?? DateTime.now();
    final List<String> lines = text.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
    if (lines.isEmpty) {
      return ReceiptScanResult(hasText: false, date: today);
    }

    final DateTime? receiptDate = _findDate(text, today);
    return ReceiptScanResult(
      hasText: true,
      amount: _findAmount(lines),
      description: _findDescription(lines),
      date: receiptDate ?? today,
      isDateFromReceipt: receiptDate != null,
      categoryId: CategoryKeywords.findCategory(text, ignoredKeywords: {'hoa don'}),
    );
  }

  /// BR-93: understands 1.234.000 · 1,234,000 · 1234000đ · 12.50. Returns null for anything that is not an amount.
  static double? parseNumber(String token) {
    final String cleaned = token.replaceAll(RegExp(r'[.,]+$'), '');
    final String digitsOnly = cleaned.replaceAll(RegExp(r'[.,]'), '');
    if (digitsOnly.isEmpty) return null;
    // BR-92: long digit strings are phone numbers or invoice codes; a leading 0 with 9+ digits is a phone number.
    if (digitsOnly.length > 10) return null;
    final bool hasSeparator = cleaned.contains('.') || cleaned.contains(',');
    if (!hasSeparator && cleaned.length >= 9 && cleaned.startsWith('0')) return null;
    if (!hasSeparator) return double.parse(cleaned);

    final int lastSeparatorIndex = cleaned.lastIndexOf(RegExp(r'[.,]'));
    final String afterLastSeparator = cleaned.substring(lastSeparatorIndex + 1);
    final List<String> groups = cleaned.split(RegExp(r'[.,]'));
    final bool isGrouping = groups.skip(1).every((group) => group.length == 3);

    if (isGrouping) return double.parse(digitsOnly);
    if (afterLastSeparator.length <= 2) {
      final String wholePart = cleaned.substring(0, lastSeparatorIndex).replaceAll(RegExp(r'[.,]'), '');
      return double.parse('$wholePart.$afterLastSeparator');
    }
    return null;
  }

  static List<double> _numbersInLine(String line) {
    final String withoutDates = line.replaceAll(_datePattern, ' ').replaceAll(_timePattern, ' ');
    final List<double> numbers = [];
    for (final RegExpMatch match in _numberPattern.allMatches(withoutDates)) {
      final double? value = parseNumber(match.group(0)!);
      if (value != null) numbers.add(value);
    }
    return numbers;
  }

  static bool _hasTotalKeyword(String normalizedLine) {
    return _totalKeywords.any((keyword) => RegExp('\\b${RegExp.escape(keyword)}\\b').hasMatch(normalizedLine));
  }

  /// BR-91: prefer numbers on a "total" line (or the line right after it); otherwise the largest number.
  static double? _findAmount(List<String> lines) {
    final List<double> totalLineNumbers = [];
    final List<double> allNumbers = [];

    for (int index = 0; index < lines.length; index++) {
      final List<double> numbers = _numbersInLine(lines[index]);
      allNumbers.addAll(numbers);
      if (!_hasTotalKeyword(TextNormalizer.normalize(lines[index]))) continue;

      final bool valueIsOnNextLine = numbers.isEmpty && index + 1 < lines.length;
      totalLineNumbers.addAll(valueIsOnNextLine ? _numbersInLine(lines[index + 1]) : numbers);
    }

    final List<double> candidates = (totalLineNumbers.isNotEmpty ? totalLineNumbers : allNumbers)
        .where((amount) => amount > 0 && amount <= AppDefaults.maxAmount)
        .toList();
    if (candidates.isEmpty) return null;
    return candidates.reduce((largest, amount) => amount > largest ? amount : largest);
  }

  /// BR-94: the first line that is mostly letters and is not a header or a total line.
  static String? _findDescription(List<String> lines) {
    for (final String line in lines) {
      final String normalized = TextNormalizer.normalize(line);
      final int letterCount = _letterPattern.allMatches(normalized).length;
      final int digitCount = _digitPattern.allMatches(normalized).length;
      final bool isHeader = _headerWords.any((word) => normalized.startsWith(word));
      if (letterCount < 3 || letterCount <= digitCount || isHeader || _hasTotalKeyword(normalized)) continue;

      final int maxLength = AppDefaults.descriptionMaxLength;
      return line.length > maxLength ? line.substring(0, maxLength) : line;
    }
    return null;
  }

  /// BR-94: first dd/mm/yyyy date; a future or impossible date counts as "not found".
  static DateTime? _findDate(String text, DateTime today) {
    final RegExpMatch? match = _datePattern.firstMatch(text);
    if (match == null) return null;

    final int day = int.parse(match.group(1)!);
    final int month = int.parse(match.group(2)!);
    final int rawYear = int.parse(match.group(3)!);
    final int year = rawYear < 100 ? 2000 + rawYear : rawYear;
    final DateTime date = DateTime(year, month, day);

    final bool isRealDate = date.year == year && date.month == month && date.day == day;
    final DateTime endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59);
    return isRealDate && !date.isAfter(endOfToday) ? date : null;
  }
}
