import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart' hide Trans;
import 'package:medora_git/features/doctor/data/models/doctor_appointment_model.dart';
import 'package:medora_git/features/doctor/data/models/patient_medical_record_model.dart';
import 'package:medora_git/features/doctor/data/src/doctor_service.dart';

/// Doctor panel state: today's appointments and the medical record data.
class DoctorController extends GetxController {
  DoctorController({DoctorService? service})
      : _service = service ?? DoctorService();

  final DoctorService _service;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<DoctorAppointmentModel> appointments =
      <DoctorAppointmentModel>[].obs;

  final RxBool isLoadingRecords = false.obs;
  final RxString recordsError = ''.obs;
  final Rxn<PatientMedicalRecordModel> patientRecord = Rxn();

  final RxBool isUpdatingRecord = false.obs;
  final RxBool isCompletingPayment = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      appointments.assignAll(await _service.getTodayAppointments());
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPatientRecord(int patientId) async {
    isLoadingRecords.value = true;
    recordsError.value = '';
    try {
      patientRecord.value =
          await _service.getPatientMedicalRecords(patientId);
    } catch (e) {
      recordsError.value = e.toString();
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      isLoadingRecords.value = false;
    }
  }

  Future<void> updateMedicalRecord({
    required int appointmentId,
    required int patientId,
    String? diagnosis,
    String? prescription,
    String? tests,
    String? notes,
    String? imagePath,
  }) async {
    isUpdatingRecord.value = true;
    try {
      await _service.updateMedicalRecord(
        appointmentId: appointmentId,
        diagnosis: diagnosis,
        prescription: prescription,
        tests: tests,
        notes: notes,
        imagePath: imagePath,
      );
      Get.snackbar('success'.tr(), 'record_updated'.tr());
      await fetchPatientRecord(patientId);
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      isUpdatingRecord.value = false;
    }
  }

  /// Finalizes the payment of a confirmed appointment
  /// (completeFinalPayment), then refreshes the appointment list.
  Future<void> completeFinalPayment({required int appointmentId}) async {
    isCompletingPayment.value = true;
    try {
      await _service.completeFinalPayment(appointmentId: appointmentId);
      Get.snackbar('success'.tr(), 'Final payment completed.');
      await fetchAppointments();
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      isCompletingPayment.value = false;
    }
  }
}