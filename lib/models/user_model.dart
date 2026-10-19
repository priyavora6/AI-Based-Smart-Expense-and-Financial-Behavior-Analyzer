import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final double monthlyIncome;
  final String currency;
  final String locale;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.monthlyIncome = 0.0,
    this.currency = '₹',
    this.locale = 'en_IN',
    required this.createdAt,
    this.lastLoginAt,
  });

  // ── From JSON (API responses) ─────────────────

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      monthlyIncome: (json['monthlyIncome'] ?? 0).toDouble(),
      currency: json['currency'] ?? '₹',
      locale: json['locale'] ?? 'en_IN',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'monthlyIncome': monthlyIncome,
      'currency': currency,
      'locale': locale,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  // ── From Firestore ────────────────────────────

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      monthlyIncome: (data['monthlyIncome'] ?? 0).toDouble(),
      currency: data['currency'] ?? '₹',
      locale: data['locale'] ?? 'en_IN',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'monthlyIncome': monthlyIncome,
      'currency': currency,
      'locale': locale,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt':
      lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  // ── Copy With ─────────────────────────────────

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    double? monthlyIncome,
    String? currency,
    String? locale,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      currency: currency ?? this.currency,
      locale: locale ?? this.locale,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}