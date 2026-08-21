import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/common/widgets/gradient.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/auth/business_layer/controller/auth_controller.dart';


class RoleSelectionScreen extends StatelessWidget {
  RoleSelectionScreen({super.key});
  final AuthController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final screenWidth = MediaQuery.of(context).size.width;
    // The card never exceeds 380px and always leaves 24px of breathing
    // room, so it fits small phones and scales up on tablets.
    final cardWidth = (screenWidth - 24).clamp(0.0, 380.0);
    return Scaffold(
      body: CustomGradient(
        child: Center(
          child: Container(
            width: cardWidth,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Image.asset(
                      'assets/images/medora_logo.png',
                      width: 90,
                      height: 90,
                      filterQuality: FilterQuality.high,
                      fit: BoxFit.contain,
                    ),
                    // const SizedBox(height: 12),
                    Text(
                      'medora'.tr(),
                      style: GoogleFonts.inter(
                        fontSize: 34,
                        fontWeight: FontWeight.w500,
                        color: context.appColors.primary,
                      ),
                    ),

                const SizedBox(height: 25),

                Text(
                  "welcome_aboard".tr(),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "tell_us_who".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: colors.textSecondary,
                  ),
                ),

                const SizedBox(height: 30),

                // Roles
                roleItem(context: context,
                  title: "role_patient".tr(),
                  subtitle: "role_patient_sub".tr(),
                  icon: Icons.person,
                  onTap: () {
                    controller.selectRole("patient");
                    Get.toNamed(AppRouter.register);
                  },
                ),
                const SizedBox(height: 16),

                roleItem(context: context,
                  title: "role_doctor".tr(),
                  subtitle: "role_doctor_sub".tr(),
                  icon: Icons.medical_services,
                  onTap: () {
                    controller.selectRole("doctor");
                    Get.toNamed(AppRouter.login);
                  },
                ),
                const SizedBox(height: 16),

                roleItem(context: context,
                  title: "role_admin".tr(),
                  subtitle: "role_admin_sub".tr(),
                  icon: Icons.admin_panel_settings,
                  onTap: () {
                    controller.selectRole("admin");
                    Get.toNamed(AppRouter.login);
                  },
                ),

                const SizedBox(height: 25),
                Text(
                  "Â© 2024 MediFlow Clinic",
                  style: TextStyle(color: colors.textHint, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  '${"privacy".tr()} • ${"support".tr()}',
                  style: TextStyle(color: colors.textHint, fontSize: 12),
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget roleItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color:AppColors.primary600),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
           Icon(Icons.arrow_forward,color: colors.textHint,)
          ],
        ),
      ),
    );
  }
}
