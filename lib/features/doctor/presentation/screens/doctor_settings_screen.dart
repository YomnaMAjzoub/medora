import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/auth/data/src/auth_service.dart';
import 'package:medora_git/features/doctor/business_layer/controller/doctor_controller.dart';

/// Doctor "Settings" tab: profile overview, personal/work info editors,
/// availability toggles, notifications, invoices, change password and
/// logout.
class DoctorSettingsScreen extends GetView<DoctorController> {
  const DoctorSettingsScreen({super.key});

  static const _onlineKey = 'doctor_online_consultation';

  void _logout(BuildContext context) {
    Get.defaultDialog(
      title: 'logout'.tr(),
      middleText: 'logout_confirm'.tr(),
      textCancel: 'cancel'.tr(),
      textConfirm: 'logout'.tr(),
      confirmTextColor: AppColors.white,
      buttonColor: Get.context!.appColors.primaryContainer,
      onConfirm: () async {
        Get.back();
        final service = AuthService();
        await service.logout();
        await service.clearSession();
        Get.offAllNamed(AppRouter.onboarding);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final name = storage.read<String>('user_name') ?? '';
    final email = storage.read<String>('user_email') ?? '';

    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          'settings'.tr(),
          style: GoogleFonts.inter(
            color: context.appColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.appColors.primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: context.appColors.primaryContainer,
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isEmpty ? 'doctor_title'.tr() : name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email.isEmpty ? 'doctor_title'.tr() : email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: context.appColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: context.appColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'doctor_title'.tr(),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: context.appColors.primary,
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
            _sectionLabel(context, 'account'.tr()),
            _menuTile(
              context,
              icon: Icons.badge_rounded,
              label: 'doctor_profile'.tr(),
              onTap: () => Get.toNamed(AppRouter.doctorProfile),
            ),
            _menuTile(
              context,
              icon: Icons.person_outline_rounded,
              label: 'personal_info'.tr(),
              onTap: () => Get.toNamed(
                AppRouter.doctorProfile,
                arguments: {'mode': 'personal'},
              ),
            ),
            _menuTile(
              context,
              icon: Icons.work_outline_rounded,
              label: 'work_info'.tr(),
              onTap: () => Get.toNamed(
                AppRouter.doctorProfile,
                arguments: {'mode': 'work'},
              ),
            ),
            _menuTile(
              context,
              icon: Icons.notifications_outlined,
              label: 'notifications'.tr(),
              onTap: () => Get.toNamed(AppRouter.doctorNotifications),
            ),
            _menuTile(
              context,
              icon: Icons.receipt_long_rounded,
              label: 'invoices'.tr(),
              onTap: () => Get.toNamed(AppRouter.doctorInvoices),
            ),
            _menuTile(
              context,
              icon: Icons.lock_outline_rounded,
              label: 'change_password'.tr(),
              onTap: () => Get.toNamed(AppRouter.resetPass),
            ),
            const SizedBox(height: 20),
            _sectionLabel(context, 'availability'.tr()),
            _toggleTile(
              context,
              icon: Icons.home_rounded,
              label: 'home_visit'.tr(),
              value: controller.myProfile.value?.homeVisit ?? false,
              onChanged: (value) => controller.updateMyProfile(
                homeVisit: value,
              ),
            ),
            _toggleTile(
              context,
              icon: Icons.videocam_rounded,
              label: 'online_consultation'.tr(),
              value: storage.read<bool>(_onlineKey) ?? true,
              onChanged: (value) {
                storage.write(_onlineKey, value);
                Get.snackbar('success'.tr(), 'availability_updated'.tr());
              },
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _logout(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.appColors.danger,
                side: BorderSide(
                  color: context.appColors.danger.withValues(alpha: 0.4),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: Text(
                'logout'.tr(),
                style: GoogleFonts.inter(
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

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: context.appColors.primary, size: 22),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: context.appColors.textPrimary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: context.appColors.primary,
        ),
      ),
    );
  }

  Widget _toggleTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: context.appColors.primary, size: 22),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: context.appColors.textPrimary,
          ),
        ),
        activeTrackColor: context.appColors.primary,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}