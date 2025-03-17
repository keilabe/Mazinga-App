import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'settings_service.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _currentTheme = ThemeMode.system;

  ThemeMode get currentTheme => _currentTheme; 

  void changeThemeMode(ThemeMode themeMode) {
    _currentTheme = themeMode;
    notifyListeners();
  }

  Future<void> _loadCurrentTheme() async {
    final savedSettings = await SettingsService().getSettings();
    final savedTheme = savedSettings['themeMode'];
    _currentTheme = ThemeMode.values.firstWhere(
      (theme) => theme.toString() == savedTheme,
      orElse: () => ThemeMode.system,
    );
    notifyListeners();
  }

  void toggleTheme() {
    _currentTheme = _currentTheme == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}