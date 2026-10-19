import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/analytics_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AnalyticsProvider>().loadAnalytics(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();
    final comparison = provider.monthlyComparison;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Analytics')),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.teal))
          : RefreshIndicator(
              onRefresh: context.read<AnalyticsProvider>().loadAnalytics,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      _MetricCard(
                        label: 'Average daily',
                        value:
                            '₹${provider.avgDailySpending.toStringAsFixed(0)}',
                      ),
                      const SizedBox(width: 12),
                      _MetricCard(
                        label: 'Top category',
                        value: provider.highestCategory,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Monthly comparison',
                    child: Text(
                      'Income: ₹${((comparison['current'] as Map<String, dynamic>?)?['income'] ?? 0).toStringAsFixed(0)}\n'
                      'Expenses: ₹${((comparison['current'] as Map<String, dynamic>?)?['expense'] ?? 0).toStringAsFixed(0)}',
                    ),
                  ),
                  _SectionCard(
                    title: 'Category breakdown',
                    child: provider.categoryBreakdown.isEmpty
                        ? const Text('No spending data for this month.')
                        : Column(
                            children: provider.categoryBreakdown.map((item) {
                              final name = item['category'] ?? 'Other';
                              final amount = item['amount'] ?? 0;
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(name.toString()),
                                trailing: Text(
                                  '₹${(amount as num).toStringAsFixed(0)}',
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
