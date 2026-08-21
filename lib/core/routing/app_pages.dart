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
import 'package:medora_git/features/admin/presentation/screens/doctor_details_screen.dart';
import 'package:medora_git/features/admin/presentation/screens/doctors_list_screen.dart';
import 'package:medora_git/features/admin/presentation/screens/edit_doctor_screen.dart';
import 'package:medora_git/features/admin/presentation/screens/inventory_screen.dart';
import 'package:medora_git/features/admin/presentation/screens/staff_dashboard_screen.dart';
import 'package:medora_git/features/doctor/presentation/bindings/doctor_bindings.dart';
import 'package:medora_git/features/doctor/presentation/screens/consultation_chat_screen.dart';
import 'package:medora_git/features/doctor/presentation/screens/doctor_appointment_details_screen.dart';
import 'package:medora_git/features/doctor/presentation/screens/doctor_appointments_screen.dart';
import 'package:medora_git/features/doctor/presentation/screens/doctor_consultations_screen.dart';
import 'package:medora_git/features/doctor/presentation/screens/doctor_invoices_screen.dart';
import 'package:medora_git/features/doctor/presentation/screens/doctor_main_screen.dart';
import 'package:medora_git/features/doctor/presentation/screens/doctor_patients_screen.dart';
import 'package:medora_git/features/doctor/presentation/screens/doctor_profile_screen.dart';
import 'package:medora_git/features/doctor/presentation/screens/doctor_schedule_edit_screen.dart';
import 'package:medora_git/features/doctor/presentation/screens/doctor_schedule_screen.dart';
import 'package:medora_git/features/doctor/presentation/screens/doctor_settings_screen.dart';
import 'package:medora_git/features/doctor/presentation/screens/medical_record_screen.dart';
import 'package:medora_git/features/notifications/presentation/bindings/notifications_bindings.dart';
import 'package:medora_git/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:medora_git/features/patient/presentation/screens/medical_file_screen.dart';
import 'package:medora_git/features/patient/presentation/screens/fatora_payment_screen.dart';
import 'package:medora_git/features/patient/presentation/screens/mock_payment_screen.dart';
import 'package:medora_git/features/patient/presentation/screens/payment_failure_screen.dart';
import 'package:medora_git/features/patient/presentation/screens/payment_result_screen.dart';
import 'package:medora_git/features/patient/presentation/screens/payment_success_screen.dart';
import 'package:medora_git/features/patient/presentation/bindings/booking_bindings.dart';
import 'package:medora_git/features/patient/presentation/bindings/doctor_discovery_bindings.dart';
import 'package:medora_git/features/patient/presentation/bindings/patient_account_bindings.dart';
import 'package:medora_git/features/patient/presentation/screens/booking_view.dart';
import 'package:medora_git/features/patient/presentation/screens/doctors_list_screen.dart';
import 'package:medora_git/features/patient/presentation/screens/main_screen.dart';
import 'package:medora_git/features/patient/presentation/screens/reminder_confirm_screen.dart';
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
       NotificationsBindings(),
     ]),
     GetPage(
      name: AppRouter.medicalFile,
      page: () => const MedicalFileScreen(),
      binding: PatientAccountBindings(),
    ),
     GetPage(
      name: AppRouter.reminderConfirm,
      page: () => const ReminderConfirmScreen(),
      binding: PatientAccountBindings(),
    ),
     GetPage(
      name: AppRouter.adminHome,
      page: () => const StaffDashboardScreen(),
      binding: AdminBindings(),
    ),
    GetPage(
      name: AppRouter.staffDoctors,
      page: () => const StaffDoctorsScreen(),
      binding: AdminBindings(),
    ),
    GetPage(
      name: AppRouter.staffDoctorDetails,
      page: () => const DoctorDetailsScreen(),
      binding: AdminBindings(),
    ),
    GetPage(
      name: AppRouter.staffInventory,
      page: () => const InventoryScreen(),
      binding: AdminBindings(),
    ),
    GetPage(
      name: AppRouter.staffOffers,
      page: () => const AddOfferScreen(),
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
      page: () => const DoctorMainScreen(),
      bindings: [
        DoctorBindings(),
        NotificationsBindings(),
      ],
    ),
    GetPage(
      name: AppRouter.doctorNotifications,
      page: () => const NotificationsScreen(),
      binding: NotificationsBindings(),
    ),
    GetPage(
      name: AppRouter.doctorAppointments,
      page: () => const DoctorAppointmentsScreen(),
      binding: DoctorBindings(),
    ),
    GetPage(
      name: AppRouter.doctorAppointmentDetails,
      page: () => const DoctorAppointmentDetailsScreen(),
      binding: DoctorBindings(),
    ),
    GetPage(
      name: AppRouter.doctorConsultations,
      page: () => const DoctorConsultationsScreen(),
      binding: DoctorBindings(),
    ),
    GetPage(
      name: AppRouter.doctorConsultationChat,
      page: () => const ConsultationChatScreen(),
      bindings: [
        ChatBindings(),
        DoctorBindings(),
      ],
    ),
    GetPage(
      name: AppRouter.doctorPatients,
      page: () => const DoctorPatientsScreen(),
      binding: DoctorBindings(),
    ),
    GetPage(
      name: AppRouter.doctorSchedule,
      page: () => const DoctorScheduleScreen(),
      binding: DoctorBindings(),
    ),
    GetPage(
      name: AppRouter.doctorScheduleEdit,
      page: () => const DoctorScheduleEditScreen(),
      binding: DoctorBindings(),
    ),
    GetPage(
      name: AppRouter.doctorInvoices,
      page: () => const DoctorInvoicesScreen(),
      binding: DoctorBindings(),
    ),
    GetPage(
      name: AppRouter.doctorSettings,
      page: () => const DoctorSettingsScreen(),
      binding: DoctorBindings(),
    ),
    GetPage(
      name: AppRouter.doctorProfile,
      page: () => const DoctorProfileScreen(),
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
      name: AppRouter.paymentResult,
      page: () => const PaymentResultScreen(),
    ),
    GetPage(
      name: AppRouter.mockPayment,
      page: () => const MockPaymentScreen(),
    ),
    GetPage(
      name: AppRouter.paymentSuccessScreen,
      page: () => const PaymentSuccessScreen(),
    ),
    GetPage(
      name: AppRouter.paymentFailureScreen,
      page: () => const PaymentFailureScreen(),
    ),
    GetPage(
      name: AppRouter.fatoraPayment,
      page: () => const FatoraPaymentScreen(),
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
