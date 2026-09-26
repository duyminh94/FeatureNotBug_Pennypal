import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../utils/constants.dart';

/// Reasons an admin login can fail, each one has its own message on the login screen.
enum AdminLoginProblem { none, wrongCredentials, notAdmin, tooManyRequests, network, unknown }

/// Result of an admin login: the admin profile when it works, or the reason it failed.
class AdminLoginResult {
  final AdminLoginProblem problem;
  final UserProfile? admin;

  const AdminLoginResult.success(UserProfile this.admin) : problem = AdminLoginProblem.none;

  const AdminLoginResult.failure(this.problem) : admin = null;

  bool get isSuccess => problem == AdminLoginProblem.none && admin != null;
}

/// Signs the admin in with Firebase Auth and checks the role saved at users/{uid}.
class AdminAuthService {
  static const Duration readTimeout = Duration(seconds: 10);
  static const Duration requestTimeout = Duration(seconds: 15);

  /// Turns a Firebase error code into a login problem.
  /// Wrong email and wrong password share one message so nobody can guess which emails exist.
  static AdminLoginProblem problemFromCode(String code) {
    return switch (code) {
      'invalid-credential' => AdminLoginProblem.wrongCredentials,
      'wrong-password' => AdminLoginProblem.wrongCredentials,
      'user-not-found' => AdminLoginProblem.wrongCredentials,
      'invalid-email' => AdminLoginProblem.wrongCredentials,
      'user-disabled' => AdminLoginProblem.wrongCredentials,
      'too-many-requests' => AdminLoginProblem.tooManyRequests,
      'network-request-failed' => AdminLoginProblem.network,
      'unavailable' => AdminLoginProblem.network,
      'permission-denied' => AdminLoginProblem.notAdmin,
      _ => AdminLoginProblem.unknown,
    };
  }

  /// Only an active account with the admin role may open the admin app.
  static bool isAdmin(UserProfile profile) {
    return profile.role == UserRoles.admin && profile.isActive;
  }

  /// Logs in, then reads the profile to make sure the account is an admin.
  /// A student account or a locked account is signed out again right away.
  static Future<AdminLoginResult> signIn(String email, String password) async {
    try {
      final UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.trim(), password: password)
          .timeout(requestTimeout);
      final String uid = credential.user!.uid;

      final DatabaseEvent event = await FirebaseDatabase.instance.ref('users/$uid').once().timeout(readTimeout);
      final Object? value = event.snapshot.value;
      if (value is! Map) {
        await signOut();
        return const AdminLoginResult.failure(AdminLoginProblem.notAdmin);
      }

      final UserProfile profile = UserProfile.fromMap(uid, value);
      if (!isAdmin(profile)) {
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

  /// Signs out; an error here is only logged because the user is leaving anyway.
  static Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('AdminAuthService.signOut failed: $e');
    }
  }
}
