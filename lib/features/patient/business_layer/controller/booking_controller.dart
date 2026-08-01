import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medora_git/features/patient/data/models/appointment_model.dart';
import 'package:medora_git/features/patient/data/models/doctor_model.dart';

enum BookingStep { selectDoctor, visitType, homeLocation, dateTime, payment }

class BookingController extends GetxController {
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

  void confirmHomeLocation({
    required LatLng location,
    required String address,
  }) {
    homeVisitLatLng.value = location;
    homeVisitAddress.value = address;
    goToNextStep();
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

  var consultationFee = 100.0.obs; // مثال
  double get depositAmount => consultationFee.value * 0.5;

  void confirmPayment() {
    // هون بتعملي API الدفع
    // وبعدها تأكيد الحجز
    Get.snackbar("Payment Confirmed", "Deposit: $depositAmount");
  }

  void resetBooking() {
    currentStep.value = 0;
    selectedDoctor.value = null;
    selectedVisitType.value = null;
    homeVisitLatLng.value = null;
    homeVisitAddress.value = null;
    selectedDate.value = null;
    selectedTimeSlot.value = null;
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
