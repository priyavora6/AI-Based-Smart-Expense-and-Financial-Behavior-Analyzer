import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/app_constants.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../services/ml_api_service.dart';
import '../services/notification_service.dart';
import '../services/firebase_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  final MLApiService _mlApiService = MLApiService();
  final NotificationService _notificationService = NotificationService();

  List<TransactionModel> _transactions = [];
  List<TransactionModel> _recentTransactions = [];
  bool _isLoading = false;
  String _errorMessage = '';
  StreamSubscription<List<TransactionModel>>? _transactionsSubscription;

  // ── Getters ───────────────────────────────────

  List<TransactionModel> get transactions => _transactions;
  List<TransactionModel> get recentTransactions => _recentTransactions;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get totalCount => _transactions.length;

  double get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  // ── Load Transactions ─────────────────────────

  Future<void> loadTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? type,
  }) async {
    _setLoading(true);

    try {
      _transactions = await _transactionService.getTransactions(
        startDate: startDate,
        endDate: endDate,
        categoryId: categoryId,
        type: type,
      );
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  // ── Load Recent (for Dashboard) ───────────────

  Future<void> loadRecentTransactions() async {
    try {
      _recentTransactions = await _transactionService.getRecentTransactions();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading recent: $e');
    }
  }

  void startRealtimeUpdates() {
    _transactionsSubscription?.cancel();
    _transactionsSubscription =
        _transactionService.streamTransactions().listen((transactions) {
      _transactions = transactions;
      _recentTransactions =
          transactions.take(AppConstants.recentTransactionLimit).toList();
      notifyListeners();
    }, onError: (Object error) {
      debugPrint('Transaction realtime update error: $error');
    });
  }

  // ── Add Transaction ───────────────────────────

  Future<bool> addTransaction({
    required double amount,
    required String description,
    required String categoryId,
    required String categoryName,
    required String type,
    String paymentMethod = 'cash',
    DateTime? date,
  }) async {
    _setLoading(true);

    try {
      // 1. Auto-categorize using ML (if description is provided)
      String predictedCategory = categoryName;
      double confidence = 0.0;

      if (description.isNotEmpty) {
        final mlResult = await _mlApiService.categorizeTransaction(description);
        if (mlResult['success'] == true && mlResult['confidence'] >= 0.70) {
          predictedCategory = mlResult['category'];
          confidence = mlResult['confidence'];
        }
      }

      // 2. Create transaction model
      final transaction = TransactionModel(
        id: '',
        userId: FirebaseService.currentUserId,
        amount: amount,
        description: description,
        categoryId: categoryId,
        categoryName: predictedCategory,
        type: type,
        paymentMethod: paymentMethod,
        date: date ?? DateTime.now(),
        mlPredictedCategory: predictedCategory,
        mlConfidence: confidence,
        createdAt: DateTime.now(),
      );

      // 3. Save to Firestore
      final docId = await _transactionService.addTransaction(transaction);

      // 4. Check for anomaly (for expenses only)
      if (type == 'expense') {
        await _checkAnomaly(docId, amount, predictedCategory);
      }

      // 5. Reload list
      await loadRecentTransactions();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ── Update Transaction ────────────────────────

  Future<bool> updateTransaction(TransactionModel transaction) async {
    _setLoading(true);

    try {
      await _transactionService.updateTransaction(transaction);
      await loadTransactions();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ── Delete Transaction ────────────────────────

  Future<bool> deleteTransaction(String transactionId) async {
    _setLoading(true);

    try {
      await _transactionService.deleteTransaction(transactionId);
      _transactions.removeWhere((t) => t.id == transactionId);
      _recentTransactions.removeWhere((t) => t.id == transactionId);
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ── Anomaly Check (Private) ───────────────────

  Future<void> _checkAnomaly(
    String transactionId,
    double amount,
    String category,
  ) async {
    try {
      // Get past amounts for this category
      final pastTransactions = _transactions
          .where((t) => t.categoryName == category && t.isExpense)
          .map((t) => t.amount)
          .toList();

      if (pastTransactions.length < 3) return; // Not enough data

      final result = await _mlApiService.detectAnomaly(
        amount: amount,
        category: category,
        historyAmounts: pastTransactions,
      );

      if (result['success'] == true && result['isAnomaly'] == true) {
        await _transactionService.markAsAnomaly(
          transactionId,
          result['reason'] ?? 'Unusual amount',
        );

        await _notificationService.createUnusualSpendingAlert(
          description: 'transaction',
          amount: amount,
          category: category,
        );
      }
    } catch (e) {
      debugPrint('Anomaly check failed: $e');
    }
  }

  // ── Helper ────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _transactionsSubscription?.cancel();
    super.dispose();
  }
}
