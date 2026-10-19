/// App-wide constants: spacing, sizes, API URLs, and limits.
class AppConstants {
  AppConstants._();

  // ── Spacing & Padding ─────────────────────────

  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;

  // ── Border Radius ─────────────────────────────

  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 999.0;

  // ── Icon Sizes ────────────────────────────────

  static const double iconSM = 18.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;

  // ── Card & Container Heights ──────────────────

  static const double cardHeight = 120.0;
  static const double buttonHeight = 52.0;
  static const double bottomNavHeight = 64.0;
  static const double appBarHeight = 56.0;

  // ── Animation Durations ───────────────────────

  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration splashDelay = Duration(seconds: 2);

  // ── API URLs (Python ML Backend) ──────────────
  // Change this to your actual server IP when running on a real device.
  // For Android emulator use 10.0.2.2, for iOS simulator use localhost.

  static const String apiBaseUrl = String.fromEnvironment(
    'ML_API_BASE_URL',
    defaultValue: 'https://neospend-ai-ml.onrender.com',
  );
  static const String apiCategorize = '$apiBaseUrl/api/categorize';
  static const String apiAnomaly = '$apiBaseUrl/api/anomaly';
  static const String apiForecast = '$apiBaseUrl/api/forecast';
  static const String apiInsights = '$apiBaseUrl/api/insights';
  static const String apiBudgetRecommendations =
      '$apiBaseUrl/api/budget-recommendations';

  // ── Firebase Collections ──────────────────────

  static const String colUsers = 'users';
  static const String colTransactions = 'transactions';
  static const String colCategories = 'categories';
  static const String colBudgets = 'budgets';
  static const String colSavingsGoals = 'savings_goals';
  static const String colRecurring = 'recurring_transactions';
  static const String colNotifications = 'notifications';
  static const String colPredictions = 'predictions';
  static const String colApiLogs = 'apiLogs';
  static const String colAuditLogs = 'auditLogs';

  // ── Limits ────────────────────────────────────

  static const int maxTransactionAmount = 9999999;
  static const int minPasswordLength = 6;
  static const int recentTransactionLimit = 5;
  static const int maxCategories = 20;
  static const int budgetWarningPercent = 80;
  static const int budgetCriticalPercent = 100;

  // ── ML Thresholds ─────────────────────────────

  static const double anomalyZScoreThreshold = 2.0;
  static const double minConfidenceForAutoCategory = 0.70;
  static const int minTransactionsForForecast = 30;
  static const int minMonthsForForecast = 2;

  // ── Currency ──────────────────────────────────

  static const String defaultCurrency = '₹';
  static const String defaultCurrencyCode = 'INR';
  static const String defaultLocale = 'en_IN';
}
