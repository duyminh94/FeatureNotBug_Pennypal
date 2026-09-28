import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/budget.dart';
import '../utils/constants.dart';

/// Reads and writes the student's budgets at budgets/{uid}/{YYYY-MM}/{categoryId or "total"}.
///
/// Writes are not awaited on purpose: the app works offline, and a Firebase write only
/// finishes when the server answers. Awaiting it would freeze the Save button without internet,
/// while the change is already shown on screen and sent when the connection comes back.
class BudgetService {
  /// Turns the raw value of budgets/{uid} into a list. The first level is the month,
  /// the second level is one budget per category (or the monthly total).
  static List<Budget> listFromValue(Object? value) {
    final List<Budget> budgets = [];
    if (value is! Map) return budgets;

    for (final month in value.keys) {
      final budgetsInMonth = value[month];
      if (budgetsInMonth is! Map) continue;

      for (final budgetKey in budgetsInMonth.keys) {
        final budgetValue = budgetsInMonth[budgetKey];
        if (budgetValue is Map) {
          budgets.add(Budget.fromMap(month.toString(), budgetValue));
        }
      }
    }
    return budgets;
  }

  /// Live list of the student's budgets for every month.
  static Stream<List<Budget>> watch(String uid) {
    final DatabaseReference budgetsRef = FirebaseDatabase.instance.ref('${DbNodes.budgets}/$uid');
    return budgetsRef.onValue.map((event) => listFromValue(event.snapshot.value));
  }

  /// Creates or replaces one budget of the signed-in student.
  static void save(Budget budget) {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('BudgetService.save skipped: no signed-in user');
        return;
      }

      final DatabaseReference budgetRef = FirebaseDatabase.instance.ref('${DbNodes.budgets}/${user.uid}/${budget.month}/${budget.budgetKey}');
      budgetRef.set(budget.toMap()).catchError((Object error) {
        debugPrint('BudgetService.save failed: $error');
      });
    } catch (e) {
      debugPrint('BudgetService.save failed: $e');
    }
  }

  /// Deletes one budget of the signed-in student.
  static void delete(Budget budget) {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('BudgetService.delete skipped: no signed-in user');
        return;
      }

      final DatabaseReference budgetRef = FirebaseDatabase.instance.ref('${DbNodes.budgets}/${user.uid}/${budget.month}/${budget.budgetKey}');
      budgetRef.remove().catchError((Object error) {
        debugPrint('BudgetService.delete failed: $error');
      });
    } catch (e) {
      debugPrint('BudgetService.delete failed: $e');
    }
  }
}
