import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';

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
              "Select Birthdate",
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
                  if (!isAdult(date)) {
                    Get.snackbar(
                      "Error",
                      "You must be at least 18 years old",
                      backgroundColor: AppColors.primary50,
                      colorText: AppColors.primary900,
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
      bool result = await authService.register(
        firstName,
        lastName,
        gender,
        birth,
        email,
        phone,
        password,
        confirmPass,
        bloodType,
        illness,
      );
      if (result) {
        onSuccess('Registration successful. Please verify your email.');
        Get.toNamed(
          AppRouter.otp,
          arguments: {'email': email, 'isRegister': true},
        );
      } else {
        onError('Registration failed');
      }
    } catch (e) {
      final msg = e.toString() ;
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
      bool result = await authService.verifyCode(email, code);
      if (result) {
        onSuccess('Email verified successfully.');
        Get.offAllNamed(AppRouter.login);
      } else {
        onError('verification failed');
      }
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
      bool result = await authService.login(email, password);
      if (result) {
        onSuccess('Login successful');
        String? role = authService.storage.read('role');
        role ??= selectedRole.value;
       if (role == "patient") {
        Get.offAllNamed(AppRouter.main);
      } else if (role == "doctor") {
       // Get.offAllNamed(AppRouter.doctorHome);
      } else if (role == "staff") {
       // Get.offAllNamed(AppRouter.staffHome);
      } 

      } else {
        onError('Login failed');
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
      onSuccess('Otp Code sent to your email');
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
      onSuccess('Email verified successfully.');
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
      onSuccess('Password reset successful');
      Get.offAllNamed(AppRouter.login);
    } catch (e) {
      onError(e.toString());
    } finally {
      isloading.value = false;
    }
  }
}
