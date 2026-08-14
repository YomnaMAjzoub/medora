// lib/features/authentication/ui/screens/reset_password_screen.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/common/widgets/elevated_button.dart';
import 'package:medora_git/common/widgets/text_field.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/auth/business_layer/controller/auth_controller.dart';


class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final AuthController authController = Get.find();
  final TextEditingController newPasswordController = TextEditingController();

  @override
  void dispose() {
    newPasswordController.dispose();
    super.dispose();
  }

  void handleResetPassword() {
    if (newPasswordController.text.isEmpty) {
      Get.snackbar(
        'error'.tr(),
        'please_fill_all'.tr(),
        backgroundColor: AppColors.red,
        colorText: AppColors.yellow,
      );
      return;
    }

    authController.resetPass(
      widget.email,
      newPasswordController.text.trim(),
      (message) {
        Get.snackbar(
          'success'.tr(),
          message,
          backgroundColor: AppColors.primary600,
          colorText: AppColors.yellow,
        );
      },
      (error) {
        Get.snackbar(
          'error'.tr(),
          error,
          backgroundColor: AppColors.red,
          colorText: AppColors.yellow,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              vertical: 32,
              horizontal: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(Icons.arrow_back, color: context.appColors.textPrimary),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Center(
                  child: Text(
                    "reset_password_title".tr(),
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    "reset_password_subtitle".tr(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                CustomFormField(
                  controller: newPasswordController,
                  width: MediaQuery.of(context).size.width * 0.93,
                  height: 48,
                  hint: "new_password".tr(),
                  inputAction: TextInputAction.next,
                  keyboard: TextInputType.text,
                  prefix: Icon(
                    Icons.lock,
                    color: AppColors.primary900,
                    size: 20,
                  ),
                  suffix: IconButton(
                    onPressed: () {
                      authController.obscurenew.value =
                          !authController.obscurenew.value;
                    },
                    icon: authController.obscurenew.value
                        ? Icon(
                            Icons.visibility_off,
                            color: AppColors.primary900,
                            size: 20,
                          )
                        : Icon(
                            Icons.visibility,
                            color: AppColors.primary900,
                            size: 20,
                          ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    borderSide: BorderSide(color: context.appColors.border),
                  ),
                  focused: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    borderSide: BorderSide(color: context.appColors.border),
                  ),
                  enabled: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    borderSide: BorderSide(color: context.appColors.border),
                  ),
                  obscuretext: authController.obscurenew.value,
                ),
                SizedBox(height:40),
                Obx(
                  () => authController.isloading.value
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary600,
                          ),
                        )
                      : CustomElevated(
                          text: "reset_password_button".tr(),
                          height: 48,
                          width: MediaQuery.of(context).size.width * 0.93,
                          onPressed: handleResetPassword,
                          background: AppColors.primary900,
                          textColor: AppColors.yellow,
                        ),
                ),
              ],
            ),
          ),
        ),
      
    );
  }
}
