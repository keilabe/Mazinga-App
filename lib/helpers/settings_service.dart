import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SettingsService {
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyUnitPreference = 'unit_preference';
  static const String _keyLengthPreference = 'length_preference';
  static const String _keyThemeMode = 'theme_mode';

  Future<void> saveSettings({
    bool? notificationsEnabled,
    String? unitPreference,
    String? lengthPreference,
    ThemeMode? themeMode,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (notificationsEnabled != null) {
      await prefs.setBool(_keyNotifications, notificationsEnabled);
    }
    if (unitPreference != null) {
      await prefs.setString(_keyUnitPreference, unitPreference);
    }
    if (lengthPreference != null) {
      await prefs.setString(_keyLengthPreference, lengthPreference);
    }
    if (themeMode != null) {
      await prefs.setString(_keyThemeMode, themeMode.toString());
    }
  }

  Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'notificationsEnabled': prefs.getBool(_keyNotifications) ?? true,
      'unitPreference': prefs.getString(_keyUnitPreference) ?? 'kg',
      'lengthPreference': prefs.getString(_keyLengthPreference) ?? 'cm',
      'themeMode': prefs.getString(_keyThemeMode) ?? ThemeMode.system.toString(),
    };
  }

  Future<void> saveNotifications(bool enabled) async {
    await saveSettings(notificationsEnabled: enabled);
  }

  Future<void> saveUnitPreference(String unit) async {
    await saveSettings(unitPreference: unit);
  }

  Future<void> saveLengthPreference(String length) async {
    await saveSettings(lengthPreference: length);
  }

  Future<void> saveTheme(ThemeMode themeMode) async {
    await saveSettings(themeMode: themeMode);
  }
}