import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/transaction_record.dart';
import '../utils/constants.dart';

class TransactionService {
  static DatabaseReference _listRef(String uid) => FirebaseDatabase.instance.ref('${DbNodes.transactions}/$uid');

  static String? get _currentUid => FirebaseAuth.instance.currentUser?.uid;

  static List<TransactionRecord> listFromValue(Object? value) {
    if (value is! Map) return [];

    final List<TransactionRecord> transactions = [];
    value.forEach((key, item) {
      if (item is Map) transactions.add(TransactionRecord.fromMap(key.toString(), item));
    });
    transactions.sort((first, second) => second.date.compareTo(first.date));
    return transactions;
  }

  static Stream<List<TransactionRecord>> watch(String uid) {
    return _listRef(uid).onValue.map((event) => listFromValue(event.snapshot.value));
  }

  static Stream<List<TransactionRecord>> watchMonth(String uid, DateTime month) {
    final int startMillis = DateTime(month.year, month.month, 1).millisecondsSinceEpoch;
    final int endMillis = DateTime(month.year, month.month + 1, 0, 23, 59, 59, 999).millisecondsSinceEpoch;
    return _listRef(uid)
        .orderByChild(DbFields.date)
        .startAt(startMillis)
        .endAt(endMillis)
        .onValue
        .map((event) => listFromValue(event.snapshot.value));
  }

  static String newId() {
    try {
      final String? uid = _currentUid;
      if (uid == null) return 'local_${DateTime.now().millisecondsSinceEpoch}';
      return _listRef(uid).push().key!;
    } catch (e) {
      debugPrint('TransactionService.newId failed: $e');
      return 'local_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  static void save(TransactionRecord transaction) {
    try {
      final String? uid = _currentUid;
      if (uid == null) {
        debugPrint('TransactionService.save skipped: no signed-in user');
        return;
      }
      _listRef(uid).child(transaction.id).set(transaction.toMap()).catchError((Object error) {
        debugPrint('TransactionService.save failed: $error');
      });
    } catch (e) {
      debugPrint('TransactionService.save failed: $e');
    }
  }

  static void delete(String transactionId) {
    try {
      final String? uid = _currentUid;
      if (uid == null) {
        debugPrint('TransactionService.delete skipped: no signed-in user');
        return;
      }
      _listRef(uid).child(transactionId).remove().catchError((Object error) {
        debugPrint('TransactionService.delete failed: $error');
      });
    } catch (e) {
      debugPrint('TransactionService.delete failed: $e');
    }
  }
}
