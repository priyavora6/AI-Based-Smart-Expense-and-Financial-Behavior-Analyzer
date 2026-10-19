import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_constants.dart';

/// Central Firebase initialisation and shared references.
/// Other services use this to get Firestore collections and the current user.
class FirebaseService {
  FirebaseService._();

  // ── Instances ─────────────────────────────────

  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // ── Current User ──────────────────────────────

  static User? get currentUser => auth.currentUser;
  static String get currentUserId => currentUser?.uid ?? '';
  static bool get isLoggedIn => currentUser != null;

  // ── Collection References ─────────────────────
  // Usage: FirebaseService.transactionsCol.doc(id)

  static CollectionReference get usersCol =>
      firestore.collection(AppConstants.colUsers);

  static CollectionReference get transactionsCol =>
      firestore.collection(AppConstants.colTransactions);

  static CollectionReference get categoriesCol =>
      firestore.collection(AppConstants.colCategories);

  static CollectionReference get budgetsCol =>
      firestore.collection(AppConstants.colBudgets);

  static CollectionReference get savingsGoalsCol =>
      firestore.collection(AppConstants.colSavingsGoals);

  static CollectionReference get recurringCol =>
      firestore.collection(AppConstants.colRecurring);

  static CollectionReference get notificationsCol =>
      firestore.collection(AppConstants.colNotifications);

  // ── User-Specific Queries ─────────────────────
  // These return only the current user's documents.

  static Query get userTransactions =>
      transactionsCol.where('userId', isEqualTo: currentUserId);

  static Query get userCategories =>
      categoriesCol.where('userId', isEqualTo: currentUserId);

  static Query get userBudgets =>
      budgetsCol.where('userId', isEqualTo: currentUserId);

  static Query get userSavingsGoals =>
      savingsGoalsCol.where('userId', isEqualTo: currentUserId);

  static Query get userRecurring =>
      recurringCol.where('userId', isEqualTo: currentUserId);

  static Query get userNotifications =>
      notificationsCol
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true);
}