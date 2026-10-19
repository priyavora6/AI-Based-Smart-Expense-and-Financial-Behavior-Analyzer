import 'package:flutter/foundation.dart';
import '../models/recurring_transaction_model.dart';
import '../services/firebase_service.dart';
import '../services/firestore_service.dart';
import '../services/transaction_service.dart';
import '../models/transaction_model.dart';
import '../services/notification_service.dart';
import '../config/app_constants.dart';

class RecurringProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final TransactionService _transactionService = TransactionService();
  final NotificationService _notificationService = NotificationService();

  List<RecurringTransactionModel> _recurring = [];
  bool _isLoading = false;

  // ── Getters ───────────────────────────────────

  List<RecurringTransactionModel> get recurring => _recurring;
  List<RecurringTransactionModel> get activeRecurring =>
      _recurring.where((r) => r.isActive).toList();
  List<RecurringTransactionModel> get dueToday =>
      _recurring.where((r) => r.isDueToday && r.isActive).toList();
  List<RecurringTransactionModel> get overdue =>
      _recurring.where((r) => r.isOverdue && r.isActive).toList();
  bool get isLoading => _isLoading;

  double get totalMonthlyRecurring => activeRecurring
      .where((r) => r.frequency == 'monthly')
      .fold(0.0, (sum, r) => sum + r.amount);

  // ── Load Recurring ────────────────────────────

  Future<void> loadRecurring({bool processDue = true}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestoreService.queryDocuments(
        collection: AppConstants.colRecurring,
        field: 'userId',
        value: FirebaseService.currentUserId,
      );

      _recurring = snapshot.docs
          .map((doc) => RecurringTransactionModel.fromFirestore(doc))
          .toList()
        ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    } catch (e) {
      debugPrint('Error loading recurring: $e');
    }

    _isLoading = false;
    notifyListeners();
    if (processDue) await processDueTransactions();
  }

  Future<void> processDueTransactions() async {
    final now = DateTime.now();
    for (final item in List<RecurringTransactionModel>.from(_recurring)) {
      if (!item.isActive || item.nextDueDate.isAfter(now)) continue;
      await _transactionService.addTransaction(
        TransactionModel(
          id: '',
          userId: FirebaseService.currentUserId,
          amount: item.amount,
          description: item.description,
          categoryId: item.categoryId,
          categoryName: item.categoryName,
          type: item.type,
          paymentMethod: item.paymentMethod,
          date: item.nextDueDate,
          createdAt: DateTime.now(),
        ),
      );
      await _notificationService.createNotification(
        title: 'Recurring transaction added',
        body: '₹${item.amount.toStringAsFixed(0)} ${item.type} for '
            '${item.description} was added automatically.',
        type: 'recurring_due',
      );
      var nextDate = item.nextDueDate;
      do {
        nextDate = _nextDate(nextDate, item.frequency);
      } while (!nextDate.isAfter(now));
      await _firestoreService.updateDocument(
        collection: AppConstants.colRecurring,
        docId: item.id,
        data: {'nextDueDate': nextDate},
      );
    }
    await loadRecurring(processDue: false);
  }

  DateTime _nextDate(DateTime date, String frequency) {
    switch (frequency) {
      case 'daily':
        return date.add(const Duration(days: 1));
      case 'weekly':
        return date.add(const Duration(days: 7));
      case 'yearly':
        return DateTime(date.year + 1, date.month, date.day);
      default:
        return DateTime(date.year, date.month + 1, date.day);
    }
  }

  // ── Add Recurring ─────────────────────────────

  Future<bool> addRecurring({
    required double amount,
    required String description,
    required String categoryId,
    required String categoryName,
    required String type,
    required String frequency,
    required DateTime nextDueDate,
    String paymentMethod = 'upi',
  }) async {
    try {
      final recurring = RecurringTransactionModel(
        id: '',
        userId: FirebaseService.currentUserId,
        amount: amount,
        description: description,
        categoryId: categoryId,
        categoryName: categoryName,
        type: type,
        frequency: frequency,
        paymentMethod: paymentMethod,
        nextDueDate: nextDueDate,
        createdAt: DateTime.now(),
      );

      await _firestoreService.addDocument(
        collection: AppConstants.colRecurring,
        data: recurring.toFirestore(),
      );

      await loadRecurring();
      return true;
    } catch (e) {
      debugPrint('Error adding recurring: $e');
      return false;
    }
  }

  // ── Toggle Active ─────────────────────────────

  Future<bool> toggleActive(String id, bool isActive) async {
    try {
      await _firestoreService.updateDocument(
        collection: AppConstants.colRecurring,
        docId: id,
        data: {'isActive': isActive},
      );
      await loadRecurring();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Delete ────────────────────────────────────

  Future<bool> deleteRecurring(String id) async {
    try {
      await _firestoreService.deleteDocument(
        collection: AppConstants.colRecurring,
        docId: id,
      );
      await loadRecurring();
      return true;
    } catch (e) {
      return false;
    }
  }
}
