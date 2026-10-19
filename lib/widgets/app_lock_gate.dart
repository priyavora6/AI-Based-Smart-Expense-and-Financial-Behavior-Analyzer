import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class AppLockGate extends StatefulWidget {
  final Widget child;

  const AppLockGate({required this.child, super.key});

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  bool _locked = false;
  bool _authenticating = false;
  bool _hasEnteredBackground = false;
  bool _hasObservedSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _hasEnteredBackground = true;
    } else if (state == AppLifecycleState.resumed && _hasEnteredBackground) {
      _hasEnteredBackground = false;
      _lockIfRequired();
    }
  }

  Future<void> _lockIfRequired() async {
    if (!mounted || _authenticating) return;
    final settings = context.read<SettingsProvider>();
    final auth = context.read<AuthProvider>();
    if (!settings.isLoaded ||
        !settings.appLockEnabled ||
        !auth.isAuthenticated) {
      return;
    }

    setState(() => _locked = true);
    await _authenticate();
  }

  Future<void> _authenticate() async {
    if (_authenticating || !mounted) return;
    _authenticating = true;

    try {
      final supported = await _localAuthentication.isDeviceSupported();
      if (!supported) {
        _showMessage(
          'Set up fingerprint, Face ID, or a device screen lock to use App Lock.',
        );
        if (mounted) setState(() => _locked = false);
        return;
      }

      final authenticated = await _localAuthentication.authenticate(
        localizedReason: 'Unlock NeoSpend to view your financial information',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      if (authenticated && mounted) {
        setState(() => _locked = false);
      }
    } on PlatformException catch (error) {
      if (error.code == 'NotEnrolled' ||
          error.code == 'NotAvailable' ||
          error.code == 'noBiometricHardware' ||
          error.code == 'noBiometrics') {
        _showMessage(
          'No biometric or device screen lock is available. App Lock remains active.',
        );
      }
    } catch (error) {
      debugPrint('App lock authentication failed: $error');
    } finally {
      _authenticating = false;
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    if (!settings.isLoaded) {
      return widget.child;
    }

    final firstSettingsBuild = !_hasObservedSettings;
    _hasObservedSettings = true;
    if (!settings.appLockEnabled) {
      return widget.child;
    }

    final auth = context.watch<AuthProvider>();

    if (firstSettingsBuild && auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _lockIfRequired());
    }

    return Stack(
      children: [
        widget.child,
        if (_locked)
          Positioned.fill(
            child: AbsorbPointer(
              child: ColoredBox(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline, size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'NeoSpend is locked',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _authenticating ? null : _authenticate,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Unlock'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
