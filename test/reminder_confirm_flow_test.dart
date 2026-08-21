import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medora_git/core/routing/app_pages.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/patient/business_layer/controller/patient_account_controller.dart';
import 'package:medora_git/features/patient/data/models/active_offer_model.dart';
import 'package:medora_git/features/patient/data/models/appointment_record_model.dart';
import 'package:medora_git/features/patient/data/models/medical_record_model.dart';
import 'package:medora_git/features/patient/data/models/payment_success_response_model.dart';
import 'package:medora_git/features/patient/data/src/patient_service.dart';

class _FakePatientService extends PatientService {
  int confirmCalls = 0;
  int completeFinalCalls = 0;

  static const fatoraUrl =
      'https://maktapp.credit/pay/MCPaymentPage?paymentID=M7HVQ0KLMHNW42.51729642M7';

  /// When true, app-confirm returns the real payment_url the backend sends
  /// after the appointment is confirmed ("please complete payment").
  bool returnPaymentUrl;

  _FakePatientService({this.returnPaymentUrl = true});

  @override
  Future<List<AppointmentRecordModel>> getPatientAppointments() async =>
      const [];

  @override
  Future<List<MedicalRecordModel>> getMedicalRecords() async => const [];

  @override
  Future<List<ActiveOfferModel>> getActiveOffers() async => const [];

  @override
  Future<AppointmentConfirmResult> confirmAfterReminder({
    required int appointmentId,
  }) async {
    confirmCalls++;
    return AppointmentConfirmResult(
      status: 'success',
      message: 'Appointment status updated to confirmed, '
          'please complete payment.',
      paymentUrl: returnPaymentUrl ? fatoraUrl : null,
    );
  }

  @override
  Future<PaymentSuccessResponseModel> completeFinalPayment({
    required int appointmentId,
  }) async {
    completeFinalCalls++;
    return PaymentSuccessResponseModel(
      message: 'Final payment completed and appointment marked as completed',
      detailMessage: 'Final payment received. Remaining balance cleared '
          'and appointment completed.',
    );
  }
}

void main() {
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

  Future<PatientAccountController> pumpApp(
    WidgetTester tester, {
    required _FakePatientService service,
  }) async {
    final controller = PatientAccountController(service: service);
    Get.put(controller);
    addTearDown(Get.deleteAll);
    // Stub the heavy routes: the real FatoraPaymentScreen needs a WebView
    // platform and MainScreen needs full bindings.
    final pages = AppPages.pages
        .map(
          (p) => switch (p.name) {
            AppRouter.fatoraPayment => GetPage(
                name: AppRouter.fatoraPayment,
                page: () => const Scaffold(
                  body: Center(child: Text('fatora-checkout-stub')),
                ),
              ),
            AppRouter.main => GetPage(
                name: AppRouter.main,
                page: () => const Scaffold(
                  body: Center(child: Text('main-stub')),
                ),
              ),
            _ => p,
          },
        )
        .toList();
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: GetMaterialApp(
          theme: AppTheme.light,
          getPages: pages,
          home: const Scaffold(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return controller;
  }

  group('Bug 6 reminder confirmation flow', () {
    testWidgets('app-confirm with payment_url opens the Fatora checkout', (
      tester,
    ) async {
      final service = _FakePatientService();
      final controller = await pumpApp(tester, service: service);

      await controller.confirmReminderAppointment(appointmentId: 20);
      await tester.pumpAndSettle();

      expect(service.confirmCalls, 1);
      expect(Get.currentRoute, AppRouter.fatoraPayment,
          reason: 'a payment_url must open the Fatora checkout');
      expect(find.text('fatora-checkout-stub'), findsOneWidget);
    });

    testWidgets('app-confirm without payment_url opens the mock payment', (
      tester,
    ) async {
      final service = _FakePatientService(returnPaymentUrl: false);
      final controller = await pumpApp(tester, service: service);

      await controller.confirmReminderAppointment(appointmentId: 20);
      await tester.pumpAndSettle();

      expect(service.confirmCalls, 1);
      expect(service.completeFinalCalls, 0);
      expect(Get.currentRoute, AppRouter.mockPayment,
          reason:
              'without a checkout URL the in-app mock payment is the fallback');
    });

    testWidgets('completeReminderPayment finalises and returns to appointments', (
      tester,
    ) async {
      final service = _FakePatientService();
      final controller = await pumpApp(tester, service: service);

      await controller.completeReminderPayment(appointmentId: 20);
      await tester.pumpAndSettle();
      // Let the snackbar timer expire and its dismiss animation finish.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      expect(service.completeFinalCalls, 1,
          reason: 'the remaining payment is finalised via completeFinalPayment');
      expect(Get.currentRoute, AppRouter.main,
          reason: 'a completed reminder payment returns to the appointments tab');
      expect(find.text('main-stub'), findsOneWidget);
    });

    testWidgets(
        'finalizeReminderPayment calls completeFinalPayment without navigating',
        (tester) async {
      final service = _FakePatientService();
      final controller = await pumpApp(tester, service: service);

      await controller.finalizeReminderPayment(appointmentId: 20);
      await tester.pump(const Duration(seconds: 4));

      expect(service.completeFinalCalls, 1);
      expect(Get.currentRoute, isNot(AppRouter.main),
          reason: 'finalize must leave navigation to the payment success '
              'screen');
    });
  });
}