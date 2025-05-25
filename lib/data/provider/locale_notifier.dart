import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends ChangeNotifier {
  static const _localeKey = 'locale';
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  LocaleNotifier() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);
    if (localeCode != null) {
      _currentLocale = Locale(localeCode);
      notifyListeners();
    }
  }

  Future<void> changeLocale(Locale locale) async {
    if (locale != _currentLocale) {
      _currentLocale = locale;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
      notifyListeners();
    }
  }
}
