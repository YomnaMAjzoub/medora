import 'package:get/get.dart';

import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/settings_screen.dart';
import 'package:medora_git/features/auth/presentation/bindings/auth_binding.dart';
import 'package:medora_git/features/auth/presentation/screens/login_screen.dart';
import 'package:medora_git/features/auth/presentation/screens/otp_screen.dart';
import 'package:medora_git/features/auth/presentation/screens/register_screen.dart';
import 'package:medora_git/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:medora_git/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:medora_git/features/chat/presentation/bindings/chat_bindings.dart';
import 'package:medora_git/features/chat/presentation/screens/chat_screen.dart';
import 'package:medora_git/features/chat/presentation/screens/conversations_screen.dart';
import 'package:medora_git/features/admin/presentation/bindings/admin_bindings.dart';
import 'package:medora_git/features/admin/presentation/screens/add_doctor_screen.dart';
import 'package:medora_git/features/admin/presentation/screens/add_offer_screen.dart';
import 'package:medora_git/features/admin/presentation/screens/admin_home_screen.dart';
import 'package:medora_git/features/admin/presentation/screens/edit_doctor_screen.dart';
import 'package:medora_git/features/doctor/presentation/bindings/doctor_bindings.dart';
import 'package:medora_git/features/doctor/presentation/screens/doctor_home_screen.dart';
import 'package:medora_git/features/doctor/presentation/screens/medical_record_screen.dart';
import 'package:medora_git/features/patient/presentation/bindings/booking_bindings.dart';
import 'package:medora_git/features/patient/presentation/bindings/doctor_discovery_bindings.dart';
import 'package:medora_git/features/patient/presentation/bindings/patient_account_bindings.dart';
import 'package:medora_git/features/patient/presentation/screens/booking_view.dart';
import 'package:medora_git/features/patient/presentation/screens/doctors_list_screen.dart';
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

     GetPage(name: AppRouter.main, page:()=>MainScreen(), bindings: [
       DoctorDiscoveryBindings(),
       PatientAccountBindings(),
     ]),
     GetPage(
      name: AppRouter.adminHome,
      page: () => const AdminHomeScreen(),
      binding: AdminBindings(),
    ),
    GetPage(
      name: AppRouter.addDoctor,
      page: () => AddDoctorScreen(),
      binding: AdminBindings(),
    ),
    GetPage(
      name: AppRouter.editDoctor,
      page: () => EditDoctorScreen(),
      binding: AdminBindings(),
    ),
    GetPage(
      name: AppRouter.addOffer,
      page: () => const AddOfferScreen(),
      binding: AdminBindings(),
    ),
    GetPage(
      name: AppRouter.doctorHome,
      page: () => const DoctorHomeScreen(),
      binding: DoctorBindings(),
    ),
    GetPage(
      name: AppRouter.medicalRecord,
      page: () => const MedicalRecordScreen(),
      binding: DoctorBindings(),
    ),
     GetPage(
      name: AppRouter.book,
      page: () =>  BookingView(),
      binding: BookingBindings(),
    ),
    GetPage(
      name: AppRouter.doctorsList,
      page: () => const DoctorsListScreen(),
      binding: DoctorDiscoveryBindings(),
    ),
    GetPage(
      name: AppRouter.conversations,
      page: () => const ConversationsScreen(),
      binding: ChatBindings(),
    ),
    GetPage(
      name: AppRouter.chat,
      page: () => const ChatScreen(),
      binding: ChatBindings(),
    ),
    GetPage(
      name: AppRouter.settings,
      page: () => const SettingsScreen(),
    ),
    // GetPage(name: AppRouter.patient, page:()=>PatientHomeScreen()),
    //  GetPage(
    //  name: AppRouter.book,
    //  page: () => BookingView(),
    //binding: BookingBindings(),
    //),
  ];
}
