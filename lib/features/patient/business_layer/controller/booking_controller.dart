import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/features/patient/business_layer/controller/doctor_discovery_controller.dart';
import 'package:medora_git/features/patient/data/models/appointment_model.dart';
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

  @override
  void onInit() {
    super.onInit();
    _preselectDoctorFromArguments();
  }

  /// Picks the doctor passed via Get.arguments (doctor_id / doctorId)
  /// when the booking flow is opened from a doctor list, matching the
  /// argument convention used by DoctorCalendarController.
  void _preselectDoctorFromArguments() {
    final args = Get.arguments;
    if (args is! Map) return;
    final rawId = args['doctor_id'] ?? args['doctorId'];
    final id = int.tryParse(rawId.toString());
    if (id == null) return;
    if (!Get.isRegistered<DoctorDiscoveryController>()) return;
    final doctor = Get.find<DoctorDiscoveryController>()
        .doctors
        .firstWhereOrNull((d) => d.id == id.toString());
    if (doctor != null) {
      selectedDoctor.value = doctor;
      currentStep.value = 1;
    }
  }

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
      Get.snackbar('error'.tr(), e.toString());
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

  /// Fatora checkout URL returned by the backend from POST /addBooking.
  final RxnString paymentUrl = RxnString();

  /// Amount the backend expects up front (deposit), when it reports one.
  final RxInt amountToPayNow = 0.obs;

  /// The last simulated-payment result, shown on the in-app result screen.
  final Rxn<PaymentSuccessResponseModel> paymentResult =
      Rxn<PaymentSuccessResponseModel>();

  /// The doctor's real session price, used for the payment summary.
  /// (The old hardcoded 100.0 placeholder was removed.)
  double get consultationFee =>
      selectedDoctor.value?.pricePerSession ?? 0;

  /// The booking flow charges 50% of the session price up front.
  double get depositAmount => consultationFee * 0.5;

  /// Creates the booking on the backend (addBooking) and keeps the
  /// created appointment id for the payment step.
  Future<void> submitBooking() async {
    final doctor = selectedDoctor.value;
    final visitType = selectedVisitType.value;
    final date = selectedDate.value;
    final timeSlot = selectedTimeSlot.value;
    if (doctor == null ||
        visitType == null ||
        date == null ||
        timeSlot == null) {
      Get.snackbar('warning'.tr(), 'complete_booking_first'.tr());
      return;
    }
    if (visitType == VisitType.home && locationId.value == null) {
      Get.snackbar('warning'.tr(), 'home_booking_needs_location'.tr());
      return;
    }
    final doctorId = doctor.userId ?? int.tryParse(doctor.id);
    if (doctorId == null) {
      Get.snackbar('error'.tr(), 'invalid_doctor_id'.tr());
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
      if (result.appointment.id == 0) {
        Get.snackbar('error'.tr(), 'booking_failed'.tr());
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Creates the booking if needed, then opens the in-app MOCK payment
  /// screen for the deposit. The backend has no redirect-URL parameter on
  /// its payment endpoints, so the mock flow is synchronous: the screen
  /// calls GET /paymentSuccess?appointment_id=... when the patient confirms,
  /// which is what moves the appointment to 'confirmed' server-side.
  Future<void> payNow() async {
    if (appointmentId.value == null) {
      await submitBooking();
    }
    final id = appointmentId.value;
    if (id == null || id == 0) {
      if (errorMessage.value.isEmpty) {
        Get.snackbar('warning'.tr(), 'unable_start_payment'.tr());
      }
      return;
    }

    Get.toNamed(
      AppRouter.mockPayment,
      arguments: {
        'appointmentId': id,
        'amount': amountToPayNow.value > 0
            ? amountToPayNow.value.toStringAsFixed(2)
            : depositAmount.toStringAsFixed(2),
        'doctorName': selectedDoctor.value?.name ?? '',
        'mode': 'deposit',
      },
    );
  }

  /// Called by the mock payment screen after the patient confirms the
  /// deposit. GET /paymentSuccess marks the payment partially_paid and the
  /// appointment 'confirmed'; the backend response (message, appointment,
  /// payment amounts) is shown on the in-app result screen.
  Future<bool> payDeposit({required int appointmentId}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _bookingService.paymentSuccess(
        appointmentId: appointmentId,
      );
      paymentResult.value = result;
      final doctorName = selectedDoctor.value?.name ?? '';
      resetBooking();
      Get.offNamed(
        AppRouter.paymentResult,
        arguments: {'result': result, 'doctorName': doctorName},
      );
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Called by the Fatora WebView when the checkout redirected to
  /// /paymentSuccess. Confirms the booking on the backend and shows the
  /// in-app result screen.
  Future<void> confirmPaymentAfterWebview({int? appointmentId}) async {
    final id = appointmentId ?? this.appointmentId.value;
    if (id == null || id == 0) {
      Get.snackbar('warning'.tr(), 'unable_start_payment'.tr());
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _bookingService.paymentSuccess(appointmentId: id);
      paymentResult.value = result;
      final doctorName = selectedDoctor.value?.name ?? '';
      resetBooking();
      Get.toNamed(
        AppRouter.paymentResult,
        arguments: {'result': result, 'doctorName': doctorName},
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Called by the Fatora WebView when the checkout redirected to
  /// /paymentCancel. Cancels the booking on the backend and returns to the
  /// main screen's appointments tab.
  Future<void> cancelPaymentAfterWebview({int? appointmentId}) async {
    final id = appointmentId ?? this.appointmentId.value;
    if (id == null || id == 0) {
      Get.snackbar('warning'.tr(), 'unable_start_payment'.tr());
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _bookingService.paymentCancel(appointmentId: id);
      Get.snackbar('info'.tr(), 'payment_cancelled'.tr());
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      isLoading.value = false;
      resetBooking();
      Get.offAllNamed(AppRouter.main, arguments: {'tab': 2});
    }
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
  }

  // ---- Navigation ----
  void goToNextStep() {
    if (currentStep.value < steps.length - 1) currentStep.value++;
  }

  void goToPreviousStep() {
    if (currentStep.value > 0) currentStep.value--;
  }
}