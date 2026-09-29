import 'constants.dart';
import 'text_normalizer.dart';

class CategoryKeywords {
  static const Map<String, List<String>> _englishKeywords = {
    CategoryKeys.food: ['food', 'eat', 'meal', 'lunch', 'coffee', 'tea', 'dinner', 'breakfast', 'snack', 'drink'],
    CategoryKeys.transport: ['transport', 'bus', 'taxi', 'grab', 'fuel', 'uber', 'train', 'parking'],
    CategoryKeys.education: ['book', 'course', 'tuition', 'study', 'school', 'textbook'],
    CategoryKeys.shopping: ['shopping', 'clothes', 'buy', 'shoes'],
    CategoryKeys.entertainment: ['movie', 'game', 'fun', 'netflix', 'cinema', 'concert'],
    CategoryKeys.bills: ['bill', 'rent', 'electricity', 'internet', 'phone', 'wifi'],
  };

  static const Map<String, List<String>> _vietnameseKeywords = {
    CategoryKeys.food: ['ăn uống', 'ăn', 'cơm', 'bún', 'phở', 'cà phê', 'trà sữa'],
    CategoryKeys.transport: ['đi lại', 'xe buýt', 'xe', 'xăng'],
    CategoryKeys.education: ['sách', 'học phí', 'khóa học', 'học'],
    CategoryKeys.shopping: ['mua sắm', 'quần áo', 'mua'],
    CategoryKeys.entertainment: ['phim', 'giải trí', 'chơi'],
    CategoryKeys.bills: ['hóa đơn', 'tiền nhà', 'điện thoại', 'điện', 'nước', 'mạng'],
  };

  static String? findCategory(String text, {Set<String> ignoredKeywords = const {}}) {
    final String normalized = TextNormalizer.normalize(text);
    for (final String categoryId in _englishKeywords.keys) {
      final List<String> keywords = [..._englishKeywords[categoryId]!, ..._vietnameseKeywords[categoryId] ?? []];
      for (final String keyword in keywords) {
        final String plainKeyword = TextNormalizer.normalize(keyword);
        if (ignoredKeywords.contains(plainKeyword)) continue;
        if (RegExp('\\b${RegExp.escape(plainKeyword)}\\b').hasMatch(normalized)) return categoryId;
      }
    }
    return null;
  }
}
