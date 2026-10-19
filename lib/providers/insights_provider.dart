import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/insight_model.dart';
import '../models/transaction_model.dart';
import '../services/ml_api_service.dart';
import '../services/transaction_service.dart';
import '../services/firebase_service.dart';
import '../services/budget_service.dart';
import '../services/notification_service.dart';
import '../services/admin_data_service.dart';

class InsightsProvider extends ChangeNotifier {
  final MLApiService _mlApiService = MLApiService();
  final TransactionService _transactionService = TransactionService();
  final BudgetService _budgetService = BudgetService();
  final NotificationService _notificationService = NotificationService();
  final AdminDataService _adminDataService = AdminDataService();

  List<InsightModel> _insights = [];
  String _monthlySummary = '';
  List<String> _recommendations = [];
  List<String> _alerts = [];
  bool _isLoading = false;
  bool _isServerAvailable = false;
  StreamSubscription<List<TransactionModel>>? _transactionsSubscription;
  Timer? _refreshTimer;
  bool _realtimeStarted = false;

  // ── Getters ───────────────────────────────────

  List<InsightModel> get insights => _insights;
  String get monthlySummary => _monthlySummary;
  List<String> get recommendations => _recommendations;
  List<String> get alerts => _alerts;
  bool get isLoading => _isLoading;
  bool get isServerAvailable => _isServerAvailable;

  List<InsightModel> get unusualInsights =>
      _insights.where((i) => i.isUnusual).toList();
  List<InsightModel> get warningInsights =>
      _insights.where((i) => i.isWarning || i.isCritical).toList();

  // ── Check Server ──────────────────────────────

  Future<void> checkServer() async {
    _isServerAvailable = await _mlApiService.isServerRunning();
    notifyListeners();
  }

  void startRealtimeUpdates() {
    if (_realtimeStarted) return;
    _realtimeStarted = true;
    _transactionsSubscription =
        _transactionService.streamTransactions().listen((_) {
      _refreshTimer?.cancel();
      _refreshTimer = Timer(const Duration(milliseconds: 750), () {
        if (!_isLoading) {
          generateInsights();
        }
      });
    }, onError: (Object error) {
      debugPrint('Insights realtime update error: $error');
    });
  }

  // ── Generate Monthly Insights ─────────────────

