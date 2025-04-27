import 'package:flutter/material.dart';
import 'package:mi_garaje/shared/themes/app_themes.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeData _currentTheme;

  ThemeNotifier(this._currentTheme);

  ThemeData get currentTheme => _currentTheme;

  void toggleTheme() {
    _currentTheme = isLightTheme() ? AppThemes.darkTheme : AppThemes.lightTheme;
    notifyListeners();
  }

  bool isLightTheme() {
    return _currentTheme == AppThemes.lightTheme;
  }
}
