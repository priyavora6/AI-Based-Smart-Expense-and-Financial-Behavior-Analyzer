import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_constants.dart';
import '../models/category_model.dart';
import 'firebase_service.dart';

/// Manages default and custom expense/income categories.
class CategoryService {
  final FirebaseFirestore _db = FirebaseService.firestore;
  final String _col = AppConstants.colCategories;

  // ── Setup Default Categories (First Time) ─────

  Future<void> setupDefaultCategories(String userId) async {
    // Check if categories already exist
    final existing = await _db
        .collection(_col)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return; // Already set up

    await _createDefaultCategories(userId);
  }

  Future<void> _createDefaultCategories(String userId) async {
    // Add all default categories
    final batch = _db.batch();
    for (final cat in CategoryModel.defaultCategories) {
      final docRef = _db.collection(_col).doc();
      batch.set(docRef, {
        ...cat.toFirestore(),
        'userId': userId,
        'isActive': true,
      });
    }
    await batch.commit();
  }

  Future<void> ensureDefaultCategories(String userId) async {
    final existing = await _db
        .collection(_col)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (existing.docs.isEmpty) {
      await _createDefaultCategories(userId);
      return;
    }

    final categories =
        await _db.collection(_col).where('userId', isEqualTo: userId).get();
    final existingDefaultNames = categories.docs
        .where((doc) => (doc.data()['isDefault'] ?? false) == true)
        .map((doc) => (doc.data()['name'] ?? '').toString().toLowerCase())
        .toSet();

    final missingDefaults = CategoryModel.defaultCategories
        .where((category) =>
            !existingDefaultNames.contains(category.name.toLowerCase()))
        .toList();

    if (missingDefaults.isNotEmpty) {
      final batch = _db.batch();
      for (final category in missingDefaults) {
        final docRef = _db.collection(_col).doc();
        batch.set(docRef, {
          ...category.toFirestore(),
          'userId': userId,
          'isActive': true,
        });
      }
      await batch.commit();
    }
  }

  // ── Get All Categories ────────────────────────

  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await FirebaseService.userCategories.get();

    return snapshot.docs
        .where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['isActive'] != false;
        })
        .map((doc) => CategoryModel.fromFirestore(doc))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  // ── Get Expense Categories Only ───────────────

  Future<List<CategoryModel>> getExpenseCategories() async {
    final all = await getCategories();
    return all.where((c) => c.type == 'expense' || c.type == 'both').toList();
  }

  // ── Get Income Categories Only ────────────────

  Future<List<CategoryModel>> getIncomeCategories() async {
    final all = await getCategories();
    return all.where((c) => c.type == 'income' || c.type == 'both').toList();
  }

  // ── Add Custom Category ───────────────────────

  Future<String> addCategory(CategoryModel category) async {
    final docRef = await _db.collection(_col).add({
      ...category.toFirestore(),
      'userId': FirebaseService.currentUserId,
    });
    return docRef.id;
  }

  // ── Update Category ───────────────────────────

  Future<void> updateCategory(CategoryModel category) async {
    await _db.collection(_col).doc(category.id).update({
      ...category.toFirestore(),
      'userId': FirebaseService.currentUserId,
    });
  }

  // ── Delete Category (Soft Delete) ─────────────

  Future<void> deleteCategory(String categoryId) async {
    await _db.collection(_col).doc(categoryId).update({
      'isActive': false,
    });
  }
}
