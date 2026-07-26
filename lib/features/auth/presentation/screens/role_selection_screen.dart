import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/common/widgets/gradient.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/features/auth/business_layer/controller/auth_controller.dart';


class RoleSelectionScreen extends StatelessWidget {
  RoleSelectionScreen({super.key});
  final AuthController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomGradient(
        child: Center(
          child: Container(
            width: 380,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
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
                      style: GoogleFonts.roboto(
                        fontSize: 34,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary900,
                      ),
                    ),

                const SizedBox(height: 25),

                const Text(
                  "Welcome aboard",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Tell us who you are to personalize your experience",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),

                const SizedBox(height: 30),

                // Roles
                roleItem(
                  title: "Patient",
                  subtitle: "Book appointments and track records.",
                  icon: Icons.person,
                  onTap: () {
                    controller.selectRole("patient");
                    Get.toNamed(AppRouter.register);
                  },
                ),
                const SizedBox(height: 16),

                roleItem(
                  title: "Doctor",
                  subtitle: "Manage patients and digital prescriptions.",
                  icon: Icons.medical_services,
                  onTap: () {
                    controller.selectRole("doctor");
                    Get.toNamed(AppRouter.login);
                  },
                ),
                const SizedBox(height: 16),

                roleItem(
                  title: "Clinic Staff",
                  subtitle: "Administrative controls and scheduling.",
                  icon: Icons.admin_panel_settings,
                  onTap: () {
                    controller.selectRole("staff");
                    Get.toNamed(AppRouter.login);
                  },
                ),

                const SizedBox(height: 25),
                const Text(
                  "© 2024 MediFlow Clinic",
                  style: TextStyle(color: Colors.black45, fontSize: 12),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Privacy Policy • Support",
                  style: TextStyle(color: Colors.black45, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget roleItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
           Icon(Icons.arrow_forward,color: AppColors.grey200,)
          ],
        ),
      ),
    );
  }
}
