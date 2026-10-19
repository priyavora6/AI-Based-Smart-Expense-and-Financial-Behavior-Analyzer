import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/analytics_provider.dart';

class SpendingTrendsScreen extends StatefulWidget {
  const SpendingTrendsScreen({super.key});

  @override
  State<SpendingTrendsScreen> createState() => _SpendingTrendsScreenState();
}

class _SpendingTrendsScreenState extends State<SpendingTrendsScreen> {
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
    final previous =
        comparison['previous'] as Map<String, dynamic>? ?? const {};
    final expenseChange =
        (comparison['expenseChangePercent'] as num? ?? 0).toDouble();
    return Scaffold(
      appBar: AppBar(title: const Text('Spending Trends')),
      body: analytics.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.teal))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _TrendCard(
                  icon: expenseChange > 0
                      ? Icons.trending_up
                      : Icons.trending_down,
                  title: 'Current month',
                  message: expenseChange == 0
                      ? 'No expense change compared with last month.'
                      : '${expenseChange.abs().toStringAsFixed(1)}% '
                          '${expenseChange > 0 ? 'higher' : 'lower'} expenses '
                          'than last month.',
                ),
                const SizedBox(height: 12),
                _ValueCard(
                  title: 'Income',
                  value:
                      '₹${(current['income'] as num? ?? 0).toStringAsFixed(0)}',
                  color: AppColors.income,
                ),
                _ValueCard(
                  title: 'Expenses',
                  value:
                      '₹${(current['expense'] as num? ?? 0).toStringAsFixed(0)}',
                  color: AppColors.expense,
                ),
                _ValueCard(
                  title: 'Previous expenses',
                  value:
                      '₹${(previous['expense'] as num? ?? 0).toStringAsFixed(0)}',
                  color: AppColors.secondaryText,
                ),
                _ValueCard(
                  title: 'Average per day',
                  value: '₹${analytics.avgDailySpending.toStringAsFixed(0)}',
                  color: AppColors.teal,
                ),
              ],
            ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _TrendCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.trending_up, color: AppColors.teal),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(message),
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _ValueCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
