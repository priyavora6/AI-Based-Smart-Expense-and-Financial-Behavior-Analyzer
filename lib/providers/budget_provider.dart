import 'package:flutter/foundation.dart';
import '../models/budget_model.dart';
import '../services/budget_service.dart';
import '../services/transaction_service.dart';
import '../services/notification_service.dart';
import '../services/firebase_service.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetService _budgetService = BudgetService();
  final TransactionService _transactionService = TransactionService();
  final NotificationService _notificationService = NotificationService();

  List<BudgetModel> _budgets = [];
  BudgetModel? _totalBudget;
  bool _isLoading = false;
  String _errorMessage = '';

  // ── Getters ───────────────────────────────────

  List<BudgetModel> get budgets => _budgets;
  BudgetModel? get totalBudget => _totalBudget;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  List<BudgetModel> get categoryBudgets =>
      _budgets.where((b) => !b.isTotalBudget).toList();

  List<BudgetModel> get exceededBudgets =>
      _budgets.where((b) => b.isExceeded).toList();

  List<BudgetModel> get warningBudgets =>
      _budgets.where((b) => b.isWarning).toList();

  // ── Load Budgets ──────────────────────────────

  Future<void> loadBudgets() async {
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final loadedBudgets = await _budgetService.getCurrentMonthBudgets();
      final transactions = await _transactionService.getTransactions(
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        type: 'expense',
      );
      final totalSpent = transactions.fold<double>(
          0, (sum, transaction) => sum + transaction.amount);
      _budgets = loadedBudgets.map((budget) {
        final spent = budget.isTotalBudget
            ? totalSpent
            : transactions
                .where((transaction) =>
                    transaction.categoryId == budget.categoryId ||
                    transaction.categoryName.toLowerCase() ==
                        budget.categoryName.toLowerCase())
                .fold<double>(
                    0, (sum, transaction) => sum + transaction.amount);
        return budget.copyWith(spentAmount: spent);
      }).toList();
      _totalBudget = await _budgetService.getTotalBudget(
        month: now.month,
        year: now.year,
      );
      if (_totalBudget != null) {
        _totalBudget = _totalBudget!.copyWith(spentAmount: totalSpent);
      }
      await checkBudgetAlerts();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Create Budget ─────────────────────────────

  Future<bool> createBudget({
    required String categoryId,
    required String categoryName,
    required double limitAmount,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final budget = BudgetModel(
        id: '',
        userId: FirebaseService.currentUserId,
        categoryId: categoryId,
        categoryName: categoryName,
        limitAmount: limitAmount,
        month: now.month,
        year: now.year,
        createdAt: DateTime.now(),
      );

      await _budgetService.createBudget(budget);
      await loadBudgets();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Update Budget ─────────────────────────────

  Future<bool> updateBudget(BudgetModel budget) async {
    try {
      await _budgetService.updateBudget(budget);
      await loadBudgets();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // ── Delete Budget ─────────────────────────────

  Future<bool> deleteBudget(String budgetId) async {
    try {
      await _budgetService.deleteBudget(budgetId);
      await loadBudgets();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // ── Check and Notify Budget Alerts ────────────

  Future<void> checkBudgetAlerts() async {
    for (final budget in _budgets) {
      if (budget.isExceeded) {
        await _notificationService.createBudgetAlert(
          categoryName: budget.categoryName,
          spent: budget.spentAmount,
          limit: budget.limitAmount,
        );
      } else if (budget.isWarning) {
        await _notificationService.createBudgetAlert(
          categoryName: budget.categoryName,
          spent: budget.spentAmount,
          limit: budget.limitAmount,
        );
      }
    }
  }
}
