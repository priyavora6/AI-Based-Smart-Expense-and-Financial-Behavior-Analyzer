import 'package:intl/intl.dart';

/// Date formatting and calculation helpers for the app.
class AppDateUtils {
  AppDateUtils._();

  // ── Format Date for Display ───────────────────

  /// "15 Jun 2025"
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// "15 Jun"
  static String formatShortDate(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  /// "Monday, 15 Jun 2025"
  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, dd MMM yyyy').format(date);
  }

  /// "15/06/2025"
  static String formatNumericDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// "2025-06-15" (for API/database)
  static String formatISODate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // ── Format Time ───────────────────────────────

  /// "2:30 PM"
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  /// "15 Jun, 2:30 PM"
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM, h:mm a').format(date);
  }

  // ── Relative Time ─────────────────────────────
  // Shows "Today", "Yesterday", "2 days ago", etc.

  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) return 'Just now';
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      return formatDate(date);
    }
  }

  // ── Month/Year Helpers ────────────────────────

  static String getMonthName(int month) {
    return DateFormat('MMMM').format(DateTime(2025, month));
  }

  static String getShortMonthName(int month) {
    return DateFormat('MMM').format(DateTime(2025, month));
  }

  static String getMonthYear(int month, int year) {
    return DateFormat('MMMM yyyy').format(DateTime(year, month));
  }

  static int getDaysInMonth(int month, int year) {
    return DateTime(year, month + 1, 0).day;
  }

  // ── Date Range Helpers ────────────────────────

  static DateTime getStartOfMonth({DateTime? date}) {
    final d = date ?? DateTime.now();
    return DateTime(d.year, d.month, 1);
  }

  static DateTime getEndOfMonth({DateTime? date}) {
    final d = date ?? DateTime.now();
    return DateTime(d.year, d.month + 1, 0, 23, 59, 59);
  }

  static DateTime getStartOfWeek({DateTime? date}) {
    final d = date ?? DateTime.now();
    return d.subtract(Duration(days: d.weekday - 1));
  }

  static DateTime getStartOfDay({DateTime? date}) {
    final d = date ?? DateTime.now();
    return DateTime(d.year, d.month, d.day);
  }

  static DateTime getEndOfDay({DateTime? date}) {
    final d = date ?? DateTime.now();
    return DateTime(d.year, d.month, d.day, 23, 59, 59);
  }

  // ── Comparison ────────────────────────────────

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }
}