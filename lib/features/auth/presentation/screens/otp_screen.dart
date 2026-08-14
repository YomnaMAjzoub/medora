// lib/features/authentication/ui/screens/otp_screen.dart
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/common/widgets/elevated_button.dart';
import 'package:medora_git/common/widgets/gradient.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/features/auth/business_layer/controller/auth_controller.dart';

import 'package:pin_code_fields/pin_code_fields.dart';

class VerificationScreen extends StatefulWidget {
  VerificationScreen({
    super.key,
    required this.email,
    required this.isRegister,
  });

  final AuthController authController = Get.find();
  final TextEditingController otpController = TextEditingController();
  final String email;
  final bool isRegister;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  String otp = '';

  @override
  void dispose() {
    widget.otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = widget.authController;
    final email = widget.email;
    final isRegister = widget.isRegister;
    final otpController = widget.otpController;
    return Scaffold(
      body: CustomGradient(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: context.appColors.textPrimary),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: context.appColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mail_outline,
                    size: 40,
                    color: AppColors.primary800,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isRegister ? "otp_title".tr() : "verify_email_title".tr(),
                  style: GoogleFonts.roboto(
                    fontSize: 22,
                    color: context.appColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "${isRegister ? "otp_subtitle".tr() : "verify_email_subtitle".tr()}$email",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: GoogleFonts.roboto(color: context.appColors.textSecondary),
                ),
                const SizedBox(height: 40),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 25,
                  ),
                  decoration: BoxDecoration(
                    color: context.appColors.surface,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      PinCodeTextField(
                        controller: otpController,
                        appContext: context,
                        length: 6,
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.fade,
                        enableActiveFill: true,
                        cursorColor: AppColors.primary800,
                        showCursor: false,
                        textStyle: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(12),
                          fieldHeight: 55,
                          fieldWidth: 45,
                          inactiveColor: context.appColors.border,
                          inactiveFillColor: context.appColors.inputFill,
                          selectedColor: AppColors.primary800,
                          selectedFillColor: context.appColors.inputFill,
                          activeColor: AppColors.primary800,
                          activeFillColor: context.appColors.inputFill,
                        ),
                        onChanged: (value) {
                         otp=value;
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                SizedBox(height: 100),
                Obx(
                  () => authController.isloading.value
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary800,
                          ),
                        )
                      : CustomElevated(
                          onPressed: () {
                            if (otp.length != 6) {
                              Get.snackbar('error'.tr(), 'enter_full_code'.tr());
                              return;
                            }
                            if (isRegister) {
                              authController.verifyCode(
                                email,
                                otp,
                                (msg) {
                                  Get.snackbar(
                                    'Success',
                                    msg,
                                    backgroundColor: AppColors.primary100,
                                    colorText: AppColors.black,
                                    duration: Duration(seconds: 3),
                                  );
                                  Get.offAllNamed(AppRouter.login);
                                },
                                (err) {
                                  Get.snackbar(
                                    'Error',
                                    err,
                                    backgroundColor: Colors.red.shade100,
                                    colorText: AppColors.black,
                                    duration: Duration(seconds: 3),
                                  );
                                },
                              );
                            } else {
                              authController.verifyOtp(
                                email,
                                 otp,
                                (msg) {
                                  Get.snackbar('success'.tr(), msg);
                                },
                                (err) {
                                  Get.snackbar('error'.tr(), err);
                                },
                              );
                            }
                          },
                          text: "Verify".tr(),
                          background: AppColors.primary900,
                          height: 48,
                          width: MediaQuery.of(context).size.width * 0.50,
                          textColor: AppColors.yellow,
                          color: AppColors.primary900,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
