import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/app_constants.dart';
import 'admin_data_service.dart';

/// Connects to the Python Flask/FastAPI backend for all ML operations:
/// 1. Expense categorization
/// 2. Unusual spending detection
/// 3. Future expense prediction
/// 4. AI-generated insights (via Gemini)
class MLApiService {
  final AdminDataService _adminDataService = AdminDataService();

  void _recordApiCall({
    required String endpoint,
    required int statusCode,
    required DateTime startedAt,
    String? error,
  }) {
    unawaited(_adminDataService.saveApiLog(
      endpoint: endpoint,
      method: 'POST',
      statusCode: statusCode,
      durationMs: DateTime.now().difference(startedAt).inMilliseconds,
      error: error,
    ));
  }

  // ── 1. Auto Categorize Transaction ────────────
  // Sends description to Python API, gets predicted category.

  Future<Map<String, dynamic>> categorizeTransaction(
    String description,
  ) async {
    final startedAt = DateTime.now();
    try {
      final response = await http
          .post(
            Uri.parse(AppConstants.apiCategorize),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'description': description}),
          )
          .timeout(const Duration(seconds: 10));
      _recordApiCall(
        endpoint: AppConstants.apiCategorize,
        statusCode: response.statusCode,
        startedAt: startedAt,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'category': data['category'] ?? 'Other',
          'confidence': (data['confidence'] ?? 0.0).toDouble(),
          'success': true,
        };
      } else {
        return {
          'category': 'Other',
          'confidence': 0.0,
          'success': false,
          'error': 'API returned status ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'category': 'Other',
        'confidence': 0.0,
        'success': false,
        'error': 'Could not connect to ML server: $e',
      };
    }
  }

  // ── 2. Detect Unusual Spending ────────────────
  // Sends transaction amount + user history, gets anomaly flag.

  Future<Map<String, dynamic>> detectAnomaly({
    required double amount,
    required String category,
    required List<double> historyAmounts,
  }) async {
    final startedAt = DateTime.now();
    try {
      final response = await http
          .post(
            Uri.parse(AppConstants.apiAnomaly),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'amount': amount,
              'category': category,
              'history': historyAmounts,
            }),
          )
          .timeout(const Duration(seconds: 10));
      _recordApiCall(
        endpoint: AppConstants.apiAnomaly,
        statusCode: response.statusCode,
        startedAt: startedAt,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'isAnomaly': data['is_anomaly'] ?? false,
          'reason': data['reason'] ?? '',
          'score': (data['score'] ?? 0.0).toDouble(),
          'success': true,
        };
      } else {
        return {
          'isAnomaly': false,
          'reason': '',
          'score': 0.0,
          'success': false,
        };
      }
    } catch (e) {
      return {
        'isAnomaly': false,
        'reason': '',
        'score': 0.0,
        'success': false,
        'error': 'Anomaly detection failed: $e',
      };
    }
  }

  // ── 3. Predict Future Expenses ────────────────
  // Sends historical daily/weekly data, gets forecast.

  Future<Map<String, dynamic>> predictExpenses({
    required List<Map<String, dynamic>> historyData,
    required int predictDays,
  }) async {
    final startedAt = DateTime.now();
    try {
      final response = await http
          .post(
            Uri.parse(AppConstants.apiForecast),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'history': historyData,
              'predict_days': predictDays,
            }),
          )
          .timeout(const Duration(seconds: 15));
      _recordApiCall(
        endpoint: AppConstants.apiForecast,
        statusCode: response.statusCode,
        startedAt: startedAt,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'predictedTotal': (data['predicted_total'] ?? 0).toDouble(),
          'dailyForecast': data['daily_forecast'] ?? [],
          'confidence': (data['confidence'] ?? 0.0).toDouble(),
          'success': true,
        };
      } else {
        return {
          'predictedTotal': 0.0,
          'dailyForecast': [],
          'confidence': 0.0,
          'success': false,
        };
      }
    } catch (e) {
      return {
        'predictedTotal': 0.0,
        'dailyForecast': [],
        'confidence': 0.0,
        'success': false,
        'error': 'Forecast failed: $e',
      };
    }
  }

  // ── 4. Recommend Budgets ─────────────────────
  // Uses category history and the savings goal to suggest category limits.

  Future<Map<String, dynamic>> recommendBudgets({
    required Map<String, double> categorySpending,
    double savingsGoal = 0,
    double monthlyIncome = 0,
  }) async {
    final startedAt = DateTime.now();
    try {
      final response = await http
          .post(
            Uri.parse(AppConstants.apiBudgetRecommendations),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'category_spending': categorySpending,
              'savings_goal': savingsGoal,
              'monthly_income': monthlyIncome,
            }),
          )
          .timeout(const Duration(seconds: 10));
      _recordApiCall(
        endpoint: AppConstants.apiBudgetRecommendations,
        statusCode: response.statusCode,
        startedAt: startedAt,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'recommendations': Map<String, dynamic>.from(
            data['recommendations'] ?? {},
          ),
          'success': true,
        };
      }

      return {
        'recommendations': <String, dynamic>{},
        'success': false,
        'error': 'API returned status ${response.statusCode}',
      };
    } catch (e) {
      return {
        'recommendations': <String, dynamic>{},
        'success': false,
        'error': 'Budget recommendation failed: $e',
      };
    }
  }

  // ── 5. Generate AI Insights ───────────────────
  // Sends calculated data to Python backend which calls Gemini API.

  Future<Map<String, dynamic>> generateInsights({
    required double totalIncome,
    required double totalExpense,
    required double budgetLimit,
    required Map<String, double> categorySpending,
    required double previousMonthExpense,
    required List<String> unusualTransactions,
  }) async {
    final startedAt = DateTime.now();
    try {
      final response = await http
          .post(
            Uri.parse(AppConstants.apiInsights),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'total_income': totalIncome,
              'total_expense': totalExpense,
              'budget_limit': budgetLimit,
              'category_spending': categorySpending,
              'previous_month_expense': previousMonthExpense,
              'unusual_transactions': unusualTransactions,
            }),
          )
          .timeout(const Duration(seconds: 20));
      _recordApiCall(
        endpoint: AppConstants.apiInsights,
        statusCode: response.statusCode,
        startedAt: startedAt,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'summary': data['summary'] ?? 'No insights available.',
          'recommendations': data['recommendations'] ?? [],
          'alerts': data['alerts'] ?? [],
          'success': true,
        };
      } else {
        return {
          'summary': 'Could not generate insights.',
          'recommendations': [],
          'alerts': [],
          'success': false,
        };
      }
    } catch (e) {
      return {
        'summary': 'AI service unavailable: $e',
        'recommendations': [],
        'alerts': [],
        'success': false,
      };
    }
  }

  // ── 6. Health Check ──────────────────────────
  // Checks if the Python backend is running.

  Future<bool> isServerRunning() async {
    final startedAt = DateTime.now();
    try {
      final response = await http
          .get(Uri.parse('${AppConstants.apiBaseUrl}/health'))
          .timeout(const Duration(seconds: 5));
      _recordApiCall(
        endpoint: '${AppConstants.apiBaseUrl}/health',
        statusCode: response.statusCode,
        startedAt: startedAt,
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
