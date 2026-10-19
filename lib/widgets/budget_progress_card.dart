import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../models/budget_model.dart';
import '../utils/currency_utils.dart';

class BudgetProgressCard extends StatelessWidget {
  final BudgetModel budget;
  final VoidCallback? onTap;

  const BudgetProgressCard({
    super.key,
    required this.budget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = budget.percentage.clamp(0.0, 100.0);
    final color = budget.isExceeded
        ? AppColors.expense
        : budget.isWarning
        ? AppColors.warning
        : AppColors.teal;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  budget.categoryName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: AppTextStyles.label.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent: ${CurrencyUtils.formatCompact(budget.spentAmount)}',
                  style: AppTextStyles.caption,
                ),
                Text(
                  'Limit: ${CurrencyUtils.formatCompact(budget.limitAmount)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            if (budget.isExceeded)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '⚠️ Exceeded by ${CurrencyUtils.formatCompact(budget.remaining.abs())}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.expense,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}