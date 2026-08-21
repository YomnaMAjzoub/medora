import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import 'package:medora_git/features/doctor/data/models/doctor_appointment_model.dart';
import 'package:medora_git/features/doctor/data/models/doctor_invoice_model.dart';
import 'package:medora_git/features/doctor/data/models/doctor_patient_model.dart';
import 'package:medora_git/features/doctor/data/models/doctor_work_schedule_model.dart';
import 'package:medora_git/features/doctor/data/models/patient_medical_record_model.dart';
import 'package:medora_git/features/doctor/data/src/doctor_service.dart';
import 'package:medora_git/features/patient/data/models/appointment_record_model.dart';
import 'package:medora_git/features/patient/data/models/doctor_profile_model.dart';

/// Doctor panel state: dashboard stats, appointments, patients,
/// consultations, schedule, invoices and the medical record editing flow.
class DoctorController extends GetxController {
  DoctorController({DoctorService? service})
      : _service = service ?? DoctorService();

  final DoctorService _service;

  static const _lastDiagnosisKey = 'doctor_last_diagnosis';
  static const _lastPrescriptionKey = 'doctor_last_prescription';

  // ---- Appointments -----------------------------------------------------
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<DoctorAppointmentModel> appointments =
      <DoctorAppointmentModel>[].obs;
  final RxString periodFilter = 'today'.obs;
  final RxString typeFilter = ''.obs;

  // ---- Patients ---------------------------------------------------------
  final RxBool isLoadingPatients = false.obs;
  final RxString patientsError = ''.obs;
  final RxList<DoctorPatientModel> patients = <DoctorPatientModel>[].obs;

  // ---- Consultations ----------------------------------------------------
  final RxBool isLoadingConsultations = false.obs;
  final RxString consultationsError = ''.obs;
  final RxList<DoctorAppointmentModel> consultations =
      <DoctorAppointmentModel>[].obs;

  // ---- Schedule ---------------------------------------------------------
  final RxBool isLoadingSchedule = false.obs;
  final RxString scheduleError = ''.obs;
  final Rxn<DoctorWorkScheduleModel> schedule = Rxn();

  // ---- Invoices ---------------------------------------------------------
  final RxBool isLoadingInvoices = false.obs;
  final RxString invoicesError = ''.obs;
  final RxList<DoctorInvoiceModel> invoices = <DoctorInvoiceModel>[].obs;

  // ---- Profile ----------------------------------------------------------
  final RxBool isLoadingProfile = false.obs;
  final Rxn<DoctorProfileModel> myProfile = Rxn();

  // ---- Medical records --------------------------------------------------
  final RxBool isLoadingRecords = false.obs;
  final RxString recordsError = ''.obs;
  final Rxn<PatientMedicalRecordModel> patientRecord = Rxn();

  final RxBool isUpdatingRecord = false.obs;
  final RxBool isCompletingPayment = false.obs;
  final RxInt processingAppointmentId = 0.obs;

  final RxString lastDiagnosis = ''.obs;
  final RxString lastPrescription = ''.obs;

  // ---- Derived dashboard stats -----------------------------------------
  int get todayAppointmentsCount =>
      _today(appointments).length;

  int get todayConsultationsCount => _today(
        consultations.where((c) => c.isOnline).toList(),
      ).length;

  int get newPatientsCount => _today(patients.map(_asAppointment).toList())
      .length;

  /// Percentage of today's appointments that were cancelled / not attended.
  double get noShowRate {
    final todayItems = _today(appointments);
    if (todayItems.isEmpty) return 0;
    final missed = todayItems
        .where((a) => a.status == AppointmentStatus.cancelled)
        .length;
    return missed / todayItems.length * 100;
  }

  /// The busiest hour window of the week, derived from appointment times.
  String get peakHours {
    if (appointments.isEmpty) return '';
    final byHour = <int, int>{};
    for (final appointment in appointments) {
      final hour = appointment.appointmentTime.hour;
      byHour[hour] = (byHour[hour] ?? 0) + 1;
    }
    final peak = byHour.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final start = peak.key;
    final end = start + 1;
    return '${_two(start)}:00 - ${_two(end)}:00';
  }

  /// Appointments matching the current period + visit-type filters.
  List<DoctorAppointmentModel> get filteredAppointments {
    var items = appointments.toList();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    items = items.where((a) {
      final date = a.appointmentTime;
      final day = DateTime(date.year, date.month, date.day);
      switch (periodFilter.value) {
        case 'week':
          final start = today.subtract(Duration(days: today.weekday - 1));
          final end = start.add(const Duration(days: 7));
          return !date.isBefore(start) && date.isBefore(end);
        case 'month':
          return date.year == now.year && date.month == now.month;
        case 'today':
        default:
          return day == today;
      }
    }).toList();
    if (typeFilter.value.isNotEmpty) {
      items = items.where((a) => a.type == typeFilter.value).toList();
    }
    return items;
  }

  DoctorAppointmentModel? appointmentById(int id) {
    for (final appointment in appointments) {
      if (appointment.id == id) return appointment;
    }
    return null;
  }

