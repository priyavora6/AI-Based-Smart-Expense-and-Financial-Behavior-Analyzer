import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_constants.dart';
import '../models/budget_model.dart';
import 'firebase_service.dart';

/// Manages monthly budgets and tracks spending against limits.
class BudgetService {
  final FirebaseFirestore _db = FirebaseService.firestore;
  final String _col = AppConstants.colBudgets;

  // ── Create Budget ─────────────────────────────

  Future<String> createBudget(BudgetModel budget) async {
    final docRef = await _db.collection(_col).add(budget.toFirestore());
    return docRef.id;
  }

  // ── Update Budget ─────────────────────────────

  Future<void> updateBudget(BudgetModel budget) async {
    await _db.collection(_col).doc(budget.id).update({
      ...budget.toFirestore(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ── Delete Budget ─────────────────────────────

  Future<void> deleteBudget(String budgetId) async {
    await _db.collection(_col).doc(budgetId).delete();
  }

  // ── Get Current Month Budgets ─────────────────

  Future<List<BudgetModel>> getCurrentMonthBudgets() async {
    final now = DateTime.now();
    return getBudgetsForMonth(month: now.month, year: now.year);
  }

  // ── Get Budgets for Specific Month ────────────

  Future<List<BudgetModel>> getBudgetsForMonth({
    required int month,
    required int year,
  }) async {
    final snapshot = await FirebaseService.userBudgets.get();

    return snapshot.docs
        .map((doc) => BudgetModel.fromFirestore(doc))
        .where((budget) => budget.month == month && budget.year == year)
        .toList();
  }

  // ── Get Total Monthly Budget ──────────────────

  Future<BudgetModel?> getTotalBudget({
    required int month,
    required int year,
  }) async {
    final budgets = await getBudgetsForMonth(month: month, year: year);
    for (final budget in budgets) {
      if (budget.isTotalBudget) return budget;
    }
    return null;
  }

  // ── Update Spent Amount ───────────────────────
  // Called when a new transaction is added.

  Future<void> updateSpentAmount({
    required String budgetId,
    required double newSpentAmount,
  }) async {
    await _db.collection(_col).doc(budgetId).update({
      'spentAmount': newSpentAmount,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ── Check Budget Alerts ───────────────────────

  Future<List<BudgetModel>> getExceededBudgets() async {
    final budgets = await getCurrentMonthBudgets();
    return budgets.where((b) => b.isExceeded).toList();
  }

  Future<List<BudgetModel>> getWarningBudgets() async {
    final budgets = await getCurrentMonthBudgets();
    return budgets.where((b) => b.isWarning).toList();
  }
}
