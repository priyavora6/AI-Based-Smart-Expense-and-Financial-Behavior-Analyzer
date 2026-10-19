import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/insights_provider.dart';
import 'insight_list_widgets.dart';

class UnusualSpendingScreen extends StatefulWidget {
  const UnusualSpendingScreen({super.key});

  @override
  State<UnusualSpendingScreen> createState() => _UnusualSpendingScreenState();
}

class _UnusualSpendingScreenState extends State<UnusualSpendingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<InsightsProvider>().generateInsights(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InsightsProvider>();
    final unusual = provider.unusualInsights;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unusual Spending'),
        actions: [
          IconButton(
            onPressed: provider.isLoading
                ? null
                : () => context.read<InsightsProvider>().generateInsights(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.teal))
          : RefreshIndicator(
              onRefresh: context.read<InsightsProvider>().generateInsights,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Card(
                    child: ListTile(
                      leading:
                          Icon(Icons.query_stats, color: AppColors.anomaly),
                      title: Text('Review changes in your routine'),
                      subtitle: Text(
                          'These transactions differ from your usual spending patterns.'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (unusual.isEmpty)
                    const InsightEmptyState(
                      icon: Icons.check_circle_outline,
                      title: 'Nothing unusual detected',
                      message:
                          'Keep tracking transactions to help Neospend learn your normal spending pattern.',
                    )
                  else
                    ...unusual
                        .map((insight) => InsightListCard(insight: insight)),
                ],
              ),
            ),
    );
  }
}
