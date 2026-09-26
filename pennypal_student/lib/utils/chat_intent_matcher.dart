import 'package:string_similarity/string_similarity.dart';

import 'text_normalizer.dart';

enum ChatIntent {
  greeting,
  help,
  topSpending,
  monthSummary,
  budgetRemaining,
  goalProgress,
  compareLastMonth,
  budgetingTips,
  savingTips,
  needsVsWants,
  unknown,
}

class ChatIntentMatcher {
  static const double similarityThreshold = 0.5;
  static const int maxMessageLength = 300;

  static const Map<ChatIntent, List<String>> _keywords = {
    ChatIntent.greeting: ['hi', 'hello', 'hey', 'chao', 'xin chao', 'alo'],
    ChatIntent.help: ['help', 'what can you do', 'giup', 'lam duoc gi', 'huong dan'],
    ChatIntent.topSpending: ['most', 'spend most', 'biggest', 'top', 'nhieu nhat', 'tieu nhieu', 'ton nhat'],
    ChatIntent.monthSummary: ['total', 'how much', 'spent this month', 'tong', 'bao nhieu', 'chi het', 'thang nay'],
    ChatIntent.budgetRemaining: ['budget', 'left', 'is left', 'remaining', 'limit', 'ngan sach', 'con lai', 'con bao nhieu', 'han muc'],
    ChatIntent.goalProgress: ['goal', 'target', 'progress', 'muc tieu', 'tien do', 'dat chua'],
    ChatIntent.compareLastMonth: ['last month', 'compare', 'vs', 'thang truoc', 'so voi', 'so sanh'],
    ChatIntent.budgetingTips: ['how to budget', 'should i budget', '50/30/20', 'plan', 'lap ngan sach', 'chia tien', 'ke hoach'],
    ChatIntent.savingTips: ['save', 'saving tips', 'save money', 'tiet kiem', 'de danh', 'meo'],
    ChatIntent.needsVsWants: ['need', 'needs', 'want', 'wants', 'necessary', 'can thiet', 'tuy chon', 'nen mua'],
  };

  static const Map<ChatIntent, List<String>> _examples = {
    ChatIntent.greeting: ['hello', 'xin chao'],
    ChatIntent.help: ['what can you do', 'ban lam duoc gi'],
    ChatIntent.topSpending: ['what did i spend most on', 'thang nay tieu nhieu nhat vao gi'],
    ChatIntent.monthSummary: ['how much did i spend this month', 'thang nay chi bao nhieu'],
    ChatIntent.budgetRemaining: ['how much budget is left', 'con bao nhieu tien an', 'budget remaining'],
    ChatIntent.goalProgress: ['how is my goal going', 'muc tieu toi dau roi'],
    ChatIntent.compareLastMonth: ['compare with last month', 'so voi thang truoc the nao'],
    ChatIntent.budgetingTips: ['how should i budget', 'chia tien the nao'],
    ChatIntent.savingTips: ['how can i save money', 'tiet kiem the nao'],
    ChatIntent.needsVsWants: ['needs vs wants', 'cai nao can thiet'],
  };

  static bool canSend(String text) {
    final String trimmed = text.trim();
    return trimmed.isNotEmpty && trimmed.length <= maxMessageLength;
  }

  static String _clean(String text) {
    return TextNormalizer.normalize(text).replaceAll(RegExp(r'[^a-z0-9/ ]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static bool _containsPhrase(String text, String phrase) {
    return RegExp('(^| )${RegExp.escape(phrase)}( |\$)').hasMatch(text);
  }

  static ChatIntent detect(String message) {
    final String text = _clean(message);
    if (text.isEmpty) return ChatIntent.unknown;

    ChatIntent best = ChatIntent.unknown;
    int bestScore = 0;
    int bestMatches = 0;
    for (final MapEntry<ChatIntent, List<String>> entry in _keywords.entries) {
      int score = 0;
      int matches = 0;
      for (final String keyword in entry.value) {
        if (!_containsPhrase(text, keyword)) continue;
        score += keyword.split(' ').length;
        matches++;
      }
      final bool isBetter = score > bestScore || (score == bestScore && matches > bestMatches);
      if (score > 0 && isBetter) {
        best = entry.key;
        bestScore = score;
        bestMatches = matches;
      }
    }
    if (bestScore > 0) return best;

    double bestSimilarity = 0;
    for (final MapEntry<ChatIntent, List<String>> entry in _examples.entries) {
      for (final String example in entry.value) {
        final double similarity = StringSimilarity.compareTwoStrings(text, example);
        if (similarity > bestSimilarity) {
          best = entry.key;
          bestSimilarity = similarity;
        }
      }
    }
    return bestSimilarity >= similarityThreshold ? best : ChatIntent.unknown;
  }
}
