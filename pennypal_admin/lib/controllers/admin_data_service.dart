import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
import '../models/transaction_record.dart';
import '../models/admin_data.dart';
import 'feedback_service.dart';
import 'learning_service.dart';
import 'settings_service.dart';
import 'support_service.dart';
import 'user_service.dart';

class AdminDataService {
  static const String transactionsNode = 'transactions';
  static const String goalsNode = 'savings_goals';

  static const Duration readTimeout = Duration(seconds: 15);

  static Future<Object?> _read(String node) async {
    final DataSnapshot snapshot = await FirebaseDatabase.instance.ref(node).get().timeout(readTimeout);
    return snapshot.value;
  }

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

  static Map<String, int> goalCountByUserFromValue(Object? value) {
    final Map<String, int> result = {};
    if (value is! Map) return result;

    for (final uid in value.keys) {
      final userGoals = value[uid];
      result[uid.toString()] = userGoals is Map ? userGoals.length : 0;
    }
    return result;
  }

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
