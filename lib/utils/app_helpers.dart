import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_colors.dart';

/// Cybersecurity helpers, OTP management, input sanitization,
/// and other app-wide utility functions.
class AppHelpers {
  AppHelpers._();

  // ═══════════════════════════════════════════════
  // 🔐 CYBERSECURITY FUNCTIONS
  // ═══════════════════════════════════════════════

  // ── 1. OTP Hashing (SHA-256) ──────────────────
  // Used only for short-lived OTP values stored locally. Account passwords
  // are managed and hashed by Firebase Authentication.

  static String hashOtp(String otp) {
    final salt = 'neospend_client_salt_2025';
    final bytes = utf8.encode(otp + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ── 3. Input Sanitization (XSS Prevention) ────
  // Removes potentially dangerous characters from user input
  // to prevent Cross-Site Scripting attacks.

  static String sanitizeInput(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('&', '&amp;')
        .replaceAll(';', '')
        .trim();
  }

  // ── 4. SQL/NoSQL Injection Prevention ─────────
  // Removes characters commonly used in injection attacks.

  static String sanitizeForDatabase(String input) {
    return input
        .replaceAll(RegExp(r"""[;$'"\\]"""), '')
        .replaceAll(RegExp(r'--'), '')
        .replaceAll(RegExp(r'/\*'), '')
        .replaceAll(RegExp(r'\*/'), '')
        .trim();
  }

  // ── 5. Rate Limiting (Client-Side) ────────────
  // Prevents brute-force attacks on login/OTP.

  static const String _loginAttemptsKey = 'login_attempts';
  static const String _loginLockTimeKey = 'login_lock_time';
  static const int maxLoginAttempts = 5;
  static const int lockDurationMinutes = 15;

  static Future<bool> isLoginBlocked() async {
    final prefs = await SharedPreferences.getInstance();
    final lockTime = prefs.getInt(_loginLockTimeKey);

    if (lockTime != null) {
      final lockExpiry = DateTime.fromMillisecondsSinceEpoch(lockTime);
      if (DateTime.now().isBefore(lockExpiry)) {
        return true; // Still locked
      } else {
        // Lock expired, reset
        await resetLoginAttempts();
        return false;
      }
    }
    return false;
  }

  static Future<void> recordFailedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = (prefs.getInt(_loginAttemptsKey) ?? 0) + 1;
    await prefs.setInt(_loginAttemptsKey, attempts);

    if (attempts >= maxLoginAttempts) {
      final lockUntil = DateTime.now()
          .add(Duration(minutes: lockDurationMinutes))
          .millisecondsSinceEpoch;
      await prefs.setInt(_loginLockTimeKey, lockUntil);
    }
  }

  static Future<void> resetLoginAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginAttemptsKey);
    await prefs.remove(_loginLockTimeKey);
  }

  static Future<int> getRemainingAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = prefs.getInt(_loginAttemptsKey) ?? 0;
    return maxLoginAttempts - attempts;
  }

  // ── 6. Session Timeout ────────────────────────
  // Auto-logout after inactivity.

  static const String _lastActivityKey = 'last_activity_time';
  static const int sessionTimeoutMinutes = 30;

  static Future<void> updateLastActivity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _lastActivityKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<bool> isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActivity = prefs.getInt(_lastActivityKey);

    if (lastActivity == null) return true;

    final lastActive = DateTime.fromMillisecondsSinceEpoch(lastActivity);
    final elapsed = DateTime.now().difference(lastActive).inMinutes;

    return elapsed > sessionTimeoutMinutes;
  }

  // ── 7. Secure Token Generation ────────────────
  // Generates a random token for CSRF protection or session ID.

  static String generateSecureToken({int length = 32}) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  // ── 8. Data Integrity Check ───────────────────
  // Creates a checksum to verify data hasn't been tampered with.

  static String generateChecksum(String data) {
    final bytes = utf8.encode(data + 'neospend_integrity_key');
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16); // Short checksum
  }

  static bool verifyChecksum(String data, String checksum) {
    return generateChecksum(data) == checksum;
  }

  // ═══════════════════════════════════════════════
  // 📧 OTP FUNCTIONS
  // ═══════════════════════════════════════════════

  // ── 9. Generate OTP (Client-Side Backup) ──────
  // Primary OTP generation happens on the Python backend.
  // This is a fallback for demo/testing.

  static String generateOTP({int length = 6}) {
    final random = Random.secure();
    return List.generate(length, (index) => random.nextInt(10)).join();
  }

  // ── 10. OTP Expiry Check ──────────────────────

  static const String _otpTimeKey = 'otp_generated_time';
  static const int otpExpiryMinutes = 5;

  static Future<void> saveOTPTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _otpTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<bool> isOTPExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final otpTime = prefs.getInt(_otpTimeKey);

    if (otpTime == null) return true;

    final generatedAt = DateTime.fromMillisecondsSinceEpoch(otpTime);
    final elapsed = DateTime.now().difference(generatedAt).inMinutes;

    return elapsed > otpExpiryMinutes;
  }

  static Future<int> getOTPRemainingSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    final otpTime = prefs.getInt(_otpTimeKey);

    if (otpTime == null) return 0;

    final generatedAt = DateTime.fromMillisecondsSinceEpoch(otpTime);
    final elapsed = DateTime.now().difference(generatedAt).inSeconds;
    final remaining = (otpExpiryMinutes * 60) - elapsed;

    return remaining > 0 ? remaining : 0;
  }

  // ── 11. OTP Resend Cooldown ───────────────────
  // Prevents spamming the OTP endpoint.

  static const String _otpResendTimeKey = 'otp_last_resend_time';
  static const int resendCooldownSeconds = 60;

  static Future<bool> canResendOTP() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResend = prefs.getInt(_otpResendTimeKey);

    if (lastResend == null) return true;

    final lastResendTime = DateTime.fromMillisecondsSinceEpoch(lastResend);
    final elapsed = DateTime.now().difference(lastResendTime).inSeconds;

    return elapsed >= resendCooldownSeconds;
  }

  static Future<void> recordOTPResend() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _otpResendTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<int> getResendCooldownRemaining() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResend = prefs.getInt(_otpResendTimeKey);

    if (lastResend == null) return 0;

    final lastResendTime = DateTime.fromMillisecondsSinceEpoch(lastResend);
    final elapsed = DateTime.now().difference(lastResendTime).inSeconds;
    final remaining = resendCooldownSeconds - elapsed;

    return remaining > 0 ? remaining : 0;
  }

  // ═══════════════════════════════════════════════
  // 🛡️ ADDITIONAL SECURITY HELPERS
  // ═══════════════════════════════════════════════

  // ── 12. Detect Suspicious Input ───────────────

  static bool isSuspiciousInput(String input) {
    final suspiciousPatterns = [
      RegExp(r'<script', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+=', caseSensitive: false),
      RegExp(r'eval\(', caseSensitive: false),
      RegExp(r'union\s+select', caseSensitive: false),
      RegExp(r'drop\s+table', caseSensitive: false),
      RegExp(r'insert\s+into', caseSensitive: false),
      RegExp(r'\.\./\.\.'),
    ];

    for (final pattern in suspiciousPatterns) {
      if (pattern.hasMatch(input)) return true;
    }
    return false;
  }

  // ── 13. Validate File Upload (for receipts) ───

  static bool isValidImageFile(String fileName, int fileSizeBytes) {
    final allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
    final extension = fileName.toLowerCase().substring(
          fileName.lastIndexOf('.'),
        );

    if (!allowedExtensions.contains(extension)) return false;

    // Max 5 MB
    if (fileSizeBytes > 5 * 1024 * 1024) return false;

    return true;
  }

  // ── 14. Encrypt Sensitive Data (Simple XOR) ───
  // For local storage encryption of non-critical data.
  // Use flutter_secure_storage for truly sensitive data.

  static String simpleEncrypt(String data, String key) {
    final dataBytes = utf8.encode(data);
    final keyBytes = utf8.encode(key);
    final encrypted = <int>[];

    for (int i = 0; i < dataBytes.length; i++) {
      encrypted.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return base64.encode(encrypted);
  }

  static String simpleDecrypt(String encryptedData, String key) {
    final dataBytes = base64.decode(encryptedData);
    final keyBytes = utf8.encode(key);
    final decrypted = <int>[];

    for (int i = 0; i < dataBytes.length; i++) {
      decrypted.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return utf8.decode(decrypted);
  }

  // ═══════════════════════════════════════════════
  // 🎨 UI HELPERS
  // ═══════════════════════════════════════════════

  // ── 15. Show Snackbar ─────────────────────────

  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    Color bgColor = AppColors.navyDark;
    if (isError) bgColor = AppColors.expense;
    if (isSuccess) bgColor = AppColors.success;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bgColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // ── 16. Show Confirmation Dialog ──────────────

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Yes',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor:
                  isDestructive ? AppColors.expense : AppColors.teal,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // ── 17. Get Category Icon ─────────────────────

  static IconData getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'movie':
        return Icons.movie;
      case 'payments':
        return Icons.payments;
      default:
        return Icons.category;
    }
  }

  // ── 18. Get Greeting ──────────────────────────

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
