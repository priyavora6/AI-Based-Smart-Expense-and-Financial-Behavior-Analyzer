/// Input validation for all forms in the app.
/// Includes email, password strength, OTP, and amount validation.
class Validators {
  Validators._();

  // ── Email ─────────────────────────────────────

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }

    // Block disposable email domains (basic check)
    final disposableDomains = [
      'tempmail.com',
      'throwaway.email',
      'guerrillamail.com',
      'mailinator.com',
      'yopmail.com',
    ];

    final domain = value.trim().split('@').last.toLowerCase();
    if (disposableDomains.contains(domain)) {
      return 'Disposable email addresses are not allowed.';
    }

    return null; // Valid
  }

  // ── Password Strength ─────────────────────────
  // Checks multiple security rules.

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }

    if (value.length > 128) {
      return 'Password is too long.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter.';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter.';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number.';
    }

    // Use a character class that includes all common special characters.
    final specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=/`~]');
    if (!specialCharRegex.hasMatch(value)) {
      return 'Password must contain at least one special character.';
    }

    // Block common passwords
    final commonPasswords = [
      'password',
      '12345678',
      'qwerty12',
      'abc12345',
      'password1',
      'iloveyou',
      'admin123',
    ];

    if (commonPasswords.contains(value.toLowerCase())) {
      return 'This password is too common. Choose a stronger one.';
    }

    return null; // Valid
  }

  // ── Password Strength Score (0–4) ─────────────
  // Used to show a strength indicator bar on the signup screen.

  static int getPasswordStrength(String password) {
    int score = 0;

    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      score++;
    }

    return score; // 0 = weak, 1 = fair, 2 = good, 3 = strong, 4 = very strong
  }

  static String getStrengthLabel(int score) {
    switch (score) {
      case 0:
        return 'Very Weak';
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Strong';
      case 4:
        return 'Very Strong';
      default:
        return '';
    }
  }

  // ── Confirm Password ──────────────────────────

  static String? validateConfirmPassword(
    String? value,
    String originalPassword,
  ) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }

    if (value != originalPassword) {
      return 'Passwords do not match.';
    }

    return null;
  }

  // ── OTP Validation ────────────────────────────

  static String? validateOTP(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP is required.';
    }

    final trimmed = value.trim();

    if (trimmed.length != 6) {
      return 'OTP must be exactly 6 digits.';
    }

    if (!RegExp(r'^[0-9]{6}$').hasMatch(trimmed)) {
      return 'OTP must contain only numbers.';
    }

    return null; // Valid
  }

  // ── Name ──────────────────────────────────────

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required.';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters.';
    }

    if (value.trim().length > 50) {
      return 'Name is too long.';
    }

    // Block special characters in name
    if (!RegExp(r"^[a-zA-Z\s.'-]+$").hasMatch(value.trim())) {
      return 'Name contains invalid characters.';
    }

    return null;
  }

  // ── Amount ────────────────────────────────────

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required.';
    }

    final cleaned = value.trim().replaceAll(',', '');

    final amount = double.tryParse(cleaned);
    if (amount == null) {
      return 'Please enter a valid number.';
    }

    if (amount <= 0) {
      return 'Amount must be greater than zero.';
    }

    if (amount > 9999999) {
      return 'Amount is too large.';
    }

    return null;
  }

  // ── Description ───────────────────────────────

  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required.';
    }

    if (value.trim().length > 200) {
      return 'Description is too long (max 200 characters).';
    }

    return null;
  }

  // ── Required Field (Generic) ──────────────────

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }
}
