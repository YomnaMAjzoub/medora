import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';

class PatientDrawer extends StatelessWidget {
  const PatientDrawer({super.key});

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
    final name = GetStorage().read<String>('user_name') ?? 'patient_account'.tr();
    return Drawer(
      width: 280,
      backgroundColor: colors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.primary700.withValues(alpha: 0.1),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary700,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "patient_account".tr(),
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // MENU ITEMS
          _drawerItem(context: context,
            icon: Icons.person,
            label: "profile_title".tr(),
            onTap: () {},
          ),
          _drawerItem(context: context,
            icon: Icons.calendar_month,
            label: "appointments".tr(),
            onTap: () {},
          ),
          _drawerItem(context: context,icon: Icons.favorite, label: "favorites".tr(), onTap: () {}),
          _drawerItem(context: context,
            icon: Icons.settings,
            label: "settings".tr(),
            onTap: () {
              Get.toNamed(AppRouter.settings);
            },
          ),
          _drawerItem(context: context,
            icon: Icons.language,
            label: "language".tr(),
            onTap: () {
              Get.toNamed(AppRouter.settings);
            },
          ),

          const Spacer(),

          // LOGOUT
          Padding(
            padding: const EdgeInsets.all(20),
            child: _drawerItem(context: context,
              icon: Icons.logout,
              label: "logout".tr(),
              onTap: _logout,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.primary700,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: context.appColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}