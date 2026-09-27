import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import '../models/category.dart';
import '../utils/constants.dart';

/// Custom categories of the student at user_categories/{uid}/{catId} (SRS Categories: IsDefault = false, CreatedBy = uid).
/// Writes are not awaited, same as the other services, so the app keeps working offline.
class CategoryService {
  static List<Category> listFromValue(Object? value) {
    final List<Category> categories = [];
    if (value is! Map) return categories;

    value.forEach((key, item) {
      if (item is Map) categories.add(Category.fromCustomMap(key.toString(), item));
    });
    categories.sort((first, second) => (first.createdAt ?? 0).compareTo(second.createdAt ?? 0));
    return categories;
  }

  static Stream<List<Category>> watch(String uid) {
    final DatabaseReference listRef = FirebaseDatabase.instance.ref('${DbNodes.userCategories}/$uid');
    return listRef.onValue.map((event) => listFromValue(event.snapshot.value));
  }

  static String? currentUid() {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (e) {
      debugPrint('CategoryService.currentUid failed: $e');
      return null;
    }
  }

  static String newId() {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return 'cat_${DateTime.now().millisecondsSinceEpoch}';
      return FirebaseDatabase.instance.ref('${DbNodes.userCategories}/${user.uid}').push().key!;
    } catch (e) {
      debugPrint('CategoryService.newId failed: $e');
      return 'cat_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  static void save(Category category) {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('CategoryService.save skipped: no signed-in user');
        return;
      }

      final DatabaseReference categoryRef = FirebaseDatabase.instance.ref('${DbNodes.userCategories}/${user.uid}/${category.id}');
      categoryRef.set(category.toMap()).catchError((Object error) {
        debugPrint('CategoryService.save failed: $error');
      });
    } catch (e) {
      debugPrint('CategoryService.save failed: $e');
    }
  }

  static void delete(Category category) {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('CategoryService.delete skipped: no signed-in user');
        return;
      }

      final DatabaseReference categoryRef = FirebaseDatabase.instance.ref('${DbNodes.userCategories}/${user.uid}/${category.id}');
      categoryRef.remove().catchError((Object error) {
        debugPrint('CategoryService.delete failed: $error');
      });
    } catch (e) {
      debugPrint('CategoryService.delete failed: $e');
    }
  }
}
