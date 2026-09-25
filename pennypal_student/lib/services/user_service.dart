import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../utils/constants.dart';

class UserService {
  static Map<String, Object?> editableFields(UserProfile profile) {
    return {
      DbFields.fullName: profile.fullName.trim(),
      DbFields.mobileNumber: profile.mobileNumber.trim(),
      DbFields.studentStatus: profile.studentStatus,
      DbFields.currency: profile.currency,
      DbFields.notificationsEnabled: profile.notificationsEnabled,
    };
  }

  static Future<bool> saveProfile(UserProfile profile) async {
    try {
      await FirebaseDatabase.instance.ref('${DbNodes.users}/${profile.uid}').update(editableFields(profile));
      return true;
    } catch (e) {
      debugPrint('UserService.saveProfile failed: $e');
      return false;
    }
  }
}
