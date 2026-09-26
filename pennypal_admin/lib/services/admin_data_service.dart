import 'package:firebase_database/firebase_database.dart';

import '../models/app_settings.dart';
import '../models/transaction_record.dart';
import '../utils/sample_data.dart';
import 'feedback_service.dart';
import 'learning_service.dart';
import 'settings_service.dart';
import 'support_service.dart';
import 'user_service.dart';

/// Loads the real data the Overview and Analytics screens count and chart.
///
/// Realtime Database has no "sum / count / group by", so every node is read once with get()
/// and grouped in the app with Map (one pass, O(n)). Security Rules let only an admin read them.
class AdminDataService {
  static const String transactionsNode = 'transactions';
  static const String goalsNode = 'savings_goals';

  // Without a time limit the Overview would spin forever when there is no internet.
  static const Duration readTimeout = Duration(seconds: 15);

  static Future<Object?> _read(String node) async {
    final DataSnapshot snapshot = await FirebaseDatabase.instance.ref(node).get().timeout(readTimeout);
    return snapshot.value;
  }

  /// transactions/{uid}/{transactionId} -> list of transactions for each student uid.
  static Map<String, List<TransactionRecord>> transactionsByUserFromValue(Object? value) {
    final Map<String, List<TransactionRecord>> result = {};
    if (value is! Map) return result;

    for (final uid in value.keys) {
      final userTransactions = value[uid];
      if (userTransactions is! Map) continue;

      final List<TransactionRecord> transactions = [];
      for (final id in userTransactions.keys) {
        final item = userTransactions[id];
        if (item is Map) transactions.add(TransactionRecord.fromMap(id.toString(), item));
      }
      result[uid.toString()] = transactions;
    }
    return result;
  }

  /// savings_goals/{uid}/{goalId} -> number of goals for each student uid.
  static Map<String, int> goalCountByUserFromValue(Object? value) {
    final Map<String, int> result = {};
    if (value is! Map) return result;

    for (final uid in value.keys) {
      final userGoals = value[uid];
      result[uid.toString()] = userGoals is Map ? userGoals.length : 0;
    }
    return result;
  }

  /// Reads users, transactions, goals, help requests, feedback, lessons and settings once.
  /// Throws when a read fails, so the screen can show "Try again".
  static Future<AdminData> load() async {
    final Object? users = await _read(UserService.node);
    final Object? transactions = await _read(transactionsNode);
    final Object? goals = await _read(goalsNode);
    final Object? support = await _read(SupportService.node);
    final Object? feedbacks = await _read(FeedbackService.node);
    final Object? lessons = await _read(LearningService.node);
    final AppSettings settings = await SettingsService.load() ?? AppSettings();

    return AdminData(
      users: UserService.listFromValue(users),
      transactionsByUser: transactionsByUserFromValue(transactions),
      supportByUser: SupportService.byUserFromValue(support),
      goalCountByUser: goalCountByUserFromValue(goals),
      feedbacks: FeedbackService.listFromValue(feedbacks),
      lessons: LearningService.listFromValue(lessons),
      settings: settings,
    );
  }
}
