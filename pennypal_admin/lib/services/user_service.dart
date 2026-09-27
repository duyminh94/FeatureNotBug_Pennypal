import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../utils/constants.dart';

/// Reads student accounts at users/{uid} and locks or unlocks them.
/// A locked student (isActive = false) is signed out by the student app and cannot log in.
class UserService {
  static const String node = 'users';

  // Without a time limit a write would wait forever when there is no internet.
  static const Duration writeTimeout = Duration(seconds: 15);
  static const Duration readTimeout = Duration(seconds: 10);

  /// Turns the raw value of users into a list of profiles (admins included,
  /// the screen keeps only students). Broken entries are skipped.
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

  /// Live list of all accounts; a new student appears as soon as they register.
  static Stream<List<UserProfile>> watch() {
    final DatabaseReference usersRef = FirebaseDatabase.instance.ref(node);
    return usersRef.onValue.map((event) => listFromValue(event.snapshot.value));
  }

  /// Locks (false) or unlocks (true) an account. Only isActive is written,
  /// the rest of the student's profile stays as the student saved it.
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

  /// Number of child entries under [path], read once. Returns null when it cannot be read.
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

  /// How many transactions one student has. Only this student's node is read,
  /// not the whole transactions tree.
  static Future<int?> countTransactions(String uid) {
    return _countChildren('transactions/$uid');
  }

  /// How many savings goals one student has.
  static Future<int?> countGoals(String uid) {
    return _countChildren('savings_goals/$uid');
  }
}
