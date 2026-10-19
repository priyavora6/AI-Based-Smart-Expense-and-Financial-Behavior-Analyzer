import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/local_notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _currency = '₹';
  String _language = 'English';
  bool _notificationsEnabled = true;
  bool _appLockEnabled = false;
  bool _isLoaded = false;

  SettingsProvider() {
    loadSettings();
  }

  // ── Getters ───────────────────────────────────

  bool get isDarkMode => _isDarkMode;
  String get currency => _currency;
  String get language => _language;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get appLockEnabled => _appLockEnabled;
  bool get isLoaded => _isLoaded;

  // ── Load Settings from Local Storage ──────────

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _isDarkMode = prefs.getBool('darkMode') ?? false;
    _currency = prefs.getString('currency') ?? '₹';
    _language = prefs.getString('language') ?? 'English';
    _notificationsEnabled = prefs.getBool('notifications') ?? true;
    _appLockEnabled = prefs.getBool('appLock') ?? false;
    _isLoaded = true;

    notifyListeners();
  }

  // ── Toggle Dark Mode ──────────────────────────

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }

  // ── Set Currency ──────────────────────────────

  Future<void> setCurrency(String value) async {
    _currency = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', value);
  }

  // ── Set Language ──────────────────────────────

  Future<void> setLanguage(String value) async {
    _language = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
  }

  // ── Toggle Notifications ──────────────────────

  Future<void> toggleNotifications(bool value) async {
    if (value) {
      await LocalNotificationService.instance.requestPermission();
    }
    _notificationsEnabled = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
  }

  Future<void> toggleAppLock(bool value) async {
    _appLockEnabled = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('appLock', value);
  }

  Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('darkMode');
    await prefs.remove('currency');
    await prefs.remove('language');
    await prefs.remove('notifications');
    await prefs.remove('appLock');

    _isDarkMode = false;
    _currency = '₹';
    _language = 'English';
    _notificationsEnabled = true;
    _appLockEnabled = false;
    notifyListeners();
  }
}
