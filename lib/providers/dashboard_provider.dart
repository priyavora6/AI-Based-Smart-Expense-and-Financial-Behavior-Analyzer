import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class DashboardProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  double _totalIncome = 0;
  double _totalExpense = 0;
  double _balance = 0;
  Map<String, double> _categorySpending = {};
  bool _isLoading = false;
  StreamSubscription<List<TransactionModel>>? _transactionsSubscription;

  // ── Getters ───────────────────────────────────

  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get totalBalance => _balance; // Screen expects totalBalance
  Map<String, double> get categoryBreakdown =>
      _categorySpending; // Screen expects categoryBreakdown
  bool get isLoading => _isLoading;

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // ── Load Dashboard Data ───────────────────────

  Future<void> loadDashboardData() async {
    // Screen expects loadDashboardData
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();

      // Load monthly totals
      final totals = await _transactionService.getMonthlyTotals(
        month: now.month,
        year: now.year,
      );

      _totalIncome = totals['income'] ?? 0;
      _totalExpense = totals['expense'] ?? 0;
      _balance = totals['balance'] ?? 0;

      // Load category spending
      _categorySpending = await _transactionService.getCategorySpending(
        month: now.month,
        year: now.year,
      );
    } catch (e) {
      debugPrint('Dashboard load error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void startRealtimeUpdates() {
    _transactionsSubscription?.cancel();
    _transactionsSubscription =
        _transactionService.streamTransactions().listen((transactions) {
      final now = DateTime.now();
      final monthly = transactions.where(
        (transaction) =>
            transaction.date.year == now.year &&
            transaction.date.month == now.month,
      );

      _totalIncome = monthly
          .where((transaction) => transaction.isIncome)
          .fold(0.0, (sum, transaction) => sum + transaction.amount);
      _totalExpense = monthly
          .where((transaction) => transaction.isExpense)
          .fold(0.0, (sum, transaction) => sum + transaction.amount);
      _balance = _totalIncome - _totalExpense;
      _categorySpending = {};
      for (final transaction in monthly.where((item) => item.isExpense)) {
        _categorySpending[transaction.categoryName] =
            (_categorySpending[transaction.categoryName] ?? 0) +
                transaction.amount;
      }
      notifyListeners();
    }, onError: (Object error) {
      debugPrint('Dashboard realtime update error: $error');
    });
  }

  // ── Refresh ───────────────────────────────────

  Future<void> refresh() async {
    await loadDashboardData();
  }

  @override
  void dispose() {
    _transactionsSubscription?.cancel();
    super.dispose();
  }
}
