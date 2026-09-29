import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../utils/constants.dart';

enum AuthProblem { none, invalidLogin, emailInUse, weakPassword, tooManyRequests, network, permission, wrongApp, locked, unknown }

class AuthResult {
  final AuthProblem problem;
  final UserProfile? profile;

  const AuthResult.success(UserProfile this.profile) : problem = AuthProblem.none;

  const AuthResult.failure(this.problem) : profile = null;

  bool get isSuccess => problem == AuthProblem.none && profile != null;
}

class RegisterForm {
  final String fullName;
  final String email;
  final String mobileNumber;
  final String? studentStatus;
  final String password;

  const RegisterForm({
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.studentStatus,
    required this.password,
  });
}

class AuthService {
  static const Duration offlineWait = Duration(seconds: 8);
  static const Duration requestWait = Duration(seconds: 15);

  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static DatabaseReference _userRef(String uid) => FirebaseDatabase.instance.ref('${DbNodes.users}/$uid');

  static AuthProblem problemFromCode(String code) {
    return switch (code) {
      'invalid-credential' || 'wrong-password' || 'user-not-found' || 'invalid-email' || 'user-disabled' => AuthProblem.invalidLogin,
      'email-already-in-use' => AuthProblem.emailInUse,
      'weak-password' => AuthProblem.weakPassword,
      'too-many-requests' => AuthProblem.tooManyRequests,
      'network-request-failed' || 'unavailable' => AuthProblem.network,
      'permission-denied' => AuthProblem.permission,
      _ => AuthProblem.unknown,
    };
  }

  static AuthProblem accessProblem(UserProfile profile) {
    if (profile.role != UserRoles.student) return AuthProblem.wrongApp;
    return profile.isActive ? AuthProblem.none : AuthProblem.locked;
  }

  static Stream<bool> watchIsActive(String uid) {
    return _userRef(uid).child(DbFields.isActive).onValue.map((event) => event.snapshot.value != false);
  }

  static Map<String, Object?> newProfileMap({
    required String fullName,
    required String email,
    required String mobileNumber,
    String? studentStatus,
  }) {
    return {
      DbFields.fullName: fullName.trim(),
      DbFields.email: email.trim(),
      DbFields.mobileNumber: mobileNumber.trim(),
      DbFields.studentStatus: studentStatus,
      DbFields.role: UserRoles.student,
      DbFields.isActive: true,
      DbFields.currency: AppDefaults.currency,
      DbFields.notificationsEnabled: true,
      DbFields.createdAt: ServerValue.timestamp,
      DbFields.lastLogin: ServerValue.timestamp,
    };
  }

  static Future<AuthResult> register(RegisterForm form) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: form.email.trim(),
        password: form.password,
      ).timeout(requestWait);
      final String uid = credential.user!.uid;
      await _userRef(uid).set(newProfileMap(
        fullName: form.fullName,
        email: form.email,
        mobileNumber: form.mobileNumber,
        studentStatus: form.studentStatus,
      )).timeout(requestWait);
      return await _readProfile(uid);
    } on TimeoutException {
      debugPrint('AuthService.register timed out');
      await signOut();
      return const AuthResult.failure(AuthProblem.network);
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService.register failed: ${e.code}');
      return AuthResult.failure(problemFromCode(e.code));
    } on FirebaseException catch (e) {
      debugPrint('AuthService.register profile write failed: ${e.code}');
      return AuthResult.failure(problemFromCode(e.code));
    } catch (e) {
      debugPrint('AuthService.register failed: $e');
      return const AuthResult.failure(AuthProblem.unknown);
    }
  }

  static Future<AuthResult> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password).timeout(requestWait);
      return await checkAccess(allowOffline: false);
    } on TimeoutException {
      debugPrint('AuthService.signIn timed out');
      await signOut();
      return const AuthResult.failure(AuthProblem.network);
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService.signIn failed: ${e.code}');
      return AuthResult.failure(problemFromCode(e.code));
    } catch (e) {
      debugPrint('AuthService.signIn failed: $e');
      return const AuthResult.failure(AuthProblem.unknown);
    }
  }

  static Future<AuthResult?> checkSession() async {
    if (_auth.currentUser == null) return null;
    return checkAccess(allowOffline: true);
  }

  static Future<AuthResult> checkAccess({required bool allowOffline}) async {
    final User? user = _auth.currentUser;
    if (user == null) return const AuthResult.failure(AuthProblem.invalidLogin);

    try {
      final DatabaseEvent event = await _userRef(user.uid).once().timeout(offlineWait);
      if (!event.snapshot.exists) {
        await _userRef(user.uid).set(newProfileMap(
          fullName: user.displayName ?? user.email?.split('@').first ?? '',
          email: user.email ?? '',
          mobileNumber: '',
        ));
      }
      return await _readProfile(user.uid);
    } on TimeoutException {
      return _offlineResult(user, allowOffline);
    } on FirebaseException catch (e) {
      debugPrint('AuthService.checkAccess failed: ${e.code}');
      await signOut();
      return AuthResult.failure(problemFromCode(e.code));
    } catch (e) {
      debugPrint('AuthService.checkAccess failed: $e');
      await signOut();
      return const AuthResult.failure(AuthProblem.unknown);
    }
  }

  static Future<AuthResult> _readProfile(String uid) async {
    final DatabaseEvent event = await _userRef(uid).once().timeout(offlineWait);
    final Object? value = event.snapshot.value;
    if (value is! Map) return const AuthResult.failure(AuthProblem.unknown);

    final UserProfile profile = UserProfile.fromMap(uid, value);
    final AuthProblem problem = accessProblem(profile);
    if (problem != AuthProblem.none) {
      await signOut();
      return AuthResult.failure(problem);
    }

    unawaited(_userRef(uid).update({DbFields.lastLogin: ServerValue.timestamp}).catchError((Object e) {
      debugPrint('AuthService lastLogin update failed: $e');
    }));
    return AuthResult.success(profile);
  }

  static Future<AuthResult> _offlineResult(User user, bool allowOffline) async {
    if (!allowOffline) {
      await signOut();
      return const AuthResult.failure(AuthProblem.network);
    }
    return AuthResult.success(UserProfile(
      uid: user.uid,
      fullName: user.displayName ?? user.email?.split('@').first ?? '',
      email: user.email ?? '',
      mobileNumber: '',
    ));
  }

  static Future<AuthProblem> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthProblem.none;
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService.sendPasswordReset failed: ${e.code}');
      final AuthProblem problem = problemFromCode(e.code);
      return problem == AuthProblem.invalidLogin ? AuthProblem.none : problem;
    } catch (e) {
      debugPrint('AuthService.sendPasswordReset failed: $e');
      return AuthProblem.unknown;
    }
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('AuthService.signOut failed: $e');
    }
  }
}
