import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/auth/business_layer/controller/auth_controller.dart';

class BloodTypeSelector extends StatelessWidget {
  BloodTypeSelector({super.key});

  final AuthController controller = Get.find<AuthController>();

  final List<String> bloodTypes = [
    "A+","A-","B+","B-","AB+","AB-","O+","O-"
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bloodTypes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.9,
      ),
      itemBuilder: (context, index) {
        final value = bloodTypes[index];

        return Obx(() {
          final isSelected = controller.bloodType.value == value;

          return GestureDetector(
            onTap: () => controller.setBloodType(value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary900 : context.appColors.border,
                  width: 1.4,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _customRadio(isSelected, context.appColors),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _customRadio(bool isSelected, AppThemeColors colors) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary900 : colors.border,
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary900,
                ),
              ),
            )
          : null,
    );
  }
}
