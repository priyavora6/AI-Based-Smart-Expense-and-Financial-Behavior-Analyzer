import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/analytics_provider.dart';

class CategoryBreakdownScreen extends StatefulWidget {
  const CategoryBreakdownScreen({super.key});

  @override
  State<CategoryBreakdownScreen> createState() =>
      _CategoryBreakdownScreenState();
}

class _CategoryBreakdownScreenState extends State<CategoryBreakdownScreen> {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Category Breakdown')),
      body: analytics.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.teal))
          : analytics.categoryBreakdown.isEmpty
              ? const Center(child: Text('No category spending this month.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: analytics.categoryBreakdown.length,
                  itemBuilder: (context, index) {
                    final item = analytics.categoryBreakdown[index];
                    final amount = (item['amount'] as num? ?? 0).toDouble();
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.mint,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(item['category']?.toString() ?? 'Other'),
                        trailing: Text('₹${amount.toStringAsFixed(0)}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    );
                  },
                ),
    );
  }
}