  DoctorPatientModel? patientById(int id) {
    for (final patient in patients) {
      if (patient.id == id) return patient;
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    lastDiagnosis.value = GetStorage().read<String>(_lastDiagnosisKey) ?? '';
    lastPrescription.value =
        GetStorage().read<String>(_lastPrescriptionKey) ?? '';
    fetchAppointments();
    fetchMyProfile();
    fetchPatients();
    fetchConsultations();
    fetchSchedule();
    fetchInvoices();
  }

  Future<void> fetchAppointments() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      appointments.assignAll(await _service.getAppointments());
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPatients() async {
    isLoadingPatients.value = true;
    patientsError.value = '';
    try {
      patients.assignAll(await _service.getPatients());
    } catch (e) {
      patientsError.value = e.toString();
    } finally {
      isLoadingPatients.value = false;
    }
  }

  Future<void> fetchConsultations() async {
    isLoadingConsultations.value = true;
    consultationsError.value = '';
    try {
      consultations.assignAll(await _service.getConsultations());
    } catch (e) {
      consultationsError.value = e.toString();
    } finally {
      isLoadingConsultations.value = false;
    }
  }

  Future<void> fetchSchedule() async {
    isLoadingSchedule.value = true;
    scheduleError.value = '';
    try {
      schedule.value = await _service.getSchedule();
    } catch (e) {
      scheduleError.value = e.toString();
    } finally {
      isLoadingSchedule.value = false;
    }
  }

  Future<void> updateSchedule(DoctorWorkScheduleModel value) async {
    try {
      await _service.updateSchedule(value);
      schedule.value = value;
      Get.snackbar('success'.tr(), 'schedule_updated'.tr());
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
    }
  }

  Future<void> fetchInvoices() async {
    isLoadingInvoices.value = true;
    invoicesError.value = '';
    try {
      invoices.assignAll(await _service.getInvoices());
    } catch (e) {
      invoicesError.value = e.toString();
    } finally {
      isLoadingInvoices.value = false;
    }
  }

  Future<void> fetchMyProfile() async {
    isLoadingProfile.value = true;
    try {
      myProfile.value = await _service.getMyProfile();
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      isLoadingProfile.value = false;
    }
  }

  Future<void> updateMyProfile({
    double? price,
    bool? homeVisit,
    bool? onlineConsultation,
    String? specialization,
    String? photoPath,
    String? password,
  }) async {
    try {
      await _service.updateMyProfile(
        price: price,
        homeVisit: homeVisit,
        specialization: specialization,
        photoPath: photoPath,
        password: password,
      );
      Get.snackbar('success'.tr(), 'profile_updated'.tr());
      await fetchMyProfile();
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
    }
  }

  // ---- Appointment actions ---------------------------------------------
  Future<void> confirmAppointment({required int appointmentId}) async {
    processingAppointmentId.value = appointmentId;
    try {
      await _service.confirmAppointment(appointmentId: appointmentId);
      Get.snackbar('success'.tr(), 'appointment_confirmed'.tr());
      await fetchAppointments();
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      processingAppointmentId.value = 0;
    }
  }

  Future<void> cancelAppointment({required int appointmentId}) async {
    processingAppointmentId.value = appointmentId;
    try {
      await _service.cancelAppointment(appointmentId: appointmentId);
      Get.snackbar('success'.tr(), 'appointment_cancelled'.tr());
      await fetchAppointments();
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      processingAppointmentId.value = 0;
    }
  }

  /// Completes an appointment (collects the final payment).
  Future<void> completeFinalPayment({required int appointmentId}) async {
    processingAppointmentId.value = appointmentId;
    try {
      await _service.completeFinalPayment(appointmentId: appointmentId);
      Get.snackbar('success'.tr(), 'final_payment_done'.tr());
      await fetchAppointments();
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      processingAppointmentId.value = 0;
    }
  }

  Future<void> endConsultation({required int appointmentId}) async {
    processingAppointmentId.value = appointmentId;
    try {
      await _service.endConsultation(appointmentId: appointmentId);
      Get.snackbar('success'.tr(), 'consultation_ended'.tr());
      await fetchAppointments();
      await fetchConsultations();
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      processingAppointmentId.value = 0;
    }
  }

  // ---- Medical records --------------------------------------------------
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
      if (diagnosis != null && diagnosis.trim().isNotEmpty) {
        lastDiagnosis.value = diagnosis.trim();
        await GetStorage().write(_lastDiagnosisKey, diagnosis.trim());
      }
      if (prescription != null && prescription.trim().isNotEmpty) {
        lastPrescription.value = prescription.trim();
        await GetStorage().write(_lastPrescriptionKey, prescription.trim());
      }
      await fetchPatientRecord(patientId);
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      isUpdatingRecord.value = false;
    }
  }

  /// Google Meet room for a new consultation.
  String newConsultationMeetLink() => _service.newConsultationMeetLink();

  List<T> _today<T>(List<T> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return items.where((item) {
      final time = switch (item) {
        DoctorAppointmentModel a => a.appointmentTime,
        DoctorPatientModel p => p.lastVisit,
        _ => null,
      };
      if (time == null) return false;
      final day = DateTime(time.year, time.month, time.day);
      return day == today;
    }).toList();
  }

  DoctorAppointmentModel _asAppointment(DoctorPatientModel patient) {
    return DoctorAppointmentModel(
      id: patient.lastAppointmentId ?? 0,
      patientId: patient.id,
      type: '',
      appointmentTime: patient.lastVisit ?? DateTime.now(),
      status: AppointmentStatus.unknown,
      patient: _patientAsAppointmentPatient(patient),
    );
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}

DoctorAppointmentPatientModel _patientAsAppointmentPatient(
  DoctorPatientModel patient,
) {
  return DoctorAppointmentPatientModel(
    id: patient.id,
    firstName: patient.firstName,
    lastName: patient.lastName,
    gender: patient.gender,
    phone: patient.phone,
    email: patient.email,
  );
}