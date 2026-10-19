import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_constants.dart';
import '../models/transaction_model.dart';
import 'firebase_service.dart';

/// All transaction-related Firestore operations.
class TransactionService {
  final FirebaseFirestore _db = FirebaseService.firestore;
  final String _col = AppConstants.colTransactions;

  // ── Add Transaction ───────────────────────────

  Future<String> addTransaction(TransactionModel transaction) async {
    final docRef = await _db.collection(_col).add(transaction.toFirestore());
    return docRef.id;
  }

  // ── Update Transaction ────────────────────────

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _db.collection(_col).doc(transaction.id).update({
      ...transaction.toFirestore(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ── Delete Transaction ────────────────────────

  Future<void> deleteTransaction(String transactionId) async {
    await _db.collection(_col).doc(transactionId).delete();
  }

  // ── Get All Transactions (Current User) ───────

  Future<List<TransactionModel>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? type,
    int? limit,
  }) async {
    final snapshot = await FirebaseService.userTransactions.get();
    final transactions = snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList();

    final filtered = transactions.where((transaction) {
      if (startDate != null && transaction.date.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && transaction.date.isAfter(endDate)) {
        return false;
      }
      if (categoryId != null && transaction.categoryId != categoryId) {
        return false;
      }
      if (type != null && transaction.type != type) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return limit == null ? filtered : filtered.take(limit).toList();
  }

  // ── Get Recent Transactions ───────────────────

  Future<List<TransactionModel>> getRecentTransactions({
    int limit = AppConstants.recentTransactionLimit,
  }) async {
    return getTransactions(limit: limit);
  }

  // ── Stream Transactions (Real-time) ───────────

  Stream<List<TransactionModel>> streamTransactions() {
    return FirebaseService.userTransactions.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList()
          ..sort((a, b) => b.date.compareTo(a.date)));
  }

  // ── Get Monthly Totals ────────────────────────

  Future<Map<String, double>> getMonthlyTotals({
    required int month,
    required int year,
  }) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final transactions =
        await getTransactions(startDate: startDate, endDate: endDate);

    double totalIncome = 0;
    double totalExpense = 0;

    for (final t in transactions) {
      if (t.isIncome) {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
      }
    }

    return {
      'income': totalIncome,
      'expense': totalExpense,
      'balance': totalIncome - totalExpense,
    };
  }

  // ── Get Category-wise Spending ────────────────

  Future<Map<String, double>> getCategorySpending({
    required int month,
    required int year,
  }) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final transactions = await getTransactions(
      startDate: startDate,
      endDate: endDate,
      type: 'expense',
    );

    final Map<String, double> categoryTotals = {};

    for (final t in transactions) {
      categoryTotals[t.categoryName] =
          (categoryTotals[t.categoryName] ?? 0) + t.amount;
    }

    return categoryTotals;
  }

  // ── Mark as Anomaly ──────────────────────────

  Future<void> markAsAnomaly(
    String transactionId,
    String reason,
  ) async {
    await _db.collection(_col).doc(transactionId).update({
      'isAnomaly': true,
      'anomalyReason': reason,
    });
  }
}
