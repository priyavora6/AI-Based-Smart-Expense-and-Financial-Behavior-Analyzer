import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/insights_provider.dart';
import '../../widgets/custom_bottom_nav.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsightsProvider>().generateInsights();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InsightsProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('AI Insights'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.dashboard,
                (route) => false,
              );
            }
          },
        ),
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
                padding: const EdgeInsets.all(20),
                children: [
                  _InsightHeader(
                    available: provider.isServerAvailable,
                    summary: provider.monthlySummary,
                  ),
                  const SizedBox(height: 16),
                  if (provider.insights.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Add transactions to receive personalised spending insights.',
                        ),
                      ),
                    ),
                  ...provider.insights.map((insight) => Card(
                        child: ListTile(
                          leading: Icon(
                            insight.isWarning
                                ? Icons.warning_amber_rounded
                                : Icons.lightbulb_outline,
                            color: insight.isWarning
                                ? AppColors.expense
                                : AppColors.teal,
                          ),
                          title: Text(insight.title),
                          subtitle: Text(insight.message),
                        ),
                      )),
                ],
              ),
            ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }
}

class _InsightHeader extends StatelessWidget {
  final bool available;
  final String summary;

  const _InsightHeader({required this.available, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.navyDark,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.tealBright),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Your financial picture',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  available ? 'Online' : 'Basic',
                  style: TextStyle(
                    color: available ? AppColors.tealBright : Colors.white70,
                  ),
                ),
              ],
            ),
            if (summary.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(summary, style: const TextStyle(color: Colors.white70)),
            ],
          ],
        ),
      ),
    );
  }
}
