import 'transaction_service.dart';

/// Calculates spending analytics from transaction data.
/// Does NOT use ML — these are pure calculations.
class AnalyticsService {
  final TransactionService _transactionService = TransactionService();

  // ── Monthly Comparison ────────────────────────

  Future<Map<String, dynamic>> getMonthlyComparison({
    required int currentMonth,
    required int currentYear,
  }) async {
    // Current month totals
    final currentTotals = await _transactionService.getMonthlyTotals(
      month: currentMonth,
      year: currentYear,
    );

    // Previous month totals
    int prevMonth = currentMonth - 1;
    int prevYear = currentYear;
    if (prevMonth == 0) {
      prevMonth = 12;
      prevYear -= 1;
    }

    final prevTotals = await _transactionService.getMonthlyTotals(
      month: prevMonth,
      year: prevYear,
    );

    // Calculate percentage changes
    final expenseChange = _calculatePercentageChange(
      prevTotals['expense'] ?? 0,
      currentTotals['expense'] ?? 0,
    );

    final incomeChange = _calculatePercentageChange(
      prevTotals['income'] ?? 0,
      currentTotals['income'] ?? 0,
    );

    return {
      'current': currentTotals,
      'previous': prevTotals,
      'expenseChangePercent': expenseChange,
      'incomeChangePercent': incomeChange,
      'expenseIncreased': expenseChange > 0,
      'incomeIncreased': incomeChange > 0,
    };
  }

  // ── Category Breakdown ────────────────────────

  Future<List<Map<String, dynamic>>> getCategoryBreakdown({
    required int month,
    required int year,
  }) async {
    final categorySpending = await _transactionService.getCategorySpending(
      month: month,
      year: year,
    );

    final totalSpending =
        categorySpending.values.fold(0.0, (sum, val) => sum + val);

    final breakdown = <Map<String, dynamic>>[];

    categorySpending.forEach((category, amount) {
      breakdown.add({
        'category': category,
        'amount': amount,
        'percentage': totalSpending > 0 ? (amount / totalSpending) * 100 : 0.0,
      });
    });

    // Sort by amount descending
    breakdown.sort(
        (a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

    return breakdown;
  }

  // ── Daily Spending Trend ──────────────────────

  Future<List<Map<String, dynamic>>> getDailySpendingTrend({
    required int month,
    required int year,
  }) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59, 999);

    final transactions = await _transactionService.getTransactions(
      startDate: startDate,
      endDate: endDate,
      type: 'expense',
    );

    // Group by day
    final Map<int, double> dailyTotals = {};
    for (final t in transactions) {
      final day = t.date.day;
      dailyTotals[day] = (dailyTotals[day] ?? 0) + t.amount;
    }

    final trend = <Map<String, dynamic>>[];
    for (int day = 1; day <= endDate.day; day++) {
      trend.add({
        'day': day,
        'amount': dailyTotals[day] ?? 0.0,
      });
    }

    return trend;
  }

  // ── Highest Spending Category ─────────────────

  Future<String> getHighestSpendingCategory({
    required int month,
    required int year,
  }) async {
    final breakdown = await getCategoryBreakdown(month: month, year: year);
    if (breakdown.isEmpty) return 'None';
    return breakdown.first['category'] as String;
  }

  // ── Average Daily Spending ────────────────────

  Future<double> getAverageDailySpending({
    required int month,
    required int year,
  }) async {
    final totals = await _transactionService.getMonthlyTotals(
      month: month,
      year: year,
    );
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final expense = totals['expense'] ?? 0;
    return daysInMonth > 0 ? expense / daysInMonth : 0;
  }

  // ── Helper ────────────────────────────────────

  double _calculatePercentageChange(double oldValue, double newValue) {
    if (oldValue == 0) return newValue > 0 ? 100.0 : 0.0;
    return ((newValue - oldValue) / oldValue) * 100;
  }
}
