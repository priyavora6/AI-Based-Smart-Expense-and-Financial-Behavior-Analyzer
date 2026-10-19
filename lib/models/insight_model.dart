/// Stores AI-generated financial insights from Gemini API
/// and ML model results.
class InsightModel {
  final String id;
  final String userId;
  final String type;
  // Types: 'monthly_summary', 'unusual_spending',
  //        'budget_alert', 'recommendation', 'forecast'
  final String title;
  final String message;
  final String? category; // related category, if any
  final double? amount; // related amount, if any
  final String severity; // 'info', 'warning', 'critical', 'success'
  final bool isRead;
  final DateTime createdAt;

  const InsightModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.category,
    this.amount,
    this.severity = 'info',
    this.isRead = false,
    required this.createdAt,
  });

  // ── Helpers ───────────────────────────────────

  bool get isWarning => severity == 'warning';
  bool get isCritical => severity == 'critical';
  bool get isUnusual => type == 'unusual_spending';
  bool get isForecast => type == 'forecast';

  // ── From JSON ─────────────────────────────────

  factory InsightModel.fromJson(Map<String, dynamic> json) {
    return InsightModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? 'monthly_summary',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      category: json['category'],
      amount: json['amount']?.toDouble(),
      severity: json['severity'] ?? 'info',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'category': category,
      'amount': amount,
      'severity': severity,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ── Copy With ─────────────────────────────────

  InsightModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? message,
    String? category,
    double? amount,
    String? severity,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return InsightModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      severity: severity ?? this.severity,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}