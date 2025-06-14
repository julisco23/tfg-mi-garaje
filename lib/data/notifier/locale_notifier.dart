import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends AsyncNotifier<Locale> {
  static const _localeKey = 'locale';
  late SharedPreferences _prefs;

  @override
  Future<Locale> build() async {
    _prefs = await SharedPreferences.getInstance();

    return switch (_prefs.getString(_localeKey)) {
      'es' => const Locale('es'),
      'en' => const Locale('en'),
      _ => const Locale('es'),
    };
  }

  Future<void> changeLocale(Locale locale) async {
    await _prefs.setString(_localeKey, locale.languageCode);
    state = AsyncValue.data(locale);
  }
}

final localeProvider = AsyncNotifierProvider<LocaleNotifier, Locale>(
  () => LocaleNotifier(),
);
