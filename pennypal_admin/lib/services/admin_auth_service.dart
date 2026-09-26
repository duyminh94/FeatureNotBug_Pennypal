import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../utils/constants.dart';

enum AdminLoginProblem { none, wrongCredentials, notAdmin, tooManyRequests, network, unknown }

class AdminLoginResult {
  final AdminLoginProblem problem;
  final UserProfile? admin;

  const AdminLoginResult.success(UserProfile this.admin) : problem = AdminLoginProblem.none;

  const AdminLoginResult.failure(this.problem) : admin = null;

  bool get isSuccess => problem == AdminLoginProblem.none && admin != null;
}

class AdminAuthService {
  static const Duration readTimeout = Duration(seconds: 10);
  static const Duration requestTimeout = Duration(seconds: 15);

  static AdminLoginProblem problemFromCode(String code) {
    return switch (code) {
      'invalid-credential' || 'wrong-password' || 'user-not-found' || 'invalid-email' || 'user-disabled' => AdminLoginProblem.wrongCredentials,
      'too-many-requests' => AdminLoginProblem.tooManyRequests,
      'network-request-failed' || 'unavailable' => AdminLoginProblem.network,
      'permission-denied' => AdminLoginProblem.notAdmin,
      _ => AdminLoginProblem.unknown,
    };
  }

  static bool isAdmin(UserProfile profile) => profile.role == UserRoles.admin && profile.isActive;

  static Future<AdminLoginResult> signIn(String email, String password) async {
    try {
      final UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ).timeout(requestTimeout);
      final String uid = credential.user!.uid;
      final DatabaseEvent event = await FirebaseDatabase.instance.ref('users/$uid').once().timeout(readTimeout);
      final Object? value = event.snapshot.value;
      final UserProfile? profile = value is Map ? UserProfile.fromMap(uid, value) : null;

      if (profile == null || !isAdmin(profile)) {
        await signOut();
        return const AdminLoginResult.failure(AdminLoginProblem.notAdmin);
      }
      return AdminLoginResult.success(profile);
    } on FirebaseAuthException catch (e) {
      debugPrint('AdminAuthService.signIn failed: ${e.code}');
      return AdminLoginResult.failure(problemFromCode(e.code));
    } on FirebaseException catch (e) {
      debugPrint('AdminAuthService.signIn read failed: ${e.code}');
      await signOut();
      return AdminLoginResult.failure(problemFromCode(e.code));
    } on TimeoutException {
      await signOut();
      return const AdminLoginResult.failure(AdminLoginProblem.network);
    } catch (e) {
      debugPrint('AdminAuthService.signIn failed: $e');
      await signOut();
      return const AdminLoginResult.failure(AdminLoginProblem.unknown);
    }
  }

  static Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('AdminAuthService.signOut failed: $e');
    }
  }
}
