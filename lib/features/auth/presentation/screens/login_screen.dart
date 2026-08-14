import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/common/widgets/elevated_button.dart';
import 'package:medora_git/common/widgets/gradient.dart';
import 'package:medora_git/common/widgets/text_field.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/auth/business_layer/controller/auth_controller.dart';
import 'package:medora_git/features/auth/presentation/screens/register_screen.dart';


class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController authController = Get.find();

  void handleLogin() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'error'.tr(),
        'please_fill_all'.tr(),
        backgroundColor: Colors.red.shade100,
        colorText: AppColors.black,
        duration: Duration(seconds: 3),
      );
      return;
    }
    authController.login(
      (message) {
        Get.snackbar(
          'success'.tr(),
          message,
          dismissDirection: DismissDirection.up,
          duration: Duration(seconds: 3),
          backgroundColor: AppColors.primary100,
          colorText: AppColors.black,
        );
      },
      (error) {
        Get.snackbar(
          'error'.tr(),
          error,
          dismissDirection: DismissDirection.up,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red.shade100,
          colorText: AppColors.black,
        );
      },
      email,
      password,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      body: CustomGradient(
        child: Center(
          child: Container(
            width: 380,
            padding: const EdgeInsets.symmetric(vertical:20, horizontal:20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/medora_logo.png',
                        width: 70,
                        height: 70,
                        filterQuality: FilterQuality.high,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        'medora'.tr(),
                        style: GoogleFonts.roboto(
                          fontSize: 34,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  Text(
                    'login_title'.tr(),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'login_subtitle'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: colors.textSecondary),
                  ),

                  const SizedBox(height: 30),
                  Text(
                    'email'.tr(),
                    style: GoogleFonts.roboto(
                      color: AppColors.primary900,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  CustomFormField(
                    controller: emailController,
                    width: MediaQuery.of(context).size.width * 0.93,
                    height: 48,
                    hint: 'email'.tr(),
                    prefix: Icon(
                      Icons.email,
                      color: AppColors.primary900,
                      size: 20,
                    ),
                    inputAction: TextInputAction.next,
                    keyboard: TextInputType.emailAddress,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide(
                        color: AppColors.grey100,
                        width: 1,
                      ),
                    ),
                    focused: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide(
                        color: AppColors.grey100,
                        width: 1,
                      ),
                    ),
                    enabled: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide(
                        color: AppColors.grey100,
                        width: 1,
                      ),
                    ),
                    obscuretext: false,
                  ),

                  SizedBox(height: 20),
                  Text(
                    'pass'.tr(),
                    style: GoogleFonts.roboto(
                      color: AppColors.primary900,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Obx(() {
                    if (authController.isloading.value) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary600,
                        ),
                      );
                    }
                    return CustomFormField(
                      controller: passwordController,
                      width: MediaQuery.of(context).size.width * 0.93,
                      height: 48,
                      hint: 'pass'.tr(),
                      prefix: Icon(
                        Icons.lock,
                        color: AppColors.primary900,
                        size: 20,
                      ),
                      suffix: IconButton(
                        onPressed: () {
                          authController.logPass.value =
                              !authController.logPass.value;
                        },
                        icon: authController.logPass.value
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

                      inputAction: TextInputAction.next,
                      keyboard: TextInputType.text,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(
                          color: AppColors.grey100,
                          width: 1,
                        ),
                      ),
                      focused: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(
                          color: AppColors.grey100,
                          width: 1,
                        ),
                      ),
                      enabled: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(
                          color: AppColors.grey100,
                          width: 1,
                        ),
                      ),
                      obscuretext: authController.logPass.value,
                    );
                  }),

                  SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.bottomEnd,
                    child: TextButton(
                      onPressed: () {
                        if (emailController.text.isEmpty) {
                          Get.snackbar('error'.tr(), 'enter_email_first'.tr());
                          return;
                        }
                        authController.forgetPassword(
                          emailController.text,
                        (msg) {
                          Get.toNamed(AppRouter.otp, arguments: {'email': emailController.text});
                        },
                        (err) {
                          Get.snackbar('error'.tr(), err);
                        },
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'forgot'.tr(),
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Align(
                    alignment: AlignmentDirectional.bottomCenter,
                    child: Obx(() {
                      if (authController.isloading.value) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary600,
                          ),
                        );
                      }
                      return CustomElevated(
                        text: 'login'.tr(),
                        height: 48,
                        width: MediaQuery.of(context).size.width * 0.75,
                        onPressed: () {
                          handleLogin();
                        },
                        background: AppColors.primary900,
                        textColor: AppColors.yellow,
                      );
                    }),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: colors.border, thickness: 1),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'continue'.tr(),
                        style: GoogleFonts.roboto(
                          color: colors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Divider(color: colors.border, thickness: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: colors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: colors.surface,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.g_mobiledata,
                                size: 26,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Google',
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: colors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: colors.surface,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.apple,
                                size: 22,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Apple',
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Text(
                          'ques-login'.tr(),
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colors.textSecondary,
                          ),
                        ),
                      
                      TextButton(
                          onPressed: () {
                            Get.toNamed(AppRouter.register);
                          },
                          child: Text(
                            'create'.tr(),
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary700,
                            ),
                          ),
                        ),
                     
                    ],
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: Column(
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 16,
                          children: [
                            FooterLink(text: 'privacy'.tr()),
                            FooterLink(text: 'terms'.tr()),
                            FooterLink(text: 'support'.tr()),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '© 2026 Medora Clinic. All rights reserved.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.textHint,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
