import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';

/// "Profile" tab (index 3 of MainScreen): the logged-in patient's account
/// info with quick links and logout.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _logout() {
    final storage = GetStorage();
    Get.defaultDialog(
      title: 'logout'.tr(),
      middleText: 'logout_confirm'.tr(),
      textCancel: 'cancel'.tr(),
      textConfirm: 'logout'.tr(),
      confirmTextColor: AppColors.white,
      buttonColor: AppColors.primary900,
      onConfirm: () {
        Get.back();
        storage.remove('access_token');
        storage.remove('user_id');
        storage.remove('role');
        storage.remove('user_name');
        storage.remove('user_email');
        Get.offAllNamed(AppRouter.onboarding);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final storage = GetStorage();
    final name = storage.read<String>('user_name') ?? 'patient_account'.tr();
    final email = storage.read<String>('user_email') ?? '';
    final role = storage.read<String>('role') ?? 'patient';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text(
          'profile'.tr(),
          style: GoogleFonts.roboto(
            color: AppColors.primary700,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary900.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary700,
                    child: Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email.isEmpty ? role.capitalizeFirst! : email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary900.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            role.capitalizeFirst!,
                            style: GoogleFonts.roboto(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _menuTile(
              context,
              icon: Icons.settings_rounded,
              label: 'settings'.tr(),
              onTap: () => Get.toNamed(AppRouter.settings),
            ),
            _menuTile(
              context,
              icon: Icons.language_rounded,
              label: 'language'.tr(),
              onTap: () => Get.toNamed(AppRouter.settings),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.danger,
                side: BorderSide(color: colors.danger.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: Text(
                'logout'.tr(),
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary700, size: 22),
        title: Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: colors.textPrimary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.primary700,
        ),
      ),
    );
  }
}