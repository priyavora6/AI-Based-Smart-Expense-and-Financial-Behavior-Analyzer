import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.assessment_outlined,
                      color: AppColors.teal, size: 32),
                  SizedBox(height: 12),
                  Text('Understand your money',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                  SizedBox(height: 6),
                  Text(
                      'Generate a clear summary of your income, expenses and categories.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month, color: AppColors.teal),
              title: const Text('Monthly report'),
              subtitle: const Text('Review this month’s financial activity'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, AppRoutes.exportReport),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.file_download_outlined,
                  color: AppColors.teal),
              title: const Text('Export data'),
              subtitle: const Text('Share your report as CSV or JSON'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, AppRoutes.exportReport),
            ),
          ),
        ],
      ),
    );
  }
}
