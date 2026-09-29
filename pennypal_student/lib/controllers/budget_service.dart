import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/budget.dart';
import '../utils/constants.dart';

class BudgetService {
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

  static Stream<List<Budget>> watch(String uid) {
    final DatabaseReference budgetsRef = FirebaseDatabase.instance.ref('${DbNodes.budgets}/$uid');
    return budgetsRef.onValue.map((event) => listFromValue(event.snapshot.value));
  }

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
