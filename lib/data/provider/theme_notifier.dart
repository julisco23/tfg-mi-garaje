import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends AsyncNotifier<ThemeMode> {
  late SharedPreferences _prefs;

  @override
  Future<ThemeMode> build() async {
    _prefs = await SharedPreferences.getInstance();

    return switch (_prefs.getString('themeMode')) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    state = AsyncValue.data(mode);
    await _prefs.setString('themeMode', mode.name);
  }

  Future<void> setSystemMode() async {
    await setMode(ThemeMode.system);
  }

  Future<void> setLightMode() async {
    await setMode(ThemeMode.light);
  }

  Future<void> setDarkMode() async {
    await setMode(ThemeMode.dark);
  }
}

final themeProvider =
    AsyncNotifierProvider<ThemeNotifier, ThemeMode>(() => ThemeNotifier());
