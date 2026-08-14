import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/auth/business_layer/controller/auth_controller.dart';


void showBirthDatePicker(BuildContext context) {
 final AuthController controller = Get.find<AuthController>();
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "select_birthdate".tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary900,
            ),
          ),
          const SizedBox(height: 10),

          SizedBox(
            height: 250,
            child: CalendarDatePicker(
              initialDate: DateTime(2000, 1, 1),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              onDateChanged: (date) {
                if (!controller.isAdult(date)) {
                  Get.snackbar(
                    "error".tr(),
                    "adult_required".tr(),
                    backgroundColor: AppColors.primary50,
                    colorText: AppColors.primary900,
                  );
                  return;
                }

               controller.setBirthDate(date);
                Get.back();
              },
            ),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}
