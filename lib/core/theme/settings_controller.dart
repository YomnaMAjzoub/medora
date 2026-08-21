import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';

/// Persists and applies the app-wide theme mode and language.
class SettingsController extends GetxController {
  static const _themeKey = 'theme_mode';
  static const _localeKey = 'locale';

  final GetStorage _storage = GetStorage();

  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  /// The active app language. Observed by the root [Obx] around
  /// GetMaterialApp, so changing it rebuilds the whole app with the new
  /// locale (and RTL/LTR direction).
  final Rx<Locale> locale = const Locale('en').obs;

  @override
  void onInit() {
    super.onInit();
    final stored = _storage.read<String>(_themeKey);
    themeMode.value = switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    locale.value = Locale(_storage.read<String>(_localeKey) ?? 'en');
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
    final newLocale = Locale(code);
    if (locale.value != newLocale) {
      locale.value = newLocale;
    }
    _storage.write(_localeKey, code);
    // GetMaterialApp resolves its locale from the cached Get.locale (it
    // ignores the widget parameter after startup), so the cached value must
    // be updated as well. The root Obx around GetMaterialApp (main.dart)
    // rebuilds on the Rx change above and delivers the new locale.
    Get.locale = newLocale;
  }
}