  Future<void> generateInsights() async {
    startRealtimeUpdates();
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      await checkServer();
      final now = DateTime.now();

      // Get current month data
      final totals = await _transactionService.getMonthlyTotals(
        month: now.month,
        year: now.year,
      );

      final categorySpending = await _transactionService.getCategorySpending(
        month: now.month,
        year: now.year,
      );

      // Get previous month expense
      int prevMonth = now.month - 1;
      int prevYear = now.year;
      if (prevMonth == 0) {
        prevMonth = 12;
        prevYear -= 1;
      }

      final prevTotals = await _transactionService.getMonthlyTotals(
        month: prevMonth,
        year: prevYear,
      );
      final currentBudget = await _budgetService.getTotalBudget(
        month: now.month,
        year: now.year,
      );

      // Get unusual transactions
      final allTransactions = await _transactionService.getTransactions(
        startDate: DateTime(now.year, now.month, 1),
      );
      final unusualList = allTransactions
          .where((t) => t.isAnomaly)
          .map((t) => '${t.description}: ₹${t.amount}')
          .toList();

      if (!_isServerAvailable) {
        _buildLocalInsights(
          now: now,
          totals: totals,
          categorySpending: categorySpending,
          previousMonthExpense: prevTotals['expense'] ?? 0,
          unusualList: unusualList,
        );
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Call ML API
      final result = await _mlApiService.generateInsights(
        totalIncome: totals['income'] ?? 0,
        totalExpense: totals['expense'] ?? 0,
        budgetLimit: currentBudget?.limitAmount ?? 0,
        categorySpending: categorySpending,
        previousMonthExpense: prevTotals['expense'] ?? 0,
        unusualTransactions: unusualList,
      );

      if (result['success'] == true) {
        _monthlySummary = result['summary'] ?? '';
        _recommendations = List<String>.from(result['recommendations'] ?? []);
        _alerts = List<String>.from(result['alerts'] ?? []);
        if (_monthlySummary.isNotEmpty) {
          await _notificationService.createAIInsightNotification(
            _monthlySummary,
          );
        }

        // Convert to InsightModel list
        _insights = [];

        if (_monthlySummary.isNotEmpty) {
          _insights.add(InsightModel(
            id: 'summary_${now.month}',
            userId: FirebaseService.currentUserId,
            type: 'monthly_summary',
            title: 'Monthly Summary',
            message: _monthlySummary,
            severity: 'info',
            createdAt: DateTime.now(),
          ));
        }

        for (final rec in _recommendations) {
          _insights.add(InsightModel(
            id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
            userId: FirebaseService.currentUserId,
            type: 'recommendation',
            title: 'Recommendation',
            message: rec,
            severity: 'info',
            createdAt: DateTime.now(),
          ));
        }

        for (final alert in _alerts) {
          _insights.add(InsightModel(
            id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
            userId: FirebaseService.currentUserId,
            type: 'budget_alert',
            title: 'Alert',
            message: alert,
            severity: 'warning',
            createdAt: DateTime.now(),
          ));
        }
        await _persistGeneratedInsights();
      } else {
        _buildLocalInsights(
          now: now,
          totals: totals,
          categorySpending: categorySpending,
          previousMonthExpense: prevTotals['expense'] ?? 0,
          unusualList: unusualList,
        );
      }
    } catch (e) {
      _monthlySummary = 'Could not generate insights from your transactions.';
      debugPrint('Insights error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void _buildLocalInsights({
    required DateTime now,
    required Map<String, double> totals,
    required Map<String, double> categorySpending,
    required double previousMonthExpense,
    required List<String> unusualList,
  }) {
    final income = totals['income'] ?? 0;
    final expense = totals['expense'] ?? 0;
    final balance = income - expense;
    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategory =
        sortedCategories.isEmpty ? null : sortedCategories.first;
    final insights = <InsightModel>[];

    if (income == 0 && expense == 0) {
      _monthlySummary =
          'Add your first income or expense to receive personalised insights.';
      _recommendations = [
        'Track each transaction so your spending patterns can be analysed.'
      ];
      _alerts = [];
    } else {
      _monthlySummary = balance >= 0
          ? 'You have ₹${balance.toStringAsFixed(0)} left after this month’s spending.'
          : 'Your expenses are ₹${(-balance).toStringAsFixed(0)} higher than your income this month.';
      _recommendations = [];
      _alerts = [];

      if (topCategory != null) {
        _recommendations.add(
          '${topCategory.key} is your largest spending category at ₹${topCategory.value.toStringAsFixed(0)}.',
        );
      }
      if (previousMonthExpense > 0 && expense > previousMonthExpense) {
        final increase =
            ((expense - previousMonthExpense) / previousMonthExpense * 100)
                .toStringAsFixed(0);
        _alerts.add('Your expenses are $increase% higher than last month.');
      }
      if (balance < 0) {
        _alerts.add(
            'Review your expenses because they are higher than your income.');
      }
      if (unusualList.isNotEmpty) {
        _alerts.add(
            '${unusualList.length} unusual transaction(s) need your attention.');
      }
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    insights.add(InsightModel(
      id: 'local_summary_$timestamp',
      userId: FirebaseService.currentUserId,
      type: 'monthly_summary',
      title: 'Monthly Summary',
      message: _monthlySummary,
      severity: balance < 0 ? 'warning' : 'info',
      createdAt: DateTime.now(),
    ));
    insights
        .addAll(_recommendations.asMap().entries.map((entry) => InsightModel(
              id: 'local_recommendation_${timestamp}_${entry.key}',
              userId: FirebaseService.currentUserId,
              type: 'recommendation',
              title: 'Recommendation',
              message: entry.value,
              severity: 'info',
              createdAt: DateTime.now(),
            )));
    insights.addAll(_alerts.asMap().entries.map((entry) => InsightModel(
          id: 'local_alert_${timestamp}_${entry.key}',
          userId: FirebaseService.currentUserId,
          type: 'budget_alert',
          title: 'Alert',
          message: entry.value,
          severity: 'warning',
          createdAt: DateTime.now(),
        )));
    _insights = insights;
    _persistGeneratedInsights();
  }

  Future<void> _persistGeneratedInsights() async {
    try {
      await Future.wait(
        _insights.map(
          (insight) => _adminDataService.savePrediction(
            type: insight.type,
            data: insight.toJson(),
          ),
        ),
      );
      await _adminDataService.saveAuditLog(
        action: 'generate_insights',
        resource: 'predictions',
        details: {'count': _insights.length},
      );
    } catch (e) {
      debugPrint('Could not persist generated insights: $e');
    }
  }

  // ── Clear ─────────────────────────────────────

  void clearInsights() {
    _insights = [];
    _monthlySummary = '';
    _recommendations = [];
    _alerts = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _transactionsSubscription?.cancel();
    super.dispose();
  }
}
