import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/savings_goal.dart';
import '../models/transaction_record.dart';
import '../utils/constants.dart';

/// Reads and writes savings goals at savings_goals/{uid}/{goalId}.
///
/// A contribution is also a "savings" expense at transactions/{uid}/{txId}, so the balance goes down.
/// The goal and its transactions are always written in ONE update from the database root:
/// either both change or neither does, and currentAmount never disagrees with the contributions.
///
/// Writes are not awaited on purpose (offline support, see BudgetService).
class GoalService {
  /// Turns the raw value of savings_goals/{uid} into a list, newest goal first.
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

  /// Live list of the student's goals.
  static Stream<List<SavingsGoal>> watch(String uid) {
    final DatabaseReference goalsRef = FirebaseDatabase.instance.ref('${DbNodes.savingsGoals}/$uid');
    return goalsRef.onValue.map((event) => listFromValue(event.snapshot.value));
  }

  /// New unique goal id made on the phone, so a goal can be created offline.
  /// Without a signed-in user a local id based on the time is used instead.
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

  /// Creates or updates a goal (name, target, date, milestones, status…).
  static void saveGoal(SavingsGoal goal) {
    final String? uid = _signedInUid('saveGoal');
    if (uid == null) return;

    final Map<String, Object?> changes = {};
    changes[_goalPath(uid, goal.id)] = goal.toMap();
    _update('saveGoal', changes);
  }

  /// Adds or edits a contribution: saves the savings transaction and adds [change] to currentAmount together (BR-30).
  static void saveContribution(TransactionRecord contribution, SavingsGoal goal, double change) {
    final String? uid = _signedInUid('saveContribution');
    if (uid == null) return;

    final Map<String, Object?> changes = {};
    changes[_transactionPath(uid, contribution.id)] = contribution.toMap();
    _addGoalAmountChanges(changes, uid, goal, change);
    _update('saveContribution', changes);
  }

  /// Removes a contribution: deletes its transaction and adds [change] (negative) to currentAmount together.
  static void deleteContribution(String contributionId, SavingsGoal goal, double change) {
    final String? uid = _signedInUid('deleteContribution');
    if (uid == null) return;

    final Map<String, Object?> changes = {};
    changes[_transactionPath(uid, contributionId)] = null;
    _addGoalAmountChanges(changes, uid, goal, change);
    _update('deleteContribution', changes);
  }

  /// currentAmount is changed with ServerValue.increment, not overwritten, so two contributions
  /// made at the same time (two phones, or offline then sync) are both counted (BR-31).
  /// Status and completedAt come from [goal], already updated by GoalCalculator.changeCurrentAmount.
  static void _addGoalAmountChanges(Map<String, Object?> changes, String uid, SavingsGoal goal, double change) {
    final String goalPath = _goalPath(uid, goal.id);
    changes['$goalPath/${DbFields.currentAmount}'] = ServerValue.increment(change);
    changes['$goalPath/${DbFields.status}'] = goal.status;
    changes['$goalPath/${DbFields.completedAt}'] = goal.completedAt;
  }

  /// Deletes a goal. With the "refund" choice [contributionIds] holds its contributions,
  /// which are deleted too so the money goes back to the balance.
  /// With "keep history" the list is empty and the transactions stay.
  static void deleteGoal(String goalId, List<String> contributionIds) {
    final String? uid = _signedInUid('deleteGoal');
    if (uid == null) return;

    final Map<String, Object?> changes = {};
    changes[_goalPath(uid, goalId)] = null;
    for (final String contributionId in contributionIds) {
      changes[_transactionPath(uid, contributionId)] = null;
    }
    _update('deleteGoal', changes);
  }

  /// Uid of the signed-in student, or null (and a log line) when nobody is signed in
  /// or Firebase is not ready; the write is then skipped instead of crashing the screen.
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

  /// Writes all [changes] in one multi-path update from the database root (a null value deletes).
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
