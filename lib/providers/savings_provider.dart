import 'package:flutter/foundation.dart';
import '../models/savings_goal_model.dart';
import '../services/firebase_service.dart';
import '../services/firestore_service.dart';
import '../config/app_constants.dart';

class SavingsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<SavingsGoalModel> _goals = [];
  bool _isLoading = false;

  // ── Getters ───────────────────────────────────

  List<SavingsGoalModel> get goals => _goals;
  List<SavingsGoalModel> get activeGoals =>
      _goals.where((g) => g.status == 'active').toList();
  List<SavingsGoalModel> get completedGoals =>
      _goals.where((g) => g.status == 'completed').toList();
  bool get isLoading => _isLoading;

  double get totalTarget =>
      _goals.fold(0.0, (sum, g) => sum + g.targetAmount);
  double get totalSaved =>
      _goals.fold(0.0, (sum, g) => sum + g.savedAmount);

  // ── Load Goals ────────────────────────────────

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestoreService.queryDocuments(
        collection: AppConstants.colSavingsGoals,
        field: 'userId',
        value: FirebaseService.currentUserId,
      );

      _goals = snapshot.docs
          .map((doc) => SavingsGoalModel.fromFirestore(doc))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error loading savings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Add Goal ──────────────────────────────────

  Future<bool> addGoal({
    required String name,
    required double targetAmount,
    required DateTime targetDate,
    String? icon,
  }) async {
    try {
      final goal = SavingsGoalModel(
        id: '',
        userId: FirebaseService.currentUserId,
        name: name,
        icon: icon,
        targetAmount: targetAmount,
        targetDate: targetDate,
        createdAt: DateTime.now(),
      );

      await _firestoreService.addDocument(
        collection: AppConstants.colSavingsGoals,
        data: goal.toFirestore(),
      );

      await loadGoals();
      return true;
    } catch (e) {
      debugPrint('Error adding goal: $e');
      return false;
    }
  }

  // ── Add Savings to Goal ───────────────────────

  Future<bool> addToGoal(String goalId, double amount) async {
    try {
      final goal = _goals.firstWhere((g) => g.id == goalId);
      final newSaved = goal.savedAmount + amount;
      final newStatus = newSaved >= goal.targetAmount ? 'completed' : 'active';

      await _firestoreService.updateDocument(
        collection: AppConstants.colSavingsGoals,
        docId: goalId,
        data: {
          'savedAmount': newSaved,
          'status': newStatus,
          'updatedAt': DateTime.now(),
        },
      );

      await loadGoals();
      return true;
    } catch (e) {
      debugPrint('Error adding to goal: $e');
      return false;
    }
  }

  // ── Delete Goal ───────────────────────────────

  Future<bool> deleteGoal(String goalId) async {
    try {
      await _firestoreService.deleteDocument(
        collection: AppConstants.colSavingsGoals,
        docId: goalId,
      );
      await loadGoals();
      return true;
    } catch (e) {
      return false;
    }
  }
}