import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_constants.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

/// Handles all authentication: sign up, login, logout, password reset.
class AuthService {
  final FirebaseAuth _auth = FirebaseService.auth;
  final FirebaseFirestore _db = FirebaseService.firestore;

  // ── Sign Up ───────────────────────────────────

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Create Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('Sign up failed');

      // 2. Update display name
      await user.updateDisplayName(name.trim());

      // Note: We are using EmailJS for OTP verification instead of
      // Firebase's built-in email verification link.

      // 3. Create user document in Firestore
      final userModel = UserModel(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _db
          .collection(AppConstants.colUsers)
          .doc(user.uid)
          .set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ── Login ─────────────────────────────────────

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    await user.reload();
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    final doc =
        await _db.collection(AppConstants.colUsers).doc(currentUser.uid).get();

    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }

    return UserModel(
      uid: currentUser.uid,
      name: currentUser.displayName ?? 'User',
      email: currentUser.email ?? '',
      createdAt: DateTime.now(),
    );
  }

  Future<bool> isCurrentUserAdmin({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final token = await user.getIdTokenResult(forceRefresh);
    final hasAdminClaim = token.claims?['admin'] == true;
    final isFixedAdmin = user.email == 'neospend@dmin.com' &&
        token.claims?['email_verified'] == true;
    return hasAdminClaim || isFixedAdmin;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('Login failed');

      // Fetch user data from Firestore
      final doc =
          await _db.collection(AppConstants.colUsers).doc(user.uid).get();

      if (doc.exists) {
        await _db.collection(AppConstants.colUsers).doc(user.uid).update({
          'lastLoginAt': Timestamp.fromDate(DateTime.now()),
        });
        return UserModel.fromFirestore(doc);
      }

      // Create a profile when the Firebase Auth account predates the profile.
      final fallback = UserModel(
        uid: user.uid,
        name: user.displayName ?? 'User',
        email: user.email ?? email,
        createdAt: DateTime.now(),
      );
      await _db
          .collection(AppConstants.colUsers)
          .doc(user.uid)
          .set(fallback.toFirestore());
      return fallback;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ── Logout ────────────────────────────────────

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<UserModel> updateProfile({
    required String name,
    required double monthlyIncome,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('You must be signed in.');

    await user.updateDisplayName(name.trim());
    await _db.collection(AppConstants.colUsers).doc(user.uid).update({
      'name': name.trim(),
      'monthlyIncome': monthlyIncome,
    });
    final updated =
        await _db.collection(AppConstants.colUsers).doc(user.uid).get();
    return UserModel.fromFirestore(updated);
  }

  // ── Forgot Password ───────────────────────────

  /// Sends a password reset link using Firebase Auth.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ── Check Email Verified ──────────────────────

  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // ── Resend Verification (Firebase) ────────────

  Future<void> resendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // ── Delete Account ────────────────────────────

  Future<void> deleteAccount() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // Delete user data from Firestore
    await _db.collection(AppConstants.colUsers).doc(uid).delete();

    // Delete auth account
    await _auth.currentUser?.delete();
  }

  // ── Error Handler ─────────────────────────────

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
