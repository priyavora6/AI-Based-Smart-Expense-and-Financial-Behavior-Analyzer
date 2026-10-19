import 'package:flutter/foundation.dart';
import '../services/analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();

  Map<String, dynamic> _monthlyComparison = {};
  List<Map<String, dynamic>> _categoryBreakdown = [];
  List<Map<String, dynamic>> _dailyTrend = [];
  double _avgDailySpending = 0;
  String _highestCategory = 'None';
  bool _isLoading = false;

  // ── Getters ───────────────────────────────────

  Map<String, dynamic> get monthlyComparison => _monthlyComparison;
  List<Map<String, dynamic>> get categoryBreakdown => _categoryBreakdown;
  List<Map<String, dynamic>> get dailyTrend => _dailyTrend;
  double get avgDailySpending => _avgDailySpending;
  String get highestCategory => _highestCategory;
  bool get isLoading => _isLoading;

  // ── Load All Analytics ────────────────────────

  Future<void> loadAnalytics() async {
    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();

    try {
      // Load all analytics in parallel
      final results = await Future.wait([
        _analyticsService.getMonthlyComparison(
          currentMonth: now.month,
          currentYear: now.year,
        ),
        _analyticsService.getCategoryBreakdown(
          month: now.month,
          year: now.year,
        ),
        _analyticsService.getDailySpendingTrend(
          month: now.month,
          year: now.year,
        ),
        _analyticsService.getAverageDailySpending(
          month: now.month,
          year: now.year,
        ),
        _analyticsService.getHighestSpendingCategory(
          month: now.month,
          year: now.year,
        ),
      ]);

      _monthlyComparison = results[0] as Map<String, dynamic>;
      _categoryBreakdown = results[1] as List<Map<String, dynamic>>;
      _dailyTrend = results[2] as List<Map<String, dynamic>>;
      _avgDailySpending = results[3] as double;
      _highestCategory = results[4] as String;
    } catch (e) {
      debugPrint('Analytics error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Load for Specific Month ───────────────────

  Future<void> loadForMonth(int month, int year) async {
    _isLoading = true;
    notifyListeners();

    try {
      _categoryBreakdown = await _analyticsService.getCategoryBreakdown(
        month: month,
        year: year,
      );
      _dailyTrend = await _analyticsService.getDailySpendingTrend(
        month: month,
        year: year,
      );
      _avgDailySpending = await _analyticsService.getAverageDailySpending(
        month: month,
        year: year,
      );
    } catch (e) {
      debugPrint('Analytics month error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}