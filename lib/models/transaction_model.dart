import 'package:cloud_firestore/cloud_firestore.dart';

/// The most important model in the app.
/// Every income and expense is a TransactionModel.
class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final String description;
  final String categoryId;
  final String categoryName;
  final String type; // 'income' or 'expense'
  final String paymentMethod; // 'cash', 'upi', 'debit_card', 'credit_card'
  final DateTime date;
  final bool isRecurring;
  final bool isAnomaly;
  final String? anomalyReason;
  final String? mlPredictedCategory;
  final double? mlConfidence;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.type,
    this.paymentMethod = 'cash',
    required this.date,
    this.isRecurring = false,
    this.isAnomaly = false,
    this.anomalyReason,
    this.mlPredictedCategory,
    this.mlConfidence,
    required this.createdAt,
    this.updatedAt,
  });

  // ── Helpers ───────────────────────────────────

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
  String get category => categoryName;
  String get title => description;
  String get notes => description;

  /// Returns +amount for income, -amount for expense.
  double get signedAmount => isIncome ? amount : -amount;

  // ── From JSON ─────────────────────────────────

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      type: json['type'] ?? 'expense',
      paymentMethod: json['paymentMethod'] ?? 'cash',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      isRecurring: json['isRecurring'] ?? false,
      isAnomaly: json['isAnomaly'] ?? false,
      anomalyReason: json['anomalyReason'],
      mlPredictedCategory: json['mlPredictedCategory'],
      mlConfidence: json['mlConfidence']?.toDouble(),
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
      'paymentMethod': paymentMethod,
      'date': date.toIso8601String(),
      'isRecurring': isRecurring,
      'isAnomaly': isAnomaly,
      'anomalyReason': anomalyReason,
      'mlPredictedCategory': mlPredictedCategory,
      'mlConfidence': mlConfidence,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // ── From Firestore ────────────────────────────

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      type: data['type'] ?? 'expense',
      paymentMethod: data['paymentMethod'] ?? 'cash',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRecurring: data['isRecurring'] ?? false,
      isAnomaly: data['isAnomaly'] ?? false,
      anomalyReason: data['anomalyReason'],
      mlPredictedCategory: data['mlPredictedCategory'],
      mlConfidence: data['mlConfidence']?.toDouble(),
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
      'paymentMethod': paymentMethod,
      'date': Timestamp.fromDate(date),
      'isRecurring': isRecurring,
      'isAnomaly': isAnomaly,
      'anomalyReason': anomalyReason,
      'mlPredictedCategory': mlPredictedCategory,
      'mlConfidence': mlConfidence,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt':
      updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // ── Copy With ─────────────────────────────────

  TransactionModel copyWith({
    String? id,
    String? userId,
    double? amount,
    String? description,
    String? categoryId,
    String? categoryName,
    String? type,
    String? paymentMethod,
    DateTime? date,
    bool? isRecurring,
    bool? isAnomaly,
    String? anomalyReason,
    String? mlPredictedCategory,
    double? mlConfidence,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? category,
    String? title,
    String? notes,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      description: description ?? title ?? notes ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? category ?? this.categoryName,
      type: type ?? this.type,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
      isAnomaly: isAnomaly ?? this.isAnomaly,
      anomalyReason: anomalyReason ?? this.anomalyReason,
      mlPredictedCategory: mlPredictedCategory ?? this.mlPredictedCategory,
      mlConfidence: mlConfidence ?? this.mlConfidence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}