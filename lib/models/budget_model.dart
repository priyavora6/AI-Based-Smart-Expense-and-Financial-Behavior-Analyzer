import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  final String id;
  final String userId;
  final String categoryId; // empty = total monthly budget
  final String categoryName;
  final double limitAmount;
  final double spentAmount;
  final int month; // 1–12
  final int year; // e.g. 2025
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BudgetModel({
    required this.id,
    required this.userId,
    this.categoryId = '',
    this.categoryName = 'Total',
    required this.limitAmount,
    this.spentAmount = 0.0,
    required this.month,
    required this.year,
    required this.createdAt,
    this.updatedAt,
  });

  // ── Helpers ───────────────────────────────────

  double get remaining => limitAmount - spentAmount;
  double get percentage =>
      limitAmount > 0 ? (spentAmount / limitAmount) * 100 : 0;
  bool get isExceeded => spentAmount > limitAmount;
  bool get isWarning => percentage >= 80 && !isExceeded;
  bool get isTotalBudget => categoryId.isEmpty;

  // ── From JSON ─────────────────────────────────

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? 'Total',
      limitAmount: (json['limitAmount'] ?? 0).toDouble(),
      spentAmount: (json['spentAmount'] ?? 0).toDouble(),
      month: json['month'] ?? DateTime.now().month,
      year: json['year'] ?? DateTime.now().year,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'limitAmount': limitAmount,
      'spentAmount': spentAmount,
      'month': month,
      'year': year,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // ── From Firestore ────────────────────────────

  factory BudgetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BudgetModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? 'Total',
      limitAmount: (data['limitAmount'] ?? 0).toDouble(),
      spentAmount: (data['spentAmount'] ?? 0).toDouble(),
      month: data['month'] ?? DateTime.now().month,
      year: data['year'] ?? DateTime.now().year,
      createdAt:
      (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'limitAmount': limitAmount,
      'spentAmount': spentAmount,
      'month': month,
      'year': year,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt':
      updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // ── Copy With ─────────────────────────────────

  BudgetModel copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? categoryName,
    double? limitAmount,
    double? spentAmount,
    int? month,
    int? year,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      limitAmount: limitAmount ?? this.limitAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}