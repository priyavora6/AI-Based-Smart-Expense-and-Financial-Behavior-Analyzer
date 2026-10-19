import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../models/savings_goal_model.dart';
import '../utils/currency_utils.dart';

class SavingsGoalCard extends StatelessWidget {
  final SavingsGoalModel goal;
  final VoidCallback? onTap;

  const SavingsGoalCard({
    super.key,
    required this.goal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = goal.percentage.clamp(0.0, 100.0);
    final isComplete = goal.isCompleted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isComplete ? AppColors.mint : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isComplete ? AppColors.success : AppColors.border,
            width: isComplete ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isComplete ? Icons.celebration : Icons.savings,
                      color: isComplete ? AppColors.success : AppColors.teal,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      goal.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (isComplete)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Done! 🎉',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isComplete ? AppColors.success : AppColors.teal,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${CurrencyUtils.formatCompact(goal.savedAmount)} '
                      'of ${CurrencyUtils.formatCompact(goal.targetAmount)}',
                  style: AppTextStyles.caption,
                ),
                Text(
                  '${goal.daysRemaining > 0 ? goal.daysRemaining : 0} days left',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}