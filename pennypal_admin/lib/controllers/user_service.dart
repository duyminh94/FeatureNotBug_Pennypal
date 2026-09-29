import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../utils/constants.dart';

class UserService {
  static const String node = 'users';

  static const Duration writeTimeout = Duration(seconds: 15);
  static const Duration readTimeout = Duration(seconds: 10);

  static List<UserProfile> listFromValue(Object? value) {
    final List<UserProfile> users = [];
    if (value is! Map) return users;

    for (final uid in value.keys) {
      final userValue = value[uid];
      if (userValue is! Map) continue;
      try {
        users.add(UserProfile.fromMap(uid.toString(), userValue));
      } catch (e) {
        debugPrint('UserService skipped user $uid: $e');
      }
    }
    return users;
  }

  static Stream<List<UserProfile>> watch() {
    final DatabaseReference usersRef = FirebaseDatabase.instance.ref(node);
    return usersRef.onValue.map((event) => listFromValue(event.snapshot.value));
  }

  static Future<bool> setActive(String uid, bool isActive) async {
    try {
      final DatabaseReference userRef = FirebaseDatabase.instance.ref('$node/$uid');
      await userRef.update({DbFields.isActive: isActive}).timeout(writeTimeout);
      return true;
    } catch (e) {
      debugPrint('UserService.setActive failed: $e');
      return false;
    }
  }

  static Future<int?> _countChildren(String path) async {
    try {
      final DataSnapshot snapshot = await FirebaseDatabase.instance.ref(path).get().timeout(readTimeout);
      final Object? value = snapshot.value;
      if (value is Map) return value.length;
      return 0;
    } catch (e) {
      debugPrint('UserService count of $path failed: $e');
      return null;
    }
  }

  static Future<int?> countTransactions(String uid) {
    return _countChildren('transactions/$uid');
  }

  static Future<int?> countGoals(String uid) {
    return _countChildren('savings_goals/$uid');
  }
}
