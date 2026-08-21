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
import 'package:medora_git/features/patient/business_layer/controller/booking_controller.dart';
import 'package:medora_git/features/patient/data/models/add_booking_response_model.dart';
import 'package:medora_git/features/patient/data/models/appointment_model.dart';
import 'package:medora_git/features/patient/data/models/doctor_model.dart';
import 'package:medora_git/features/patient/data/models/location_model.dart';
import 'package:medora_git/features/patient/data/models/payment_success_response_model.dart';
import 'package:medora_git/features/patient/data/src/booking_service.dart';

class _FakeBookingService extends BookingService {
  int paymentSuccessCalls = 0;

  static const fatoraUrl =
      'https://maktapp.credit/pay/MCPaymentPage?paymentID=XQI79Z5ZYO3D51729566XQ';

  /// When false, addBooking returns no payment_url (gateway link
  /// generation failed server-side), so the flow must fall back to the
  /// in-app mock payment.
  final bool returnPaymentUrl;

  _FakeBookingService({this.returnPaymentUrl = true});

  @override
  Future<AddLocationResponseModel> addLocation({
    required String address,
    required String latitude,
    required String longitude,
  }) async {
    return AddLocationResponseModel(
      message: 'ok',
      location: LocationModel(
        id: 7,
        userId: 18,
        address: address,
        latitude: latitude,
        longitude: longitude,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<AddBookingResponseModel> addBooking({
    required int doctorId,
    required VisitType type,
    required DateTime appointmentTime,
    int? locationId,
  }) async {
    return AddBookingResponseModel(
      appointment: BookingAppointmentModel(
        id: 19,
        patientId: 18,
        doctorId: '$doctorId',
        type: type.name,
        appointmentTime:
            '${appointmentTime.year}-${appointmentTime.month}-${appointmentTime.day} '
            '${appointmentTime.hour}:${appointmentTime.minute}',
        status: 'pending_deposit',
        locationId: locationId,
      ),
      paymentUrl: returnPaymentUrl ? fatoraUrl : '',
      amountToPayNow: 5,
    );
  }

  @override
  Future<PaymentSuccessResponseModel> paymentSuccess({
    required int appointmentId,
  }) async {
    paymentSuccessCalls++;
    return PaymentSuccessResponseModel(
      message: 'Payment successful',
      detailMessage: 'First deposit (50%) paid successfully.',
      appointment: BookingAppointmentModel(
        id: appointmentId,
        patientId: 18,
        doctorId: '4',
        type: 'clinic',
        appointmentTime: '2026-08-20 10:00',
        status: 'confirmed',
      ),
      payment: PaymentModel(
        id: 1,
        appointmentId: appointmentId,
        totalAmount: '10',
        amountPaid: '5',
        remainingAmount: '5',
        method: 'fatora',
        status: 'paid',
      ),
    );
  }
}

DoctorModel _doctor() {
  return DoctorModel(
    id: '4',
    name: 'Dr. Test',
    specialty: 'Cardiology',
    imageUrl: '',
    pricePerSession: 10,
    rating: 4.5,
    reviewsCount: 12,
    experienceYears: 5,
    supportedVisitTypes: const [VisitType.clinic],
    isTopRated: false,
  );
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

  Future<BookingController> pumpApp(
    WidgetTester tester, {
    BookingService? service,
  }) async {
    final controller = BookingController(bookingService: service);
    Get.put(controller);
    addTearDown(Get.deleteAll);
    // The real FatoraPaymentScreen needs a WebView platform and MainScreen
    // needs full bindings; stub both routes so the controller's navigation
    // decisions can be asserted in tests.
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
    return controller;
  }

  void fillBooking(BookingController controller) {
    controller.selectDoctor(_doctor());
    controller.selectVisitType(VisitType.clinic);
    controller.selectDate(DateTime(2026, 8, 20));
    controller.selectTimeSlot('10:00');
  }

  group('Bug 5 Fatora payment flow', () {
    testWidgets('addBooking stores the real payment_url from the backend',
        (tester) async {
      final service = _FakeBookingService();
      final controller = await pumpApp(tester, service: service);
      fillBooking(controller);

      await controller.submitBooking();

      expect(controller.appointmentId.value, 19);
      expect(controller.paymentUrl.value, _FakeBookingService.fatoraUrl);
      expect(controller.amountToPayNow.value, 5);
    });

    testWidgets('payNow opens the Fatora checkout when a payment_url exists',
        (tester) async {
      final service = _FakeBookingService();
      final controller = await pumpApp(tester, service: service);
      fillBooking(controller);

      await controller.payNow();
      await tester.pumpAndSettle();

      expect(controller.appointmentId.value, 19);
      expect(controller.paymentUrl.value, isNotEmpty);
      expect(service.paymentSuccessCalls, 0,
          reason: 'paymentSuccess must not be called before the checkout');
      // The booking stays pending until the WebView checkout completes.
      expect(controller.appointmentId.value, 19);
      expect(Get.currentRoute, AppRouter.fatoraPayment,
          reason: 'payNow must open the Fatora checkout page');
      expect(find.text('fatora-checkout-stub'), findsOneWidget);
    });

    testWidgets(
        'payNow falls back to the mock payment when no payment_url exists',
        (tester) async {
      final service = _FakeBookingService(returnPaymentUrl: false);
      final controller = await pumpApp(tester, service: service);
      fillBooking(controller);

      await controller.submitBooking();
      await controller.payNow();
      // Let the gateway-unavailable snackbar expire (3s timer) before
      // settling, otherwise its timer stays pending.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      expect(service.paymentSuccessCalls, 0,
          reason: 'the mock screen must not confirm the payment by itself');
      expect(Get.currentRoute, AppRouter.mockPayment,
          reason: 'without a checkout URL the in-app mock payment is used');
    });

    testWidgets(
        'finalizeDepositPayment calls paymentSuccess without navigating',
        (tester) async {
      final service = _FakeBookingService();
      final controller = await pumpApp(tester, service: service);
      fillBooking(controller);
      await controller.submitBooking();

      final result =
          await controller.finalizeDepositPayment(appointmentId: 19);
      await tester.pump(const Duration(seconds: 4));

      expect(service.paymentSuccessCalls, 1);
      expect(result.appointment?.status, 'confirmed',
          reason: 'the backend response carries the confirmed appointment');
      expect(controller.appointmentId.value, 19,
          reason: 'finalize must not reset the booking state by itself');
    });
  });
}