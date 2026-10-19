import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/analytics_provider.dart';

class IncomeExpenseScreen extends StatefulWidget {
  const IncomeExpenseScreen({super.key});

  @override
  State<IncomeExpenseScreen> createState() => _IncomeExpenseScreenState();
}

class _IncomeExpenseScreenState extends State<IncomeExpenseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AnalyticsProvider>().loadAnalytics(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsProvider>();
    final comparison = analytics.monthlyComparison;
    final current = comparison['current'] as Map<String, dynamic>? ?? const {};
    final income = (current['income'] as num? ?? 0).toDouble();
    final expense = (current['expense'] as num? ?? 0).toDouble();
    final total = income + expense;
    return Scaffold(
      appBar: AppBar(title: const Text('Income vs Expense')),
      body: analytics.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.teal))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text('This month',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 20),
                        _Bar(
                            label: 'Income',
                            value: income,
                            total: total,
                            color: AppColors.income),
                        const SizedBox(height: 16),
                        _Bar(
                            label: 'Expenses',
                            value: expense,
                            total: total,
                            color: AppColors.expense),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('Net balance'),
                  trailing: Text(
                    '₹${(income - expense).toStringAsFixed(0)}',
                    style: TextStyle(
                      color: income >= expense
                          ? AppColors.income
                          : AppColors.expense,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double value;
  final double total;
  final Color color;

  const _Bar({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : (value / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('₹${value.toStringAsFixed(0)}',
                style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: ratio,
          minHeight: 10,
          borderRadius: BorderRadius.circular(8),
          color: color,
          backgroundColor: color.withValues(alpha: 0.12),
        ),
      ],
    );
  }
}
