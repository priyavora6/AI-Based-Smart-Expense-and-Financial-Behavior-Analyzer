import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/settings_provider.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.mint,
                    child: const Icon(
                      Icons.verified_user_outlined,
                      color: AppColors.teal,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Your account is protected by Firebase Authentication.',
                      style: TextStyle(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const _SecuritySectionTitle('App protection'),
          Card(
            child: Consumer<SettingsProvider>(
              builder: (context, settings, child) => SwitchListTile(
                secondary: const Icon(
                  Icons.lock_outline,
                  color: AppColors.teal,
                ),
                title: const Text('App lock'),
                subtitle: const Text(
                  'Keep your financial information private on this device',
                ),
                value: settings.appLockEnabled,
                onChanged: (value) async {
                  if (!value) {
                    await settings.toggleAppLock(false);
                    return;
                  }

                  final authenticated =
                      await LocalAuthentication().authenticate(
                    localizedReason:
                        'Confirm your identity to enable NeoSpend App Lock',
                    options: const AuthenticationOptions(
                      biometricOnly: false,
                      stickyAuth: true,
                      useErrorDialogs: true,
                    ),
                  );
                  if (authenticated) {
                    await settings.toggleAppLock(true);
                  }
                },
              ),
            ),
          ),
          const _SecuritySectionTitle('Account'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.password, color: AppColors.teal),
                  title: const Text('Change password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.forgotPassword),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.shield_outlined, color: AppColors.teal),
                  title: Text('Data protection'),
                  subtitle: Text(
                    'Neospend does not display your password or store it locally.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'For your safety, never share your password or verification codes '
            'with anyone.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _SecuritySectionTitle extends StatelessWidget {
  final String title;

  const _SecuritySectionTitle(this.title);

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
