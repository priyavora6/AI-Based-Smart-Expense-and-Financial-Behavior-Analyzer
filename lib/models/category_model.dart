import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String type; // 'income', 'expense', or 'both'
  final int colorValue;
  final DateTime createdAt;
  final bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    required this.colorValue,
    required this.createdAt,
    this.isDefault = false,
  });

  String get color => '#${colorValue.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  static final List<CategoryModel> defaultCategories = [
    CategoryModel(id: '', name: 'Food', icon: 'restaurant', type: 'expense', colorValue: 0xFFF97316, createdAt: DateTime.now(), isDefault: true),
    CategoryModel(id: '', name: 'Groceries', icon: 'groceries', type: 'expense', colorValue: 0xFF84CC16, createdAt: DateTime.now(), isDefault: true),
    CategoryModel(id: '', name: 'Dining Out', icon: 'dining', type: 'expense', colorValue: 0xFFF59E0B, createdAt: DateTime.now(), isDefault: true),
    CategoryModel(id: '', name: 'Transport', icon: 'car', type: 'expense', colorValue: 0xFF3B82F6, createdAt: DateTime.now(), isDefault: true),
    CategoryModel(id: '', name: 'Fuel', icon: 'fuel', type: 'expense', colorValue: 0xFF0EA5E9, createdAt: DateTime.now(), isDefault: true),
    CategoryModel(id: '', name: 'Travel', icon: 'travel', type: 'expense', colorValue: 0xFF06B6D4, createdAt: DateTime.now(), isDefault: true),
    CategoryModel(id: '', name: 'Shopping', icon: 'shopping', type: 'expense', colorValue: 0xFFEC4899, createdAt: DateTime.now(), isDefault: true),
    CategoryModel(id: '', name: 'Clothing', icon: 'clothing', type: 'expense', colorValue: 0xFFD946EF, createdAt: DateTime.now(), isDefault: true),
    CategoryModel(id: '', name: 'Bills', icon: 'bills', type: 'expense', colorValue: 0xFFEAB308, createdAt: DateTime.now(), isDefault: true),
    CategoryModel(id: '', name: 'Rent', icon: 'rent', type: 'expense', colorValue: 0xFFF97316, createdAt: DateTime.now(), isDefault: true),
    CategoryModel(id: '', name: 'Utilities', icon: 'utilities', type: 'expense', colorValue: 0xFFEAB308, createdAt: DateTime.now(), isDefault: true),
    CategoryModel(id: '', name: 'Health', icon: 'health', type: 'expense', colorValue: 0xFFEF4444, createdAt: DateTime.now(), isDefault: true),
    CategoryModel(id: '', name: 'Education', icon: 'education', type: 'expense', colorValue: 0xFF8B5CF6, createdAt: DateTime.now(), isDefault: true),
    CategoryModel(id: '', name: 'Entertainment', icon: 'entertainment', type: 'expense', colorValue: 0xFFA855F7, createdAt: DateTime.now(), isDefault: true),
    CategoryModel(id: '', name: 'Subscriptions', icon: 'subscriptions', type: 'expense', colorValue: 0xFF6366F1, createdAt: DateTime.now(), isDefault: true),
    CategoryModel(id: '', name: 'Personal Care', icon: 'personal_care', type: 'expense', colorValue: 0xFF14B8A6, createdAt: DateTime.now(), isDefault: true),
    CategoryModel(id: '', name: 'Gifts', icon: 'gifts', type: 'expense', colorValue: 0xFFEC4899, createdAt: DateTime.now(), isDefault: true),
    CategoryModel(id: '', name: 'Insurance', icon: 'insurance', type: 'expense', colorValue: 0xFF64748B, createdAt: DateTime.now(), isDefault: true),
    CategoryModel(id: '', name: 'Taxes', icon: 'taxes', type: 'expense', colorValue: 0xFF475569, createdAt: DateTime.now(), isDefault: true),
    CategoryModel(id: '', name: 'Other Expense', icon: 'other', type: 'expense', colorValue: 0xFF94A3B8, createdAt: DateTime.now(), isDefault: true),
    CategoryModel(id: '', name: 'Salary', icon: 'salary', type: 'income', colorValue: 0xFF10B981, createdAt: DateTime.now(), isDefault: true),
    CategoryModel(id: '', name: 'Freelance', icon: 'freelance', type: 'income', colorValue: 0xFF22C55E, createdAt: DateTime.now(), isDefault: true),
    CategoryModel(id: '', name: 'Investment', icon: 'investment', type: 'income', colorValue: 0xFF16A34A, createdAt: DateTime.now(), isDefault: true),
    CategoryModel(id: '', name: 'Gift Income', icon: 'gift_income', type: 'income', colorValue: 0xFF10B981, createdAt: DateTime.now(), isDefault: true),
  ];

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      type: map['type'] ?? 'expense',
      colorValue: map['colorValue'] is String
          ? int.tryParse(map['colorValue'].replaceFirst('#', '0x')) ?? 0xFF000000
          : map['colorValue'] ?? 0xFF000000,
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt']
          : map['createdAt'] != null
          ? DateTime.parse(map['createdAt'].toString())
          : DateTime.now(),
      isDefault: map['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'type': type,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
      'isDefault': isDefault,
    };
  }

  factory CategoryModel.fromFirestore(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    final createdAt = data['createdAt'];
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      type: data['type'] ?? 'expense',
      colorValue: data['colorValue'] is String
          ? int.tryParse(data['colorValue'].replaceFirst('#', '0x')) ?? 0xFF000000
          : data['colorValue'] ?? 0xFF000000,
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : createdAt is DateTime
          ? createdAt
          : createdAt != null
          ? DateTime.parse(createdAt.toString())
          : DateTime.now(),
      isDefault: data['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => toMap();

  CategoryModel copyWith({
    String? name,
    String? icon,
    String? type,
    int? colorValue,
    DateTime? createdAt,
    bool? isDefault,
  }) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
