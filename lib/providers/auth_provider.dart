import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/category_service.dart';
import '../services/email_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final CategoryService _categoryService = CategoryService();

  UserModel? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String _errorMessage = '';
  bool _isAuthenticated = false;
  bool _isAdmin = false;

  AuthProvider() {
    _restoreSession();
  }

  // ── Getters ───────────────────────────────────

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  bool get isAdmin => _isAdmin;
  AuthStatus get status {
    if (_isLoading) return AuthStatus.loading;
    if (!_isInitialized) return AuthStatus.initial;
    if (_isAuthenticated) return AuthStatus.authenticated;
    return AuthStatus.unauthenticated;
  }

  String get userName => _user?.name ?? 'User';
  String get userEmail => _user?.email ?? '';

  Future<void> _restoreSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final restoredUser = await _authService.getCurrentUser();
      if (restoredUser != null) {
        _user = restoredUser;
        _isAuthenticated = true;
        _isAdmin = await _authService.isCurrentUserAdmin();
        await _categoryService.ensureDefaultCategories(restoredUser.uid);
      }
    } catch (e) {
      debugPrint('Session restore failed: $e');
      _user = null;
      _isAuthenticated = false;
      _isAdmin = false;
    } finally {
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Register ──────────────────────────────────

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      _user = await _authService.signUp(
        name: name,
        email: email,
        password: password,
      );

      // Send OTP after successful sign up
      await EmailService.sendOTP(toEmail: email, userName: name);

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // ── Login ─────────────────────────────────────

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      _user = await _authService.login(
        email: email,
        password: password,
      );
      _isAuthenticated = true;
      _isAdmin = await _authService.isCurrentUserAdmin();
      await _categoryService.ensureDefaultCategories(_user!.uid);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // ── OTP Verification ──────────────────────────

  Future<bool> verifyOTP(String otp) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      final success = await EmailService.verifyOTP(
        enteredOTP: otp,
        email: _user?.email ?? '',
      );

      if (success) {
        _isAuthenticated = true;
        // Setup default categories for new user upon verification
        if (_user != null) {
          await _categoryService.setupDefaultCategories(_user!.uid);
        }
      }

      _setLoading(false);
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // ── Resend OTP ────────────────────────────────

  Future<void> resendOTP(String email) async {
    _errorMessage = '';
    try {
      await EmailService.sendOTP(
        toEmail: email,
        userName: _user?.name ?? 'User',
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    }
  }

  // ── Forgot Password ───────────────────────────

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // ── Logout ────────────────────────────────────

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isAuthenticated = false;
    _isAdmin = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    required double monthlyIncome,
  }) async {
    _setLoading(true);
    _errorMessage = '';
    try {
      _user = await _authService.updateProfile(
        name: name,
        monthlyIncome: monthlyIncome,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // ── Set User (from splash check) ──────────────

  void setUser(UserModel user) {
    _user = user;
    _isAuthenticated = true;
    notifyListeners();
  }

  // ── Helper ────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
