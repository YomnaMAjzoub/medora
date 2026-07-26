import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/features/auth/business_layer/controller/auth_controller.dart';


class GenderSelector extends StatelessWidget {
  GenderSelector({super.key});

  final AuthController controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _genderItem(
            label: "male".tr(),
            value: "male",
            icon: Icons.male,
          ),
          
          _genderItem(
            label: "female".tr(),
            value: "female",
            icon: Icons.female,
          ),
        ],
      );
    });
  }

  Widget _genderItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final bool isSelected = controller.gender.value == value;

    return GestureDetector(
      onTap: () => controller.setGender(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary900 : AppColors.grey100,
            width: 1.4,
          ),
         // color: isSelected ? AppColors.primary500 : AppColors.white,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary900 : AppColors.neutral500,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color:AppColors.grey300,
              ),
            ),
            const SizedBox(width: 8),
            _customRadio(isSelected),
          ],
        ),
      ),
    );
  }

  Widget _customRadio(bool isSelected) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary900 : AppColors.neutral400,
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
