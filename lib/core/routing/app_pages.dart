import 'package:get/get.dart';

import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/features/auth/presentation/bindings/auth_binding.dart';
import 'package:medora_git/features/auth/presentation/screens/login_screen.dart';
import 'package:medora_git/features/auth/presentation/screens/otp_screen.dart';
import 'package:medora_git/features/auth/presentation/screens/register_screen.dart';
import 'package:medora_git/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:medora_git/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:medora_git/features/patient/presentation/bindings/booking_bindings.dart';
import 'package:medora_git/features/patient/presentation/screens/booking_view.dart';
import 'package:medora_git/features/patient/presentation/screens/main_screen.dart';
import 'package:medora_git/features/start/presentation/screens/onboarding_screen.dart';
import 'package:medora_git/features/start/presentation/screens/splash_screen.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRouter.splash, page: () => SplashScreen()),
    GetPage(name: AppRouter.onboarding, page: () => OnboardingScreen()),
    GetPage(
      name: AppRouter.role,
      page: () => RoleSelectionScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRouter.register,
      page: () => RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRouter.otp,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return VerificationScreen(
          email: args['email'],
          isRegister: args['isRegister'] ?? false,
        );
      },
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRouter.login,
      page: () => LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRouter.resetPass,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return ResetPasswordScreen(email: args['email'], otp: args['otp_code']);
        
      },
      binding: AuthBinding(),
    ),

     GetPage(name: AppRouter.main, page:()=>MainScreen()),
     GetPage(
      name: AppRouter.book,
      page: () =>  BookingView(),
      binding: BookingBindings(),
    ),
    // GetPage(name: AppRouter.patient, page:()=>PatientHomeScreen()),
    //  GetPage(
    //  name: AppRouter.book,
    //  page: () => BookingView(),
    //binding: BookingBindings(),
    //),
  ];
}
