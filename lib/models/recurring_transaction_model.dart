import 'package:cloud_firestore/cloud_firestore.dart';

class RecurringTransactionModel {
  final String id;
  final String userId;
  final double amount;
  final String description;
  final String categoryId;
  final String categoryName;
  final String type; // 'income' or 'expense'
  final String frequency; // 'daily', 'weekly', 'monthly', 'yearly'
  final String paymentMethod;
  final DateTime nextDueDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RecurringTransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.type,
    this.frequency = 'monthly',
    this.paymentMethod = 'upi',
    required this.nextDueDate,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  // ── Helpers ───────────────────────────────────

  bool get isDueToday {
    final now = DateTime.now();
    return nextDueDate.year == now.year &&
        nextDueDate.month == now.month &&
        nextDueDate.day == now.day;
  }

  bool get isOverdue => nextDueDate.isBefore(DateTime.now());

  int get daysUntilDue => nextDueDate.difference(DateTime.now()).inDays;

  // ── From JSON ─────────────────────────────────

  factory RecurringTransactionModel.fromJson(Map<String, dynamic> json) {
    return RecurringTransactionModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      type: json['type'] ?? 'expense',
      frequency: json['frequency'] ?? 'monthly',
      paymentMethod: json['paymentMethod'] ?? 'upi',
      nextDueDate: json['nextDueDate'] != null
          ? DateTime.parse(json['nextDueDate'])
          : DateTime.now(),
      isActive: json['isActive'] ?? true,
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
      'amount': amount,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'type': type,
      'frequency': frequency,
      'paymentMethod': paymentMethod,
      'nextDueDate': nextDueDate.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // ── From Firestore ────────────────────────────

  factory RecurringTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecurringTransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      type: data['type'] ?? 'expense',
      frequency: data['frequency'] ?? 'monthly',
      paymentMethod: data['paymentMethod'] ?? 'upi',
      nextDueDate:
      (data['nextDueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      createdAt:
      (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'type': type,
      'frequency': frequency,
      'paymentMethod': paymentMethod,
      'nextDueDate': Timestamp.fromDate(nextDueDate),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt':
      updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // ── Copy With ─────────────────────────────────

  RecurringTransactionModel copyWith({
    String? id,
    String? userId,
    double? amount,
    String? description,
    String? categoryId,
    String? categoryName,
    String? type,
    String? frequency,
    String? paymentMethod,
    DateTime? nextDueDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringTransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}