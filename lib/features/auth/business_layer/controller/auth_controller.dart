import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';

import 'package:medora_git/features/auth/data/src/auth_service.dart';

class AuthController extends GetxController {
  final RxBool isloading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirm = true.obs;
  final RxBool obscurenew = true.obs;
  final RxBool logPass = true.obs;
  final errorMessage = ''.obs;
  AuthService authService = AuthService();
  var gender = "male".obs;
  var birthDate = "".obs;
  var bloodType = "".obs;
  RxString selectedRole = ''.obs;

  void selectRole(String role) {
    selectedRole.value = role;
    authService.storage.write('role', role);
  }

  void setBloodType(String value) {
    bloodType.value = value;
  }

  void setBirthDate(DateTime date) {
    birthDate.value =
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  bool isAdult(DateTime date) {
    final today = DateTime.now();
    final age = today.year - date.year;
    if (age > 18) return true;
    if (age == 18 && today.month > date.month) return true;
    if (age == 18 && today.month == date.month && today.day >= date.day) {
      return true;
    }
    return false;
  }

  void showBirthDatePicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
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
                color: context.appColors.primary,
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
                  if (!isAdult(date)) {
                    // Close the sheet first so the error snackbar is
                    // visible (it renders behind an open bottom sheet).
                    Get.back();
                    Get.snackbar(
                      "error".tr(),
                      "adult_required".tr(),
                      backgroundColor: AppColors.primary50,
                      colorText: context.appColors.primary,
                    );
                    return;
                  }

                  setBirthDate(date);
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

  void setGender(String value) {
    gender.value = value;
  }

  Future<void> register(
    String firstName,
    String lastName,
    String gender,
    String birth,
    String email,
    String phone,
    String password,
    String confirmPass,
    String? bloodType,
    String? illness,
    Function(String) onSuccess,
    Function(String) onError,
  ) async {
    try {
      isloading.value = true;
      final result = await authService.register(
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        birth: birth,
        email: email,
        phone: phone,
        password: password,
        confirmPass: confirmPass,
        bloodType: bloodType,
        illness: illness,
      );
      onSuccess(result.message);
      Get.toNamed(
        AppRouter.otp,
        arguments: {'email': email, 'isRegister': true},
      );
    } catch (e) {
      final msg = e.toString();
      errorMessage.value = msg;
      onError(msg);
    } finally {
      isloading.value = false;
    }
  }

  Future<void> verifyCode(
    String email,
    String code,
    Function(String) onSuccess,
    Function(String) onError,
  ) async {
    try {
      isloading.value = true;
      final result = await authService.verifyCode(email: email, code: code);
      await authService.storage.write('user_id', result.user.id);
      onSuccess(result.message);
      Get.offAllNamed(AppRouter.login);
    } catch (e) {
      errorMessage.value = e.toString();
      onError(errorMessage.value);
    } finally {
      isloading.value = false;
    }
  }

  Future<void> login(
    Function(String) onSuccess,
    Function(String) onError,
    String email,
    String password,
  ) async {
    try {
      isloading.value = true;
      final result = await authService.login(email: email, password: password);
      final user = result.user;
      if (user != null) {
        await authService.storage.write('user_id', user.id);
        if (user.role.isNotEmpty) {
          await authService.storage.write('role', user.role);
        }
        final fullName = '${user.firstName} ${user.lastName}'.trim();
        if (fullName.isNotEmpty) {
          await authService.storage.write('user_name', fullName);
        }
        if (user.email.isNotEmpty) {
          await authService.storage.write('user_email', user.email);
        }
      }
      onSuccess(result.message);
      String? role = authService.storage.read('role');
      role ??= selectedRole.value;
      final fcmToken = authService.storage.read<String>('fcm_token') ?? '';
      log('=== LOGIN OK ===');
      log('user_id   : ${user?.id}');
      log('role      : $role');
      log('user_name : ${authService.storage.read<String>('user_name')}');
      log('user_email: ${authService.storage.read<String>('user_email')}');
      log('fcm_token : ${fcmToken.isEmpty ? 'NOT SET' : fcmToken}');

      // The login body already carries the token; pushing it explicitly too
      // guarantees the server is up to date even when the login payload was
      // built before the token existed.
      if (fcmToken.isNotEmpty) {
        authService.updateFcmToken(fcmToken);
      }

      if (role == "patient") {
        Get.offAllNamed(AppRouter.main);
      } else if (role == "doctor") {
        Get.offAllNamed(AppRouter.doctorHome);
      } else if (role == "admin") {
        Get.offAllNamed(AppRouter.adminHome);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      onError(errorMessage.value);
    } finally {
      isloading.value = false;
    }
  }

  Future<void> forgetPassword(
    String email,
    Function(String) onSuccess,
    Function(String) onError,
  ) async {
    try {
      isloading.value = true;
      await authService.forgotPass(email);
      onSuccess('otp_code_sent'.tr());
    } catch (e) {
      onError(e.toString());
    } finally {
      isloading.value = false;
    }
  }

  Future<void> verifyOtp(
    String email,
    String otp,
    Function(String) onSuccess,
    Function(String) onError,
  ) async {
    try {
      isloading.value = true;
      await authService.verifyOtp(email, otp);
      onSuccess('email_verified_success'.tr());
      Get.offNamed(
        AppRouter.resetPass,
        arguments: {
          'email': email,
          'otp_code': otp,
        },
      );
    } catch (e) {
      onError(e.toString());
    } finally {
      isloading.value = false;
    }
  }

  Future<void> resetPass(
    String email,
    String pass,
    Function(String) onSuccess,
    Function(String) onError,
  ) async {
    try {
      isloading.value = true;
      await authService.resetPass(email, pass);
      onSuccess('password_reset_success'.tr());
      Get.offAllNamed(AppRouter.login);
    } catch (e) {
      onError(e.toString());
    } finally {
      isloading.value = false;
    }
  }

  /// Logs the user out: backend session invalidation (best-effort), local
  /// session + FCM token cleanup, then back to onboarding.
  Future<void> logout() async {
    isloading.value = true;
    await authService.logout();
    await authService.clearSession();
    isloading.value = false;
    Get.offAllNamed(AppRouter.onboarding);
  }
}
