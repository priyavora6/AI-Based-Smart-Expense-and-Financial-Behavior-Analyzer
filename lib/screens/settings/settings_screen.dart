import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<SettingsProvider>().loadSettings(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const _SectionTitle('Appearance'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    settings.isDarkMode
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                  ),
                  title: Text(
                    settings.isDarkMode ? 'Dark mode' : 'Light mode',
                  ),
                  subtitle: Text(
                    settings.isDarkMode
                        ? 'Dark theme is enabled'
                        : 'Light theme is enabled',
                  ),
                  value: settings.isDarkMode,
                  onChanged: settings.toggleDarkMode,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  value: settings.notificationsEnabled,
                  onChanged: settings.toggleNotifications,
                ),
              ],
            ),
          ),
          const _SectionTitle('Preferences'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.currency_rupee, color: AppColors.teal),
                  title: const Text('Currency'),
                  trailing: DropdownButton<String>(
                    value: settings.currency,
                    underline: const SizedBox.shrink(),
                    items: const ['₹', '\$', '€', '£']
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) settings.setCurrency(value);
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.language, color: AppColors.teal),
                  title: const Text('Language'),
                  trailing: Text(settings.language),
                  onTap: () => settings.setLanguage('English'),
                ),
              ],
            ),
          ),
          const _SectionTitle('Privacy & security'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.security, color: AppColors.teal),
                  title: const Text('Security'),
                  subtitle: const Text('Protect your account and app access'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.security),
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      const Icon(Icons.lock_outline, color: AppColors.teal),
                  title: const Text('App lock'),
                  subtitle:
                      const Text('Require protection when opening Neospend'),
                  trailing: Switch(
                    value: settings.appLockEnabled,
                    onChanged: settings.toggleAppLock,
                  ),
                ),
              ],
            ),
          ),
          const _SectionTitle('More'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.info_outline, color: AppColors.teal),
                  title: const Text('About Neospend'),
                  subtitle: const Text('Version, features and support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.about),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore, color: AppColors.teal),
                  title: const Text('Reset preferences'),
                  subtitle:
                      const Text('Restore appearance and preference defaults'),
                  onTap: () => _confirmReset(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset preferences?'),
        content: const Text(
          'Your theme, currency, language, notification and app-lock preferences '
          'will be restored to their defaults.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (shouldReset != true || !context.mounted) return;
    await context.read<SettingsProvider>().resetSettings();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferences reset successfully')),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

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
