import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  // ── Getters ───────────────────────────────────

  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get expenseCategories =>
      _categories.where((c) => c.type == 'expense' || c.type == 'both').toList();
  List<CategoryModel> get incomeCategories =>
      _categories.where((c) => c.type == 'income' || c.type == 'both').toList();
  bool get isLoading => _isLoading;

  // ── Load Categories ───────────────────────────

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _categoryService.getCategories();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Add Custom Category ───────────────────────

  Future<bool> addCategory({
    required String name,
    required String icon,
    required String type,
    required int colorValue,
  }) async {
    try {
      final category = CategoryModel(
        id: '',
        name: name,
        icon: icon,
        type: type,
        colorValue: colorValue,
        createdAt: DateTime.now(),
      );

      await _categoryService.addCategory(category);
      await loadCategories();
      return true;
    } catch (e) {
      debugPrint('Error adding category: $e');
      return false;
    }
  }

  // ── Delete Category ───────────────────────────

  Future<bool> deleteCategory(String categoryId) async {
    try {
      await _categoryService.deleteCategory(categoryId);
      await loadCategories();
      return true;
    } catch (e) {
      debugPrint('Error deleting category: $e');
      return false;
    }
  }

  Future<bool> updateCategory(CategoryModel category) async {
    try {
      await _categoryService.updateCategory(category);
      await loadCategories();
      return true;
    } catch (e) {
      debugPrint('Error updating category: $e');
      return false;
    }
  }

  // ── Get Category by ID ────────────────────────

  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Get Category by Name ──────────────────────

  CategoryModel? getCategoryByName(String name) {
    try {
      return _categories.firstWhere(
            (c) => c.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}