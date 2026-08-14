import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Persists and applies the app-wide theme mode and language.
class SettingsController extends GetxController {
  static const _themeKey = 'theme_mode';
  static const _localeKey = 'locale';

  final GetStorage _storage = GetStorage();

  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    final stored = _storage.read<String>(_themeKey);
    themeMode.value = switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    _storage.write(_themeKey, mode.name);
  }

  void toggleTheme() {
    setThemeMode(
      themeMode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  void setLocale(String code) {
    _storage.write(_localeKey, code);
  }
}
