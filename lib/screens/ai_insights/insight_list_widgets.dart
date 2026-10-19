import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/insight_model.dart';

class InsightListCard extends StatelessWidget {
  final InsightModel insight;

  const InsightListCard({required this.insight, super.key});

  @override
  Widget build(BuildContext context) {
    final color = insight.isCritical || insight.isWarning
        ? AppColors.expense
        : AppColors.teal;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
            insight.isCritical || insight.isWarning
                ? Icons.warning_amber_rounded
                : Icons.lightbulb_outline,
            color: color,
          ),
        ),
        title: Text(
          insight.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(insight.message),
        ),
      ),
    );
  }
}

class InsightEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const InsightEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppColors.teal),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
