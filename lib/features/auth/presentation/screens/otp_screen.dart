// lib/features/authentication/ui/screens/otp_screen.dart
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/common/widgets/elevated_button.dart';
import 'package:medora_git/common/widgets/gradient.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/features/auth/business_layer/controller/auth_controller.dart';

import 'package:pin_code_fields/pin_code_fields.dart';

class VerificationScreen extends StatelessWidget {
  VerificationScreen({
    super.key,
    required this.email,
    required this.isRegister,
  });

  final AuthController authController = Get.find();
  final TextEditingController otpController = TextEditingController();
  final String email;
  String otp = '';
  final bool isRegister;

  @override
  Widget build(BuildContext context) {
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
                    icon: const Icon(Icons.arrow_back, color: AppColors.black),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
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
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "${isRegister ? "otp_subtitle".tr() : "verify_email_subtitle".tr()}$email",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: GoogleFonts.roboto(color: AppColors.grey200),
                ),
                const SizedBox(height: 40),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 25,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
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
                          inactiveColor: AppColors.grey200,
                          inactiveFillColor: AppColors.grey50,
                          selectedColor: AppColors.primary800,
                          selectedFillColor: AppColors.white,
                          activeColor: AppColors.primary800,
                          activeFillColor: AppColors.white,
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
                              Get.snackbar('Error', 'Enter full code');
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
                                  Get.snackbar('Success', msg);
            
                                  Get.toNamed(
                                    AppRouter.resetPass,
                                    arguments: {'email': email, 'otp_code':otp},
                                  );
                                },
                                (err) {
                                  Get.snackbar('Error', err);
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
