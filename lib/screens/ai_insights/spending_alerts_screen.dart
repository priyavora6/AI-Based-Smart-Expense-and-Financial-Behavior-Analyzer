import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/insights_provider.dart';
import 'insight_list_widgets.dart';

class SpendingAlertsScreen extends StatefulWidget {
  const SpendingAlertsScreen({super.key});

  @override
  State<SpendingAlertsScreen> createState() => _SpendingAlertsScreenState();
}

class _SpendingAlertsScreenState extends State<SpendingAlertsScreen> {
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
    final alerts = provider.insights
        .where((insight) =>
            insight.type == 'budget_alert' ||
            insight.isWarning ||
            insight.isCritical)
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Alerts'),
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
                      leading: Icon(Icons.notifications_active_outlined,
                          color: AppColors.warning),
                      title: Text('Stay ahead of your spending'),
                      subtitle: Text(
                          'Alerts highlight budget pressure and activity that may need your attention.'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (alerts.isEmpty)
                    const InsightEmptyState(
                      icon: Icons.check_circle_outline,
                      title: 'No active alerts',
                      message:
                          'Your current insights do not show any spending alerts.',
                    )
                  else
                    ...alerts
                        .map((insight) => InsightListCard(insight: insight)),
                ],
              ),
            ),
    );
  }
}
