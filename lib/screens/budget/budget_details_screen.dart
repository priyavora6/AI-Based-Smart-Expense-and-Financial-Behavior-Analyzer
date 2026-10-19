import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../models/budget_model.dart';
import '../../providers/budget_provider.dart';

class BudgetDetailsScreen extends StatelessWidget {
  const BudgetDetailsScreen({super.key});

  String _formatCurrency(double amount) {
    return '₹${NumberFormat('#,##,##0', 'en_IN').format(amount)}';
  }

  String _getMonthName(int month) {
    return DateFormat('MMMM').format(DateTime(2024, month));
  }

  @override
  Widget build(BuildContext context) {
    final budget = ModalRoute.of(context)!.settings.arguments as BudgetModel;
    final progress = budget.limitAmount == 0
        ? 0.0
        : (budget.spentAmount / budget.limitAmount).clamp(0.0, 1.0);
    final remaining = budget.remaining;
    final isOver = budget.isExceeded;
    final progressColor = isOver
        ? AppColors.expense
        : progress > 0.8
            ? AppColors.warning
            : AppColors.success;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.dashboard,
            (route) => false,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.navyDark, size: 20),
        ),
        title: const Text('Budget Details',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.navyDark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Hero card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.navyDark,
                    AppColors.primary,
                    AppColors.navyLight
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.navyDark.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8))
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getCategoryIcon(budget.categoryName),
                        color: Colors.white, size: 34),
                  ),
                  const SizedBox(height: 14),
                  Text(budget.categoryName,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 6),
                  Text('${_getMonthName(budget.month)} ${budget.year}',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                          letterSpacing: 0.5)),
                  const SizedBox(height: 24),

                  // Circular Progress
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 12,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(progressColor),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${(progress * 100).toInt()}%',
                                style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                            Text('Used',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.6))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats
            Row(
              children: [
                Expanded(
                    child: _buildStatCard(
                        'Limit', budget.limitAmount, AppColors.teal)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildStatCard(
                        'Spent', budget.spentAmount, AppColors.expense)),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatCard(isOver ? 'Over Budget' : 'Remaining',
                remaining.abs(), isOver ? AppColors.expense : AppColors.success,
                fullWidth: true),

            const SizedBox(height: 32),

            // Delete button
            GestureDetector(
              onTap: () => _confirmDelete(context, budget.id),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.expense.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.expense.withOpacity(0.3)),
                ),
                child: const Center(
                  child: Text('Delete Budget',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.expense,
                          letterSpacing: 0.5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, double amount, Color color,
      {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(_formatCurrency(amount),
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Budget'),
        content: const Text('Are you sure you want to delete this budget?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.secondaryText))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider =
                  Provider.of<BudgetProvider>(context, listen: false);
              await provider.deleteBudget(id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: AppColors.expense, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'bills':
        return Icons.receipt_rounded;
      case 'health':
        return Icons.local_hospital_rounded;
      case 'education':
        return Icons.school_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
