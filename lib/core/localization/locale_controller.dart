import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { ru, kk }

extension AppLanguageX on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.ru:
        return 'ru';
      case AppLanguage.kk:
        return 'kk';
    }
  }

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) {
    switch (code) {
      case 'kk':
        return AppLanguage.kk;
      case 'ru':
      default:
        return AppLanguage.ru;
    }
  }
}

final appLocaleProvider = StateNotifierProvider<AppLocaleController, Locale>((
  ref,
) {
  final controller = AppLocaleController();
  controller.load();
  return controller;
});

class AppLocaleController extends StateNotifier<Locale> {
  static const _prefsKey = 'app_language_code';

  AppLocaleController() : super(const Locale('ru'));

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    state = AppLanguageX.fromCode(code).locale;
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (state.languageCode == language.code) return;

    state = language.locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, language.code);
  }
}
