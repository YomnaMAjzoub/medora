import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/doctor/business_layer/controller/doctor_controller.dart';
import 'package:medora_git/features/doctor/data/models/doctor_appointment_model.dart';
import 'package:medora_git/features/doctor/data/models/doctor_invoice_model.dart';
import 'package:medora_git/features/doctor/data/models/doctor_patient_model.dart';
import 'package:medora_git/features/doctor/data/models/doctor_work_schedule_model.dart';
import 'package:medora_git/features/doctor/data/src/doctor_service.dart';
import 'package:medora_git/features/doctor/presentation/screens/doctor_home_screen.dart';
import 'package:medora_git/features/patient/data/models/doctor_profile_model.dart';

class _FakeDoctorService extends DoctorService {
  final List<DoctorAppointmentModel> rows;
  int fetchAppointmentsCalls = 0;

  _FakeDoctorService(this.rows);

  @override
  Future<List<DoctorAppointmentModel>> getAppointments({
    String? period,
    String? type,
  }) async {
    fetchAppointmentsCalls++;
    return rows;
  }

  @override
  Future<List<DoctorAppointmentModel>> getConsultations() async => const [];

  @override
  Future<List<DoctorPatientModel>> getPatients() async => const [];

  @override
  Future<DoctorWorkScheduleModel> getSchedule() async =>
      DoctorWorkScheduleModel(
        workingDays: const [],
        daysOff: const [],
        peakHours: const [],
      );

  @override
  Future<List<DoctorInvoiceModel>> getInvoices() async => const [];

  @override
  Future<DoctorProfileModel> getMyProfile() async {
    return DoctorProfileModel(
      id: 5,
      userId: 4,
      profilePhoto: '',
      specialization: '',
      isAvailable: true,
      homeVisit: false,
      firstName: 'Ali',
      lastName: 'Doctor',
      gender: 'male',
      schedules: const [],
    );
  }
}

/// Builds the exact row the backend returned for GET /appointmentForDoctor,
/// with the appointment time moved to today so the "today" stats count it.
Map<String, dynamic> _realPayloadRow() {
  final now = DateTime.now();
  final time = DateTime(now.year, now.month, now.day, 16, 0);
  String pad(int v) => v.toString().padLeft(2, '0');
  final appointmentTime =
      '${time.year}-${pad(time.month)}-${pad(time.day)} '
      '${pad(time.hour)}:${pad(time.minute)}:00';
  return {
    'id': 20,
    'patient_id': 18,
    'doctor_id': 5,
    'location_id': null,
    'type': 'clinic',
    'appointment_time': appointmentTime,
    'status': 'completed',
    'created_at': '2026-08-19T14:22:14.000000Z',
    'updated_at': '2026-08-19T14:27:00.000000Z',
    'patient': {
      'id': 18,
      'first_name': 'yomna',
      'last_name': 'mj',
      'birth': '2000-01-03',
      'phone': '0977777777',
      'gender': 'female',
      'email': 'yomnamajzoub@gmail.com',
      'role': 'patient',
      'is_verified': 1,
      'email_verified_at': null,
      'fcm_token': 'x',
      'created_at': '2026-08-18T14:30:02.000000Z',
      'updated_at': '2026-08-18T14:31:20.000000Z',
    },
    'location': null,
  };
}

void main() {
  setUp(() {
    Get.reset();
  });

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

  Future<void> pumpDashboard(
    WidgetTester tester, {
    required List<Map<String, dynamic>> payload,
  }) async {
    Get.put(
      DoctorController(
        service: _FakeDoctorService(
          payload
              .map(DoctorAppointmentModel.fromJson)
              .toList(),
        ),
      ),
    );
    addTearDown(Get.deleteAll);
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: GetMaterialApp(
          theme: AppTheme.light,
          home: const DoctorHomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('dashboard renders a real appointmentForDoctor row', (
    tester,
  ) async {
    await pumpDashboard(tester, payload: [_realPayloadRow()]);

    expect(find.text('yomna mj'), findsOneWidget);
    expect(find.textContaining('Clinic'), findsOneWidget);
    expect(find.text('completed'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('dashboard shows empty state when appointmentForDoctor is empty', (
    tester,
  ) async {
    await pumpDashboard(tester, payload: const []);

    expect(find.text('no_appointments_today'), findsOneWidget);
  });

  testWidgets('pull-to-refresh re-fetches appointments from the API', (
    tester,
  ) async {
    final service = _FakeDoctorService(
      [_realPayloadRow()].map(DoctorAppointmentModel.fromJson).toList(),
    );
    Get.put(DoctorController(service: service));
    addTearDown(Get.deleteAll);
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: GetMaterialApp(
          theme: AppTheme.light,
          home: const DoctorHomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(service.fetchAppointmentsCalls, 1);

    await tester.dragFrom(
      tester.getTopLeft(find.byType(ListView)) + const Offset(200, 10),
      const Offset(0, 800),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(service.fetchAppointmentsCalls, greaterThan(1));
  });
}