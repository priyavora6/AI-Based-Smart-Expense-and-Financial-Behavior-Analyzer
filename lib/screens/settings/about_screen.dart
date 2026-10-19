import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Image.asset('assets/logo.png', height: 76, width: 220),
                  const SizedBox(height: 16),
                  const Text(
                    'Neospend',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Smart spending. Better decisions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const _AboutSectionTitle('About the app'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.insights_outlined, color: AppColors.teal),
                  title: Text('Understand your spending'),
                  subtitle: Text(
                    'Track transactions, budgets, savings and financial trends in one place.',
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading:
                      Icon(Icons.auto_awesome_outlined, color: AppColors.teal),
                  title: Text('Make informed decisions'),
                  subtitle: Text(
                    'Use insights and reports to build healthier money habits.',
                  ),
                ),
              ],
            ),
          ),
          const _AboutSectionTitle('Information'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.help_outline, color: AppColors.teal),
                  title: const Text('Help & support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showInfoDialog(
                    context,
                    'Help & support',
                    'For account or app support, contact the Neospend support '
                        'team through the email associated with your account.',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined,
                      color: AppColors.teal),
                  title: const Text('Privacy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showInfoDialog(
                    context,
                    'Privacy',
                    'Your financial data is used to provide the features you '
                        'request. Keep your account credentials private and use '
                        'the Security section to protect access to the app.',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined,
                      color: AppColors.teal),
                  title: const Text('Terms of use'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showInfoDialog(
                    context,
                    'Terms of use',
                    'Neospend is a personal finance tracking tool. Its insights '
                        'are informational and are not financial advice.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Made to help you spend with confidence.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _AboutSectionTitle extends StatelessWidget {
  final String title;

  const _AboutSectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.secondaryText,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
