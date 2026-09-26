import 'constants.dart';
import 'text_normalizer.dart';

/// Keywords of the default categories (words.md section 8), used by receipt scan and the chatbot.
class CategoryKeywords {
  static const Map<String, List<String>> _keywordsByCategory = {
    CategoryKeys.food: ['food', 'eat', 'meal', 'lunch', 'coffee', 'an uong', 'an', 'com', 'bun', 'pho', 'ca phe', 'tra sua'],
    CategoryKeys.transport: ['transport', 'bus', 'taxi', 'grab', 'fuel', 'di lai', 'xe buyt', 'xe', 'xang'],
    CategoryKeys.education: ['book', 'course', 'tuition', 'study', 'sach', 'hoc phi', 'khoa hoc', 'hoc'],
    CategoryKeys.shopping: ['shopping', 'clothes', 'buy', 'mua sam', 'quan ao', 'mua'],
    CategoryKeys.entertainment: ['movie', 'game', 'fun', 'phim', 'giai tri', 'choi'],
    CategoryKeys.bills: ['bill', 'rent', 'electricity', 'internet', 'phone', 'hoa don', 'tien nha', 'dien thoai', 'dien', 'nuoc', 'mang'],
  };

  /// Returns the first category whose keyword appears as a whole word, or null when nothing matches.
  /// [ignoredKeywords] lets the receipt parser skip words printed on every receipt, such as "hoa don".
  static String? findCategory(String text, {Set<String> ignoredKeywords = const {}}) {
    final String normalized = TextNormalizer.normalize(text);
    for (final MapEntry<String, List<String>> entry in _keywordsByCategory.entries) {
      for (final String keyword in entry.value) {
        if (ignoredKeywords.contains(keyword)) continue;
        if (RegExp('\\b${RegExp.escape(keyword)}\\b').hasMatch(normalized)) return entry.key;
      }
    }
    return null;
  }
}
