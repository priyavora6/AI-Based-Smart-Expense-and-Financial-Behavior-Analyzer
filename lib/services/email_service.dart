import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_helpers.dart';
import '../config/env.dart';

/// Sends OTP emails using EmailJS REST API.
/// No backend server needed — calls EmailJS directly from Flutter.
class EmailService {
  // ── EmailJS REST API URL ───────────────────────
  static const String _apiUrl = 'https://api.emailjs.com/api/v1.0/email/send';

  // ── OTP Storage Keys ──────────────────────────
  static const String _otpHashKey = 'otp_hash';
  static const String _otpEmailKey = 'otp_email';
  static const String _otpTimeKey = 'otp_time';
  static const String _otpAttemptsKey = 'otp_attempts';
  static const int _maxOTPAttempts = 3;
  static const int _otpExpiryMinutes = 5;

  // ═══════════════════════════════════════════════
  // 📧 SEND OTP EMAIL
  // ═══════════════════════════════════════════════

  /// Generates a 6-digit OTP, sends it via EmailJS,
  /// and stores the hashed OTP locally for verification.
  static Future<bool> sendOTP({
    required String toEmail,
    required String userName,
  }) async {
    try {
      final canResend = await AppHelpers.canResendOTP();
      if (!canResend) {
        final remaining = await AppHelpers.getResendCooldownRemaining();
        throw Exception('Please wait $remaining seconds before requesting a new OTP.');
      }

      final otp = _generateOTP();
      final otpHash = AppHelpers.hashOtp(otp);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_otpHashKey, otpHash);
      await prefs.setString(_otpEmailKey, toEmail.toLowerCase().trim());
      await prefs.setInt(_otpTimeKey, DateTime.now().millisecondsSinceEpoch);
      await prefs.setInt(_otpAttemptsKey, 0);

      await AppHelpers.recordOTPResend();

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: jsonEncode({
          'service_id': Env.emailJsServiceId,
          'template_id': Env.emailJsTemplateId,
          'user_id': Env.emailJsPublicKey,
          'template_params': {
            'email': toEmail,
            'passcode': otp,
            'time': _expiryTime(),
          },
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Email sending failed. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  static String _expiryTime() {
    final expiry = DateTime.now().add(const Duration(minutes: _otpExpiryMinutes));
    final hour = expiry.hour % 12 == 0 ? 12 : expiry.hour % 12;
    final minute = expiry.minute.toString().padLeft(2, '0');
    final period = expiry.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // ═══════════════════════════════════════════════
  // ✅ VERIFY OTP
  // ═══════════════════════════════════════════════

  static Future<bool> verifyOTP({
    required String enteredOTP,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString(_otpHashKey);
    final storedEmail = prefs.getString(_otpEmailKey);
    final storedTime = prefs.getInt(_otpTimeKey);

    if (storedHash == null || storedEmail == null || storedTime == null) {
      throw Exception('No OTP found. Please request a new one.');
    }

    if (storedEmail != email.toLowerCase().trim()) {
      throw Exception('Email does not match the OTP request.');
    }

    final generatedAt = DateTime.fromMillisecondsSinceEpoch(storedTime);
    if (DateTime.now().difference(generatedAt).inMinutes > _otpExpiryMinutes) {
      await clearOTP();
      throw Exception('OTP has expired. Please request a new one.');
    }

    final attempts = prefs.getInt(_otpAttemptsKey) ?? 0;
    if (attempts >= _maxOTPAttempts) {
      await clearOTP();
      throw Exception('Too many incorrect attempts. Please request a new OTP.');
    }

    final enteredHash = AppHelpers.hashOtp(enteredOTP.trim());
    if (enteredHash == storedHash) {
      await clearOTP();
      return true;
    } else {
      await prefs.setInt(_otpAttemptsKey, attempts + 1);
      final remaining = _maxOTPAttempts - attempts - 1;
      throw Exception('Incorrect OTP. $remaining attempts remaining.');
    }
  }

  static Future<void> clearOTP() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_otpHashKey);
    await prefs.remove(_otpEmailKey);
    await prefs.remove(_otpTimeKey);
    await prefs.remove(_otpAttemptsKey);
  }

  static String _generateOTP() {
    final random = Random.secure();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }
}
