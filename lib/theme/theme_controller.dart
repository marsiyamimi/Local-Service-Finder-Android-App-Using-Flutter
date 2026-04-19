import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

class ThemeController extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _colorKey = 'primary_color';

  ThemeMode _themeMode = ThemeMode.light;
  Color _primaryColor = AppColors.primaryBlue;

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  bool get isDark => _themeMode == ThemeMode.dark;

  final List<Map<String, dynamic>> colorOptions = [
    {'name': 'Blue', 'color': AppColors.primaryBlue, 'value': 0xFF2563EB},
    {'name': 'Purple', 'color': AppColors.primaryDeepPurple, 'value': 0xFF7C3AED},
    {'name': 'Green', 'color': AppColors.primaryGreen, 'value': 0xFF059669},
    {'name': 'Red', 'color': AppColors.primaryRed, 'value': 0xFFDC2626},
    {'name': 'Orange', 'color': AppColors.primaryOrange, 'value': 0xFFEA580C},
  ];

  ThemeController() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_themeModeKey);
    final savedColor = prefs.getInt(_colorKey);

    if (savedMode == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }

    if (savedColor != null) {
      _primaryColor = Color(savedColor);
    }

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorKey, color.value);
    notifyListeners();
  }
}
