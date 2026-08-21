import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/auth/data/src/auth_service.dart';
import 'package:medora_git/features/patient/business_layer/controller/patient_account_controller.dart';

/// "Profile" tab (index 3 of MainScreen): the logged-in patient's account
/// info loaded from the backend (getMyProfile) with quick links and logout.
class ProfileScreen extends GetView<PatientAccountController> {
  const ProfileScreen({super.key});

  void _logout() {
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
    final colors = context.appColors;
    final storage = GetStorage();
    final role = storage.read<String>('role') ?? 'patient';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text(
          'profile'.tr(),
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
        child: Obx(() {
          final profile = controller.profile.value;
          final name = profile?.fullName.isNotEmpty == true
              ? profile!.fullName
              : (storage.read<String>('user_name') ?? 'patient_account'.tr());
          final email = profile?.email.isNotEmpty == true
              ? profile!.email
              : (storage.read<String>('user_email') ?? '');
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: context.appColors.primary.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: context.appColors.primaryContainer,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 32,
                          ),
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
                                style: GoogleFonts.inter(
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
                                style: GoogleFonts.inter(
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
                                  color: context.appColors.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  role.capitalizeFirst!,
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
                    if (profile != null) ...[
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      _infoGrid(colors, profile),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Obx(
                () => _menuTile(
                  context,
                  icon: Icons.picture_as_pdf_rounded,
                  label: 'export_records'.tr(),
                  loading: controller.isExportingPdf.value,
                  onTap: () => controller.exportMedicalRecordsPdf(),
                ),
              ),
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
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _infoGrid(dynamic colors, dynamic profile) {
    final entries = <(IconData, String, String)>[
      (Icons.phone_rounded, 'phone'.tr(), profile.phone),
      (Icons.wc_rounded, 'gender'.tr(), profile.gender.capitalizeFirst ?? ''),
      (Icons.cake_rounded, 'birth'.tr(), profile.birth ?? ''),
      (Icons.bloodtype_rounded, 'blood_type'.tr(), profile.bloodType ?? ''),
      (
        Icons.medical_information_rounded,
        'previous_illnesses'.tr(),
        profile.previousIllnesses ?? '',
      ),
    ];
    return Column(
      children: [
        for (final (icon, label, value) in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color:AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  '$label: ',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
                Expanded(
                  child: Text(
                    value.isEmpty ? 'not_provided'.tr() : value,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool loading = false,
  }) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: loading ? null : onTap,
        leading: Icon(icon, color: context.appColors.primary, size: 22),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: colors.textPrimary,
          ),
        ),
        trailing: loading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.appColors.primary,
                ),
              )
            : Icon(
                Icons.chevron_right_rounded,
                color: context.appColors.primary,
              ),
      ),
    );
  }
}