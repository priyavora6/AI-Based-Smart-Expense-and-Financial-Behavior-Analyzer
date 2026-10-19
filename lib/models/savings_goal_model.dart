import 'package:cloud_firestore/cloud_firestore.dart';

class SavingsGoalModel {
  final String id;
  final String userId;
  final String name; // e.g. "New Laptop"
  final String? icon;
  final double targetAmount;
  final double savedAmount;
  final DateTime targetDate;
  final String status; // 'active', 'completed', 'paused'
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SavingsGoalModel({
    required this.id,
    required this.userId,
    required this.name,
    this.icon,
    required this.targetAmount,
    this.savedAmount = 0.0,
    required this.targetDate,
    this.status = 'active',
    required this.createdAt,
    this.updatedAt,
  });

  // ── Helpers ───────────────────────────────────

  double get remaining => targetAmount - savedAmount;
  double get percentage =>
      targetAmount > 0 ? (savedAmount / targetAmount) * 100 : 0;
  bool get isCompleted => savedAmount >= targetAmount;

  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;

  /// How much to save per month to reach the goal on time.
  double get monthlyRequired {
    final months = daysRemaining / 30;
    if (months <= 0) return remaining;
    return remaining / months;
  }

  // ── From JSON ─────────────────────────────────

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
      targetAmount: (json['targetAmount'] ?? 0).toDouble(),
      savedAmount: (json['savedAmount'] ?? 0).toDouble(),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'])
          : DateTime.now().add(const Duration(days: 180)),
      status: json['status'] ?? 'active',
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
      'name': name,
      'icon': icon,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'targetDate': targetDate.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // ── From Firestore ────────────────────────────

  factory SavingsGoalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavingsGoalModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      icon: data['icon'],
      targetAmount: (data['targetAmount'] ?? 0).toDouble(),
      savedAmount: (data['savedAmount'] ?? 0).toDouble(),
      targetDate: (data['targetDate'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 180)),
      status: data['status'] ?? 'active',
      createdAt:
      (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'icon': icon,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'targetDate': Timestamp.fromDate(targetDate),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt':
      updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // ── Copy With ─────────────────────────────────

  SavingsGoalModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? icon,
    double? targetAmount,
    double? savedAmount,
    DateTime? targetDate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingsGoalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}