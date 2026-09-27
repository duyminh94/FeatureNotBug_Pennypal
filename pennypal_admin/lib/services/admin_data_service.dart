import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

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
        if (item is! Map) continue;
        // One record with a wrong type (e.g. amount "abc") is skipped so the whole Overview still loads.
        try {
          transactions.add(TransactionRecord.fromMap(id.toString(), item));
        } catch (e) {
          debugPrint('AdminDataService skipped transaction $uid/$id: $e');
        }
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
  /// All reads start together (Future.wait), so the wait is the slowest read, not the 7 reads added up.
  /// Throws when a read fails, so the screen can show "Try again".
  static Future<AdminData> load() async {
    final Future<AppSettings?> settingsFuture = SettingsService.load();
    final List<Object?> values = await Future.wait([
      _read(UserService.node),
      _read(transactionsNode),
      _read(goalsNode),
      _read(SupportService.node),
      _read(FeedbackService.node),
      _read(LearningService.node),
    ]);
    final AppSettings settings = await settingsFuture ?? AppSettings();

    return AdminData(
      users: UserService.listFromValue(values[0]),
      transactionsByUser: transactionsByUserFromValue(values[1]),
      goalCountByUser: goalCountByUserFromValue(values[2]),
      supportByUser: SupportService.byUserFromValue(values[3]),
      feedbacks: FeedbackService.listFromValue(values[4]),
      lessons: LearningService.listFromValue(values[5]),
      settings: settings,
    );
  }
}
