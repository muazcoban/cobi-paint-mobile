import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';

  Locale _locale = const Locale('tr'); // Default Turkish

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);
    if (localeCode != null) {
      _locale = Locale(localeCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('tr'), // Turkish
    Locale('en'), // English
  ];

  // Get language name for display
  String getLanguageName(String code) {
    switch (code) {
      case 'tr':
        return 'Turkce';
      case 'en':
        return 'English';
      default:
        return code;
    }
  }

  // Get flag emoji for language
  String getLanguageFlag(String code) {
    switch (code) {
      case 'tr':
        return '🇹🇷';
      case 'en':
        return '🇺🇸';
      default:
        return '🌐';
    }
  }
}
