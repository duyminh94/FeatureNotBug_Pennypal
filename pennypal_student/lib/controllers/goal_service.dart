import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/savings_goal.dart';
import '../models/transaction_record.dart';
import '../utils/constants.dart';
import '../utils/recurring_calculator.dart';

class GoalService {
  static List<SavingsGoal> listFromValue(Object? value) {
    final List<SavingsGoal> goals = [];
    if (value is! Map) return goals;

    for (final goalId in value.keys) {
      final goalValue = value[goalId];
      if (goalValue is Map) {
        goals.add(SavingsGoal.fromMap(goalId.toString(), goalValue));
      }
    }
    goals.sort((first, second) => (second.createdAt ?? 0).compareTo(first.createdAt ?? 0));
    return goals;
  }

  static Stream<List<SavingsGoal>> watch(String uid) {
    final DatabaseReference goalsRef = FirebaseDatabase.instance.ref('${DbNodes.savingsGoals}/$uid');
    return goalsRef.onValue.map((event) => listFromValue(event.snapshot.value));
  }

  static String newId() {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return 'local_${DateTime.now().millisecondsSinceEpoch}';
      return FirebaseDatabase.instance.ref('${DbNodes.savingsGoals}/${user.uid}').push().key!;
    } catch (e) {
      debugPrint('GoalService.newId failed: $e');
      return 'local_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  static void saveGoal(SavingsGoal goal) {
    final String? uid = _signedInUid('saveGoal');
    if (uid == null) return;

    final Map<String, Object?> changes = {};
    changes[_goalPath(uid, goal.id)] = goal.toMap();
    _update('saveGoal', changes);
  }

  static void saveContribution(TransactionRecord contribution, SavingsGoal goal, double change) {
    final String? uid = _signedInUid('saveContribution');
    if (uid == null) return;

    final Map<String, Object?> changes = {};
    changes[_transactionPath(uid, contribution.id)] = contribution.toMap();
    addGoalAmountChanges(changes, uid, goal, change);
    _update('saveContribution', changes);
  }

  static void deleteContribution(String contributionId, SavingsGoal goal, double change) {
    final String? uid = _signedInUid('deleteContribution');
    if (uid == null) return;

    final Map<String, Object?> changes = {};
    changes[_transactionPath(uid, contributionId)] = null;
    addGoalAmountChanges(changes, uid, goal, change);
    _update('deleteContribution', changes);
  }

  static void addGoalAmountChanges(Map<String, Object?> changes, String uid, SavingsGoal goal, double change) {
    final String goalPath = _goalPath(uid, goal.id);
    changes['$goalPath/${DbFields.currentAmount}'] = ServerValue.increment(change);
    changes['$goalPath/${DbFields.status}'] = goal.status;
    changes['$goalPath/${DbFields.completedAt}'] = goal.completedAt;
  }

  static void deleteGoal(String goalId, List<String> contributionIds) {
    final String? uid = _signedInUid('deleteGoal');
    if (uid == null) return;

    final Map<String, Object?> changes = {};
    changes[_goalPath(uid, goalId)] = null;
    changes['${DbNodes.recurring}/$uid/${RecurringCalculator.goalItemId(goalId)}'] = null;
    for (final String contributionId in contributionIds) {
      changes[_transactionPath(uid, contributionId)] = null;
    }
    _update('deleteGoal', changes);
  }

  static String? _signedInUid(String action) {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('GoalService.$action skipped: no signed-in user');
        return null;
      }
      return user.uid;
    } catch (e) {
      debugPrint('GoalService.$action failed: $e');
      return null;
    }
  }

  static String _goalPath(String uid, String goalId) {
    return '${DbNodes.savingsGoals}/$uid/$goalId';
  }

  static String _transactionPath(String uid, String transactionId) {
    return '${DbNodes.transactions}/$uid/$transactionId';
  }

  static void _update(String action, Map<String, Object?> changes) {
    try {
      FirebaseDatabase.instance.ref().update(changes).catchError((Object error) {
        debugPrint('GoalService.$action failed: $error');
      });
    } catch (e) {
      debugPrint('GoalService.$action failed: $e');
    }
  }
}
