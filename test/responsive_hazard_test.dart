import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/doctor/business_layer/controller/doctor_controller.dart';
import 'package:medora_git/features/doctor/data/models/doctor_appointment_model.dart';
import 'package:medora_git/features/doctor/data/models/doctor_invoice_model.dart';
import 'package:medora_git/features/doctor/data/models/doctor_patient_model.dart';
import 'package:medora_git/features/doctor/data/models/doctor_work_schedule_model.dart';
import 'package:medora_git/features/doctor/data/src/doctor_service.dart';
import 'package:medora_git/features/doctor/presentation/screens/doctor_profile_screen.dart';
import 'package:medora_git/features/patient/business_layer/controller/doctor_discovery_controller.dart';
import 'package:medora_git/features/patient/business_layer/controller/patient_account_controller.dart';
import 'package:medora_git/features/patient/data/models/active_offer_model.dart';
import 'package:medora_git/features/patient/data/models/appointment_record_model.dart';
import 'package:medora_git/features/patient/data/models/doctor_profile_model.dart';
import 'package:medora_git/features/patient/data/models/medical_record_model.dart';
import 'package:medora_git/features/patient/data/models/specialization_model.dart';
import 'package:medora_git/features/patient/data/src/patient_service.dart';
import 'package:medora_git/features/patient/presentation/screens/appointments_screen.dart';
import 'package:medora_git/features/patient/presentation/screens/patient_home_screen.dart';

class _FakePatientService extends PatientService {
  @override
  Future<List<DoctorProfileModel>> getAllDoctorsForPatient() async => const [];

  @override
  Future<List<SpecializationModel>> getSpecializations() async => const [
        SpecializationModel(name: 'Cardiovascular Surgery'),
        SpecializationModel(name: 'General Practitioner'),
        SpecializationModel(name: 'Dentistry'),
      ];

  @override
  Future<List<AppointmentRecordModel>> getPatientAppointments() async => [
        AppointmentRecordModel(
          id: 1,
          patientId: 1,
          doctorId: 1,
          locationId: null,
          type: 'clinic',
          appointmentTime: DateTime.now().add(const Duration(days: 1)),
          status: AppointmentStatus.confirmed,
          createdAt: DateTime.now(),
          doctor: null,
        ),
      ];

  @override
  Future<List<MedicalRecordModel>> getMedicalRecords() async => const [];

  @override
  Future<List<ActiveOfferModel>> getActiveOffers() async => const [];
}

class _FakeDoctorService extends DoctorService {
  @override
  Future<List<DoctorAppointmentModel>> getAppointments({
    String? period,
    String? type,
  }) async =>
      const [];

  @override
  Future<List<DoctorAppointmentModel>> getConsultations() async => const [];

  @override
  Future<List<DoctorPatientModel>> getPatients() async => const [];

  @override
  Future<DoctorWorkScheduleModel> getSchedule() async =>
      const DoctorWorkScheduleModel(
        workingDays: [],
        daysOff: [],
        peakHours: [],
      );

  @override
  Future<List<DoctorInvoiceModel>> getInvoices() async => const [];

  @override
  Future<DoctorProfileModel> getMyProfile() async => DoctorProfileModel(
        id: 1,
        userId: 1,
        profilePhoto: '',
        specialization: 'Cardiovascular Surgery',
        isAvailable: true,
        homeVisit: true,
        firstName: 'Ahmed',
        lastName: 'Hassan',
        gender: 'male',
        schedules: const [],
      );
}

/// Regression tests for Bug 4: the specific layouts that used to throw
/// RenderFlex overflows at small-phone (320px) widths.
void main() {
  const smallPhone = Size(320, 568);

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return Directory.systemTemp.path;
      }
      return null;
    });
    await GetStorage.init();
  });

  Future<void> pump(WidgetTester tester, Widget home) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    tester.view.physicalSize = smallPhone;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: GetMaterialApp(
          theme: AppTheme.light,
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Bug 4 responsive hazards at 320px', () {
    testWidgets('confirmed appointments render without overflow at 320px',
        (tester) async {
      final account = PatientAccountController(service: _FakePatientService());
      Get.put(account);
      addTearDown(Get.deleteAll);
      await pump(tester, const AppointmentsScreen());
      await tester.tap(find.text('confirmed_schedules'));
      await tester.pumpAndSettle();
      expect(find.text('no_appointments'), findsNothing,
          reason: 'the seeded confirmed appointment should be visible');
      expect(tester.takeException(), isNull);
    });

    testWidgets('patient home specialties grid fits long names',
        (tester) async {
      Get.put(PatientAccountController(service: _FakePatientService()));
      Get.put(
        DoctorDiscoveryController(service: _FakePatientService()),
      );
      addTearDown(Get.deleteAll);
      await pump(tester, const PatientHomeScreen());
      expect(find.text('Cardiovascular Surgery'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('doctor profile personal/work buttons fit side by side',
        (tester) async {
      Get.put(DoctorController(service: _FakeDoctorService()));
      addTearDown(Get.deleteAll);
      await pump(tester, const DoctorProfileScreen());
      expect(find.text('personal_info'), findsOneWidget);
      expect(find.text('work_info'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}