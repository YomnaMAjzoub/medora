import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medora_git/features/patient/data/models/app_confirm_response_model.dart';
import 'package:medora_git/features/patient/data/models/appointment_model.dart';
import 'package:medora_git/features/patient/data/models/complete_final_payment_response_model.dart';
import 'package:medora_git/features/patient/data/models/doctor_model.dart';
import 'package:medora_git/features/patient/data/models/payment_success_response_model.dart';
import 'package:medora_git/features/patient/data/src/booking_service.dart';

enum BookingStep { selectDoctor, visitType, homeLocation, dateTime, payment }

class BookingController extends GetxController {
  BookingController({BookingService? bookingService})
      : _bookingService = bookingService ?? BookingService();

  final BookingService _bookingService;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxInt currentStep = 0.obs;

  List<BookingStep> get steps {
    return [
      BookingStep.selectDoctor,
      BookingStep.visitType,
      if (selectedVisitType.value == VisitType.home) BookingStep.homeLocation,
      BookingStep.dateTime,
      BookingStep.payment,
    ];
  }

  BookingStep get currentBookingStep => steps[currentStep.value];

  // ---- Step 1: doctor ----
  final Rx<DoctorModel?> selectedDoctor = Rx<DoctorModel?>(null);

  void selectDoctor(DoctorModel doctor) {
    selectedDoctor.value = doctor;
    goToNextStep();
  }

  // ---- Step 2: visit type ----
  final Rx<VisitType?> selectedVisitType = Rx<VisitType?>(null);

  /// Only the visit types the selected doctor actually supports.
  List<VisitType> get availableVisitTypes {
    final doctor = selectedDoctor.value;
    if (doctor == null) return [];
    const order = [VisitType.clinic, VisitType.home, VisitType.online];
    return order.where(doctor.supports).toList();
  }

  void selectVisitType(VisitType type) {
    selectedVisitType.value = type;
    if (type != VisitType.home) {
      homeVisitAddress.value = null;
      homeVisitLatLng.value = null;
    }
    goToNextStep();
  }

  // ---- Step 3: home location (only when visit type == home) ----
  final Rxn<LatLng> homeVisitLatLng = Rxn<LatLng>();
  final RxnString homeVisitAddress = RxnString();
  final RxnInt locationId = RxnInt();

  Future<void> confirmHomeLocation({
    required LatLng location,
    required String address,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _bookingService.addLocation(
        address: address,
        latitude: location.latitude.toString(),
        longitude: location.longitude.toString(),
      );
      locationId.value = result.location.id;
      homeVisitLatLng.value = location;
      homeVisitAddress.value = address;
      goToNextStep();
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ---- Step 4: date & time ----
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final RxnString selectedTimeSlot = RxnString();

  void selectDate(DateTime date) {
    selectedDate.value = date;
    selectedTimeSlot.value = null;
  }

  void selectTimeSlot(String time) {
    selectedTimeSlot.value = time;
  }

  void confirmDateTime() {
    if (selectedDate.value == null || selectedTimeSlot.value == null) return;
    goToNextStep();
  }

  final RxnInt appointmentId = RxnInt();
  final RxnString paymentUrl = RxnString();
  final RxInt amountToPayNow = 0.obs;
  final Rxn<PaymentSuccessResponseModel> paymentResult = Rxn<PaymentSuccessResponseModel>();

  /// Called after the payment redirect returns; confirms the booking server-side.
  Future<void> confirmPaymentSuccess() async {
    final id = appointmentId.value;
    if (id == null) {
      Get.snackbar('Warning', 'No appointment to confirm.');
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _bookingService.paymentSuccess(appointmentId: id);
      paymentResult.value = result;
      Get.snackbar('Success', result.data.message);
      resetBooking();
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  final Rxn<AppConfirmResponseModel> appConfirmResult =
      Rxn<AppConfirmResponseModel>();
  final Rxn<CompleteFinalPaymentResponseModel> finalPaymentResult =
      Rxn<CompleteFinalPaymentResponseModel>();

  Future<void> completeFinalPayment() async {
    final id = appointmentId.value;
    if (id == null) {
      Get.snackbar('Warning', 'No appointment to finalize.');
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _bookingService.completeFinalPayment(
        appointmentId: id,
      );
      finalPaymentResult.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> confirmAppointment() async {
    final id = appointmentId.value;
    if (id == null) {
      Get.snackbar('Warning', 'No appointment to confirm.');
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _bookingService.confirmAppointment(
        appointmentId: id,
      );
      appConfirmResult.value = result;
      if (result.paymentUrl.isNotEmpty) {
        paymentUrl.value = result.paymentUrl;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitBooking() async {
    final doctor = selectedDoctor.value;
    final visitType = selectedVisitType.value;
    final date = selectedDate.value;
    final timeSlot = selectedTimeSlot.value;
    if (doctor == null || visitType == null || date == null || timeSlot == null) {
      Get.snackbar('Warning', 'Please complete booking details first.');
      return;
    }
    if (visitType == VisitType.home && locationId.value == null) {
      Get.snackbar('Warning', 'Home bookings require a saved location first.');
      return;
    }
    final doctorId = int.tryParse(doctor.id);
    if (doctorId == null) {
      Get.snackbar('Error', 'Invalid doctor id.');
      return;
    }
    // Combines the picked day with the picked time (slot format "HH:mm").
    final timeParts = timeSlot.split(':');
    final appointmentTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _bookingService.addBooking(
        doctorId: doctorId,
        type: visitType,
        appointmentTime: appointmentTime,
        locationId: locationId.value,
      );
      appointmentId.value = result.appointment.id;
      paymentUrl.value = result.paymentUrl;
      amountToPayNow.value = result.amountToPayNow;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  var consultationFee = 100.0.obs; // مثال
  double get depositAmount => consultationFee.value * 0.5;

  /// Submits the booking (if not yet done), opens the gateway payment page,
  /// then asks the user to confirm once they return from the gateway.
  Future<void> payNow() async {
    if (appointmentId.value == null) {
      await submitBooking();
    }
    final url = paymentUrl.value;
    if (url == null || url.isEmpty) {
      if (errorMessage.value.isEmpty) {
        Get.snackbar('Warning', 'Unable to start payment.');
      }
      return;
    }

    final launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      Get.snackbar('Error', 'Could not open the payment page.');
      return;
    }

    _showPaymentReturnDialog();
  }

  void _showPaymentReturnDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Payment'),
        content: const Text('Did you complete the payment?'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              confirmPaymentSuccess();
            },
            child: const Text('Yes, I paid'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Not yet'),
          ),
        ],
      ),
    );
  }

  void resetBooking() {
    currentStep.value = 0;
    selectedDoctor.value = null;
    selectedVisitType.value = null;
    homeVisitLatLng.value = null;
    homeVisitAddress.value = null;
    selectedDate.value = null;
    selectedTimeSlot.value = null;
    locationId.value = null;
    appointmentId.value = null;
    paymentUrl.value = null;
    amountToPayNow.value = 0;
    paymentResult.value = null;
    appConfirmResult.value = null;
    finalPaymentResult.value = null;
    depositAmount; // Reset deposit amount if needed
  }

  // ---- Navigation ----
  void goToNextStep() {
    if (currentStep.value < steps.length - 1) currentStep.value++;
  }

  void goToPreviousStep() {
    if (currentStep.value > 0) currentStep.value--;
  }
}
