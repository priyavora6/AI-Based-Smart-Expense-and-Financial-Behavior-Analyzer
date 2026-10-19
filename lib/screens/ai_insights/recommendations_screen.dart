import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/insights_provider.dart';
import 'insight_list_widgets.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
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
    final recommendations = provider.insights
        .where((insight) => insight.type == 'recommendation')
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendations'),
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
                  const _InsightIntro(
                    title: 'Suggestions for your money habits',
                    message:
                        'Use these practical suggestions to improve your spending and saving decisions.',
                  ),
                  const SizedBox(height: 12),
                  if (recommendations.isEmpty)
                    const InsightEmptyState(
                      icon: Icons.tips_and_updates_outlined,
                      title: 'No recommendations yet',
                      message:
                          'Add a few transactions and generate insights to receive personalised suggestions.',
                    )
                  else
                    ...recommendations.map(
                      (insight) => InsightListCard(insight: insight),
                    ),
                ],
              ),
            ),
    );
  }
}

class _InsightIntro extends StatelessWidget {
  final String title;
  final String message;

  const _InsightIntro({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.navyDark,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.tealBright),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(message, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
