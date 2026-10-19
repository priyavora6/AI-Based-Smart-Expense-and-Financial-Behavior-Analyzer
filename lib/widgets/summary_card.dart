import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../utils/currency_utils.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final bool showSign;
  final String? percentageChange;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    this.showSign = false,
    this.percentageChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.label),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            showSign
                ? CurrencyUtils.formatWithSign(amount, title.toLowerCase())
                : CurrencyUtils.formatCompact(amount),
            style: AppTextStyles.moneyMedium,
          ),
          if (percentageChange != null) ...[
            const SizedBox(height: 4),
            Text(
              percentageChange!,
              style: AppTextStyles.caption.copyWith(
                color: percentageChange!.startsWith('+')
                    ? AppColors.expense
                    : AppColors.success,
              ),
            ),
          ],
        ],
      ),
    );
  }
}