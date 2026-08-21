import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medora_git/features/patient/business_layer/controller/booking_controller.dart';
import 'package:medora_git/features/patient/business_layer/controller/patient_account_controller.dart';
import 'package:medora_git/features/patient/data/models/active_offer_model.dart';
import 'package:medora_git/features/patient/data/models/add_booking_response_model.dart';
import 'package:medora_git/features/patient/data/models/appointment_record_model.dart';
import 'package:medora_git/features/patient/data/models/medical_record_model.dart';
import 'package:medora_git/features/patient/data/models/appointment_model.dart';
import 'package:medora_git/features/patient/data/models/doctor_model.dart';
import 'package:medora_git/features/patient/data/models/payment_success_response_model.dart';
import 'package:medora_git/features/patient/data/models/patient_profile_model.dart';
import 'package:medora_git/features/patient/data/src/booking_service.dart';
import 'package:medora_git/features/patient/data/src/patient_service.dart';
import 'package:medora_git/features/patient/presentation/screens/fatora_payment_screen.dart';

/// The exact post-payment redirect targets the backend bakes into every
/// Fatora checkout (AppointmentServices::generateFatoraLink) and its own
/// JSON callbacks.
class _BackendRedirects {
  static const gatewaySuccess = 'http://domain.com/payments/success';
  static const gatewayFailure = 'http://domain.com/payments/failure';
  static const backendSuccess =
      'http://10.2.0.2:8000/api/paymentSuccess?appointment_id=19';
  static const backendCancel =
      'http://10.2.0.2:8000/api/paymentCancel?appointment_id=19';
  static const checkoutPage =
      'https://maktapp.credit/pay/MCPaymentPage?paymentID=X85S3K7NRYH5401730457X8';
}

DoctorModel _doctor() {
  return DoctorModel(
    id: '3',
    name: 'Dr. Test',
    specialty: 'Cardiology',
    imageUrl: '',
    pricePerSession: 80,
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
      if (call.method == 'getApplicationDocumentsDirectory' ||
          call.method == 'getTemporaryDirectory') {
        return Directory.systemTemp.path;
      }
      return null;
    });
    await GetStorage.init();
    Get.testMode = true;
  });

  group('PaymentRedirectMatcher', () {
    test('gateway success redirect (backend placeholder URL) is a success', () {
      expect(
        PaymentRedirectMatcher.classify(_BackendRedirects.gatewaySuccess),
        PaymentRedirectOutcome.success,
      );
      expect(
        PaymentRedirectMatcher.classify(
          '${_BackendRedirects.gatewaySuccess}?paymentID=ABC123&status=paid',
        ),
        PaymentRedirectOutcome.success,
      );
    });

    test('gateway failure redirect is a failure', () {
      expect(
        PaymentRedirectMatcher.classify(_BackendRedirects.gatewayFailure),
        PaymentRedirectOutcome.failure,
      );
    });

    test('backend JSON callbacks are still intercepted as a safety net', () {
      expect(
        PaymentRedirectMatcher.classify(_BackendRedirects.backendSuccess),
        PaymentRedirectOutcome.success,
      );
      expect(
        PaymentRedirectMatcher.classify(_BackendRedirects.backendCancel),
        PaymentRedirectOutcome.failure,
      );
    });

    test('the checkout page itself and unrelated URLs are not intercepted',
        () {
      expect(
        PaymentRedirectMatcher.classify(_BackendRedirects.checkoutPage),
        PaymentRedirectOutcome.none,
      );
      expect(
        PaymentRedirectMatcher.classify(
          'https://maktapp.credit/pay/some/internal/route',
        ),
        PaymentRedirectOutcome.none,
      );
      expect(
        PaymentRedirectMatcher.classify('https://meet.google.com/abc-def-ghi'),
        PaymentRedirectOutcome.none,
      );
    });

    test('appointment id is read from appointment_id / order_id params', () {
      expect(
        PaymentRedirectMatcher.appointmentIdFrom(
          _BackendRedirects.backendSuccess,
        ),
        19,
      );
      expect(
        PaymentRedirectMatcher.appointmentIdFrom(
          '${_BackendRedirects.gatewaySuccess}?order_id=42',
        ),
        42,
      );
      expect(
        PaymentRedirectMatcher.appointmentIdFrom(
          _BackendRedirects.gatewaySuccess,
        ),
        isNull,
      );
    });
  });

  group('deposit flow finalisation', () {
    test('finalizeDepositPayment confirms the deposit without navigating',
        () async {
      final service = _FakeBookingService();
      final controller = BookingController(bookingService: service);
      Get.put(controller);
      addTearDown(Get.deleteAll);

      controller.selectDoctor(_doctor());
      controller.selectVisitType(VisitType.clinic);
      controller.selectDate(DateTime(2026, 9, 1));
      controller.selectTimeSlot('10:00');

      await controller.submitBooking();
      expect(controller.appointmentId.value, 19);

      final result =
          await controller.finalizeDepositPayment(appointmentId: 19);
      expect(service.paymentSuccessCalls, 1);
      expect(result.detailMessage, contains('confirmed'));
      expect(controller.appointmentId.value, 19,
          reason: 'finalize must leave navigation/state to the success screen');
    });
  });

  group('reminder flow finalisation', () {
    test('finalizeReminderPayment completes the final payment without '
        'navigating', () async {
      final service = _FakePatientService();
      final controller = PatientAccountController(service: service);
      Get.put(controller);
      addTearDown(Get.deleteAll);

      final result =
          await controller.finalizeReminderPayment(appointmentId: 20);
      expect(service.completeFinalCalls, 1);
      expect(result.message, contains('completed'));
    });
  });
}

class _FakeBookingService extends BookingService {
  int paymentSuccessCalls = 0;
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
        appointmentTime: '2026-09-01 10:00',
        status: 'pending_deposit',
      ),
      paymentUrl: _BackendRedirects.checkoutPage,
      amountToPayNow: 40,
    );
  }

  @override
  Future<PaymentSuccessResponseModel> paymentSuccess({
    required int appointmentId,
  }) async {
    paymentSuccessCalls++;
    return PaymentSuccessResponseModel(
      message: 'Payment successful',
      detailMessage: 'First deposit (50%) paid successfully. '
          'Appointment confirmed.',
    );
  }
}

class _FakePatientService extends PatientService {
  int completeFinalCalls = 0;

  @override
  Future<List<AppointmentRecordModel>> getPatientAppointments() async =>
      const [];

  @override
  Future<List<MedicalRecordModel>> getMedicalRecords() async => const [];

  @override
  Future<List<ActiveOfferModel>> getActiveOffers() async => const [];

  @override
  Future<PatientProfileModel> getMyProfile() async {
    return PatientProfileModel.fromJson(const {});
  }

  @override
  Future<PaymentSuccessResponseModel> completeFinalPayment({
    required int appointmentId,
  }) async {
    completeFinalCalls++;
    return PaymentSuccessResponseModel(
      message: 'Final payment completed and appointment marked as completed',
      detailMessage:
          'Final payment received. Remaining balance cleared and appointment '
          'completed.',
    );
  }
}
