import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/core/theme/settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'settings'.tr(),
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: context.appColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _sectionLabel(context, 'appearance'.tr()),
          const SizedBox(height: 8),
          Obx(
            () => _optionTile(context, 
              icon: Icons.brightness_auto,
              label: 'theme_system'.tr(),
              selected: controller.themeMode.value == ThemeMode.system,
              onTap: () => controller.setThemeMode(ThemeMode.system),
            ),
          ),
          Obx(
            () => _optionTile(context, 
              icon: Icons.light_mode,
              label: 'theme_light'.tr(),
              selected: controller.themeMode.value == ThemeMode.light,
              onTap: () => controller.setThemeMode(ThemeMode.light),
            ),
          ),
          Obx(
            () => _optionTile(context, 
              icon: Icons.dark_mode,
              label: 'theme_dark'.tr(),
              selected: controller.themeMode.value == ThemeMode.dark,
              onTap: () => controller.setThemeMode(ThemeMode.dark),
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel(context, 'language'.tr()),
          const SizedBox(height: 8),
          _optionTile(context, 
            icon: Icons.language,
            label: 'english'.tr(),
            selected: context.locale.languageCode == 'en',
            onTap: () {
              controller.setLocale('en');
              context.setLocale(const Locale('en'));
            },
          ),
          _optionTile(context, 
            icon: Icons.language,
            label: 'arabic'.tr(),
            selected: context.locale.languageCode == 'ar',
            onTap: () {
              controller.setLocale('ar');
              context.setLocale(const Locale('ar'));
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: context.appColors.textSecondary,
        ),
      ),
    );
  }

  Widget _optionTile(BuildContext context, {
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: context.appColors.primary, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected
                      ? colors.primary
                      : colors.textHint,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}