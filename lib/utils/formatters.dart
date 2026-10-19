/// General-purpose text and data formatters.
class Formatters {
  Formatters._();

  // ── Name Formatting ───────────────────────────

  /// "priya vora" → "Priya Vora"
  static String capitalizeName(String name) {
    return name
        .trim()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) =>
    '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// "Priya Vora" → "PV"
  static String getInitials(String name) {
    final parts = name.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // ── Email Masking (for security display) ──────

  /// "priya@gmail.com" → "p***a@gmail.com"
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) return '${name[0]}***@$domain';

    return '${name[0]}***${name[name.length - 1]}@$domain';
  }

  // ── Phone Masking ─────────────────────────────

  /// "9876543210" → "98****3210"
  static String maskPhone(String phone) {
    if (phone.length < 6) return phone;
    final start = phone.substring(0, 2);
    final end = phone.substring(phone.length - 4);
    final middle = '*' * (phone.length - 6);
    return '$start$middle$end';
  }

  // ── Card Number Masking ───────────────────────

  /// "1234567890123456" → "**** **** **** 3456"
  static String maskCardNumber(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 4) return cleaned;
    final last4 = cleaned.substring(cleaned.length - 4);
    return '**** **** **** $last4';
  }

  // ── Number Formatting ─────────────────────────

  /// 1500 → "1,500"
  static String formatNumber(num number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  /// 1500 → "1.5K"
  static String formatNumberShort(num number) {
    if (number >= 10000000) return '${(number / 10000000).toStringAsFixed(1)}Cr';
    if (number >= 100000) return '${(number / 100000).toStringAsFixed(1)}L';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  // ── Transaction Description Cleaning ──────────

  /// Removes extra spaces, special chars for ML processing
  static String cleanDescription(String description) {
    return description
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .toLowerCase();
  }

  // ── Truncate Text ─────────────────────────────

  /// "This is a very long text" → "This is a..."
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}