import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/recurring_item.dart';
import '../models/savings_goal.dart';
import '../models/transaction_record.dart';
import '../utils/constants.dart';
import '../utils/recurring_calculator.dart';
import 'goal_service.dart';

/// Reads and writes fixed monthly items at recurring/{uid}/{itemId}.
/// Writes are not awaited, same as the other services, so they also work offline.
class RecurringService {
  static const Duration readTimeout = Duration(seconds: 10);

  static List<RecurringItem> listFromValue(Object? value) {
    if (value is! Map) return [];

    final List<RecurringItem> items = [];
    value.forEach((key, item) {
      if (item is Map) items.add(RecurringItem.fromMap(key.toString(), item));
    });
    return items;
  }

  // Runs once when the app opens. Offline or any error: nothing is written, the next opening tries again.
  static Future<void> createDue(String uid) async {
    try {
      final DateTime now = DateTime.now();
      final DataSnapshot snapshot = await FirebaseDatabase.instance.ref('${DbNodes.recurring}/$uid').get().timeout(readTimeout);
      final List<RecurringItem> items = listFromValue(snapshot.value);

      final Map<String, Object?> changes = RecurringCalculator.dueChanges(uid, items, now);
      if (changes.isNotEmpty) {
        FirebaseDatabase.instance.ref().update(changes).catchError((Object error) {
          debugPrint('RecurringService.createDue failed: $error');
        });
      }

      final List<RecurringItem> goalItems = items.where((item) => item.isGoalContribution && item.isActive).toList();
      if (goalItems.isEmpty) return;

      // All goals are read once, not once per item.
      final DataSnapshot goalSnapshot = await FirebaseDatabase.instance.ref('${DbNodes.savingsGoals}/$uid').get().timeout(readTimeout);
      final Map<String, SavingsGoal> goalsById = {};
      for (final SavingsGoal goal in GoalService.listFromValue(goalSnapshot.value)) {
        goalsById[goal.id] = goal;
      }
      for (final RecurringItem item in goalItems) {
        await _createGoalContributions(uid, item, goalsById[item.goalId], now);
      }
    } catch (e) {
      debugPrint('RecurringService.createDue failed: $e');
    }
  }

  // The contributions, the goal's saved money and status, and the stop flag are written in one update.
  static Future<void> _createGoalContributions(String uid, RecurringItem item, SavingsGoal? goal, DateTime now) async {
    final GoalAutoContribution result = RecurringCalculator.goalContributions(item, goal, now);
    if (result.lastCreatedMonth == item.lastCreatedMonth) return;

    final bool isClaimed = await _claimMonths(uid, item, result.lastCreatedMonth);
    if (!isClaimed) return;

    final Map<String, Object?> changes = {};
    for (final TransactionRecord contribution in result.contributions) {
      changes['${DbNodes.transactions}/$uid/${contribution.id}'] = contribution.toMap();
    }
    final SavingsGoal? updatedGoal = result.goal;
    if (updatedGoal != null && result.total > 0) GoalService.addGoalAmountChanges(changes, uid, updatedGoal, result.total);
    if (result.stopItem) changes['${DbNodes.recurring}/$uid/${item.id}/${DbFields.isActive}'] = false;
    if (changes.isEmpty) return;

    FirebaseDatabase.instance.ref().update(changes).catchError((Object error) {
      debugPrint('RecurringService goal contributions failed: $error');
    });
  }

  // increment() is not safe to repeat, so only one phone may add these months: lastCreatedMonth is moved
  // forward in a database transaction, and only the phone that moved it writes the contributions.
  static Future<bool> _claimMonths(String uid, RecurringItem item, String newMonth) async {
    final DatabaseReference monthRef = FirebaseDatabase.instance.ref('${DbNodes.recurring}/$uid/${item.id}/${DbFields.lastCreatedMonth}');
    final TransactionResult result = await monthRef.runTransaction((Object? current) {
      // null means the value is not loaded yet; the database calls this again with the real value.
      if (current == null) return Transaction.success(null);
      if (current != item.lastCreatedMonth) return Transaction.abort();
      return Transaction.success(newMonth);
    }).timeout(readTimeout);
    return result.committed && result.snapshot.value == newMonth;
  }

  static Stream<List<RecurringItem>> watch(String uid) {
    final DatabaseReference listRef = FirebaseDatabase.instance.ref('${DbNodes.recurring}/$uid');
    return listRef.onValue.map((event) {
      final List<RecurringItem> items = listFromValue(event.snapshot.value);
      items.sort((first, second) => (second.createdAt ?? 0).compareTo(first.createdAt ?? 0));
      return items;
    });
  }

  // One item read once; null when it does not exist, nobody is signed in or the read fails.
  static Future<RecurringItem?> load(String itemId) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      final DataSnapshot snapshot = await FirebaseDatabase.instance.ref('${DbNodes.recurring}/${user.uid}/$itemId').get().timeout(readTimeout);
      final Object? value = snapshot.value;
      if (value is! Map) return null;
      return RecurringItem.fromMap(itemId, value);
    } catch (e) {
      debugPrint('RecurringService.load failed: $e');
      return null;
    }
  }

  // Writes a whole new item (used when a goal turns on auto contribution for the first time).
  static void save(RecurringItem item) {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('RecurringService.save skipped: no signed-in user');
        return;
      }
      FirebaseDatabase.instance.ref('${DbNodes.recurring}/${user.uid}/${item.id}').set(item.toMap()).catchError((Object error) {
        debugPrint('RecurringService.save failed: $error');
      });
    } catch (e) {
      debugPrint('RecurringService.save failed: $e');
    }
  }

  // Only the given fields change, so the lastCreatedMonth written by the app-open check is never overwritten.
  static void update(String itemId, Map<String, Object?> fields) {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('RecurringService.update skipped: no signed-in user');
        return;
      }
      FirebaseDatabase.instance.ref('${DbNodes.recurring}/${user.uid}/$itemId').update(fields).catchError((Object error) {
        debugPrint('RecurringService.update failed: $error');
      });
    } catch (e) {
      debugPrint('RecurringService.update failed: $e');
    }
  }

  // Transactions already created are kept.
  static void delete(String itemId) {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('RecurringService.delete skipped: no signed-in user');
        return;
      }
      FirebaseDatabase.instance.ref('${DbNodes.recurring}/${user.uid}/$itemId').remove().catchError((Object error) {
        debugPrint('RecurringService.delete failed: $error');
      });
    } catch (e) {
      debugPrint('RecurringService.delete failed: $e');
    }
  }

  static String newId() {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return 'local_${DateTime.now().millisecondsSinceEpoch}';
      return FirebaseDatabase.instance.ref('${DbNodes.recurring}/${user.uid}').push().key!;
    } catch (e) {
      debugPrint('RecurringService.newId failed: $e');
      return 'local_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // The item and its first transaction are saved in one update: both are saved or neither is.
  static void create(RecurringItem item, TransactionRecord firstTransaction) {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('RecurringService.create skipped: no signed-in user');
        return;
      }
      final Map<String, Object?> changes = {
        '${DbNodes.recurring}/${user.uid}/${item.id}': item.toMap(),
        '${DbNodes.transactions}/${user.uid}/${firstTransaction.id}': firstTransaction.toMap(),
      };
      FirebaseDatabase.instance.ref().update(changes).catchError((Object error) {
        debugPrint('RecurringService.create failed: $error');
      });
    } catch (e) {
      debugPrint('RecurringService.create failed: $e');
    }
  }
}
