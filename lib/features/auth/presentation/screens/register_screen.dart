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
import 'package:medora_git/features/auth/presentation/widgets/blood_selector.dart';
import 'package:medora_git/features/auth/presentation/widgets/genderoption.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});
  final AuthController authController = Get.find();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController illnessController = TextEditingController();

  void handleRegister() {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        authController.gender.isEmpty ||
        authController.birthDate.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar(
        'error'.tr(),
        'please_fill_all'.tr(),
        backgroundColor: Get.context!.appColors.danger.withValues(alpha: 0.15),
        colorText: Get.context!.appColors.textPrimary,
      );
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'error'.tr(),
        'passwords_not_match'.tr(),
        backgroundColor: Get.context!.appColors.danger.withValues(alpha: 0.15),
        colorText: Get.context!.appColors.textPrimary,
      );
      return;
    }
    authController.register(
      firstNameController.text.trim(),
      lastNameController.text.trim(),
      authController.gender.value.trim(),
      authController.birthDate.value.trim(),
      emailController.text.trim(),
      phoneController.text.trim(),
      passwordController.text.trim(),
      confirmPasswordController.text.trim(),
      authController.bloodType.value.trim(),
      illnessController.text.trim(),
      (message) {
        Get.snackbar(
          "success".tr(),
          message,
          backgroundColor:
              Get.context!.appColors.success.withValues(alpha: 0.15),
          colorText: Get.context!.appColors.textPrimary,
          duration: Duration(seconds: 3),
        );
      },
      (error) {
        Get.snackbar(
          "error".tr(),
          error,
          backgroundColor:
              Get.context!.appColors.danger.withValues(alpha: 0.15),
          colorText: Get.context!.appColors.textPrimary,
          duration: Duration(seconds: 3),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // The card never exceeds 380px and always leaves 24px of breathing
    // room, so it fits small phones and scales up on tablets.
    final cardWidth = (screenWidth - 24).clamp(0.0, 380.0);
    return Scaffold(
      body: CustomGradient(
        child: Center(
          child: Container(
            width: cardWidth,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
            decoration: BoxDecoration(
              color: context.appColors.surface,
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
                        style: GoogleFonts.inter(
                          fontSize: 34,
                          fontWeight: FontWeight.w500,
                          color: context.appColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Text(
                    'register_title'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                  Text(
                    'register_subtitle'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: CustomFormField(
                          controller: firstNameController,
                          width: double.infinity,
                          height: 48,
                          hint: 'first'.tr(),
                          prefix: Icon(
                            Icons.person,
                            color: context.appColors.primary,
                            size: 20,
                          ),
                          inputAction: TextInputAction.next,
                          keyboard: TextInputType.name,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide: BorderSide(
                              color: context.appColors.border,
                              width: 1,
                            ),
                          ),
                          focused: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide: BorderSide(
                              color: context.appColors.border,
                              width: 1,
                            ),
                          ),
                          enabled: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide: BorderSide(
                              color: context.appColors.border,
                              width: 1,
                            ),
                          ),
                          obscuretext: false,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomFormField(
                          controller: lastNameController,
                          width: double.infinity,
                          height: 48,
                          hint: 'last'.tr(),
                          prefix: Icon(
                            Icons.person,
                            color: context.appColors.primary,
                            size: 20,
                          ),
                          inputAction: TextInputAction.next,
                          keyboard: TextInputType.name,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide: BorderSide(
                              color: context.appColors.border,
                              width: 1,
                            ),
                          ),
                          focused: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide: BorderSide(
                              color: context.appColors.border,
                              width: 1,
                            ),
                          ),
                          enabled: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide: BorderSide(
                              color: context.appColors.border,
                              width: 1,
                            ),
                          ),
                          obscuretext: false,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'gender'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 10),
                  GenderSelector(),
                  SizedBox(height: 20),
                  Obx(() {
                    return GestureDetector(
                      onTap: () => authController.showBirthDatePicker(context),
                      child: AbsorbPointer(
                        child: CustomFormField(
                          width: double.infinity,
                          height: 48,
                          hint: authController.birthDate.value.isEmpty
                              ? 'birth'.tr()
                              : DateFormat('dd/MM/yyyy').format(
                                  DateTime.parse(authController.birthDate.value),
                                ),
                          prefix: Icon(
                            Icons.calendar_month,
                            color: context.appColors.primary,
                            size: 20,
                          ),
                          readOnly: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide: BorderSide(
                              color: context.appColors.border,
                              width: 1,
                            ),
                          ),
                          enabled: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide: BorderSide(
                              color: context.appColors.border,
                              width: 1,
                            ),
                          ),
                          focused: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide: BorderSide(
                              color: context.appColors.border,
                              width: 1,
                            ),
                          ),
                          obscuretext: false,
                          inputAction: TextInputAction.next,
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 20),
                  CustomFormField(
                    controller: emailController,
                    width: double.infinity,
                    height: 48,
                    hint: 'email'.tr(),
                    prefix: Icon(
                      Icons.email,
                      color: context.appColors.primary,
                      size: 20,
                    ),
                    inputAction: TextInputAction.next,
                    keyboard: TextInputType.emailAddress,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide(
                        color: context.appColors.border,
                        width: 1,
                      ),
                    ),
                    focused: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide(
                        color: context.appColors.border,
                        width: 1,
                      ),
                    ),
                    enabled: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide(
                        color: context.appColors.border,
                        width: 1,
                      ),
                    ),
                    obscuretext: false,
                  ),
                  SizedBox(height: 20),
                  CustomFormField(
                    controller: phoneController,
                    width: double.infinity,
                    height: 48,
                    hint: 'phone'.tr(),
                    prefix: Icon(
                      Icons.phone,
                      color: context.appColors.primary,
                      size: 20,
                    ),
                    inputAction: TextInputAction.next,
                    keyboard: TextInputType.phone,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide(
                        color: context.appColors.border,
                        width: 1,
                      ),
                    ),
                    focused: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide(
                        color: context.appColors.border,
                        width: 1,
                      ),
                    ),
                    enabled: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide(
                        color: context.appColors.border,
                        width: 1,
                      ),
                    ),
                    obscuretext: false,
                  ),
                  SizedBox(height: 20),
                  Obx(
                    () => CustomFormField(
                      controller: passwordController,
                      width: double.infinity,
                      height: 48,
                      hint: 'pass'.tr(),
                      prefix: Icon(
                        Icons.lock,
                        color: context.appColors.primary,
                        size: 20,
                      ),
                      suffix: IconButton(
                        onPressed: () {
                          authController.obscurePassword.value =
                              !authController.obscurePassword.value;
                        },
                        icon: authController.obscurePassword.value
                            ? Icon(Icons.visibility_off)
                            : Icon(Icons.visibility),
                      ),
                      inputAction: TextInputAction.next,
                      keyboard: TextInputType.text,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(
                          color: context.appColors.border,
                          width: 1,
                        ),
                      ),
                      focused: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(
                          color: context.appColors.border,
                          width: 1,
                        ),
                      ),
                      enabled: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(
                          color: context.appColors.border,
                          width: 1,
                        ),
                      ),
                      obscuretext: authController.obscurePassword.value,
                    ),
                  ),
                  SizedBox(height: 20),
                  Obx(
                    () => CustomFormField(
                      controller: confirmPasswordController,
                      width: double.infinity,
                      height: 48,
                      hint: 'confirm'.tr(),
                      prefix: Icon(
                        Icons.lock,
                        color: context.appColors.primary,
                        size: 20,
                      ),
                      suffix: IconButton(
                        onPressed: () {
                          authController.obscureConfirm.value =
                              !authController.obscureConfirm.value;
                        },
                        icon: authController.obscureConfirm.value
                            ? Icon(Icons.visibility_off)
                            : Icon(Icons.visibility),
                      ),
                      inputAction: TextInputAction.done,
                      keyboard: TextInputType.text,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(
                          color: context.appColors.border,
                          width: 1,
                        ),
                      ),
                      focused: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(
                          color: context.appColors.border,
                          width: 1,
                        ),
                      ),
                      enabled: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(
                          color: context.appColors.border,
                          width: 1,
                        ),
                      ),
                      obscuretext: authController.obscureConfirm.value,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'blood'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 5),
                  BloodTypeSelector(),
                  SizedBox(height: 25),
                  CustomFormField(
                    controller: illnessController,
                    width: double.infinity,
                    height: 48,
                    hint: 'ill'.tr(),
                    prefix: Icon(
                      Icons.medical_information,
                      color: context.appColors.primary,
                      size: 20,
                    ),
                    inputAction: TextInputAction.next,
                    keyboard: TextInputType.text,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide(
                        color: context.appColors.border,
                        width: 1,
                      ),
                    ),
                    focused: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide(
                        color: context.appColors.border,
                        width: 1,
                      ),
                    ),
                    enabled: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide(
                        color: context.appColors.border,
                        width: 1,
                      ),
                    ),
                    obscuretext: false,
                  ),
                  SizedBox(height: 30),
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
                        text: 'register'.tr(),
                        height: 48,
                        width: double.infinity,
                        onPressed: () {
                          handleRegister();
                        },
                        background: context.appColors.primary,
                        textColor: AppColors.yellow,
                      );
                    }),
                  ),

                  SizedBox(height: 20),

                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: 'refering'.tr(),
                        style: GoogleFonts.inter(
                          color: context.appColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: 'terms'.tr(),
                            style: GoogleFonts.inter(
                              color: context.appColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: 'and'.tr(),
                            style: GoogleFonts.inter(
                              color: context.appColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: 'privacy'.tr(),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: context.appColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(child: Divider(color: context.appColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or'.tr(),
                          style: GoogleFonts.inter(
                            color: context.appColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: context.appColors.border)),
                    ],
                  ),

                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'already-have'.tr(),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.toNamed(AppRouter.login);
                        },
                        child: Text(
                          'login'.tr(),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: context.appColors.primary,
                          ),
                        ),
                      ),
                    ],
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

class FooterLink extends StatelessWidget {
  final String text;
  const FooterLink({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        text,
        style: TextStyle(
          color: context.appColors.textSecondary,
          fontSize: 11,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
