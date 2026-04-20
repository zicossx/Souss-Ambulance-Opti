import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  String _languageCode = 'en';
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = true;

  String get languageCode => _languageCode;
  ThemeMode get themeMode => _themeMode;
  bool get isArabic => _languageCode == 'ar';
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _languageCode = prefs.getString('language') ?? 'en';
      final themeIndex = prefs.getInt('theme');
      if (themeIndex != null && themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[themeIndex];
      }
    } catch (e) {
      print('SharedPreferences error: $e');
      // Keep defaults
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', code);
    } catch (e) {
      print('Error saving language: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme', mode.index);
    } catch (e) {
      print('Error saving theme: $e');
    }
  }

  void toggleLanguage() {
    setLanguage(_languageCode == 'en' ? 'ar' : 'en');
  }
}