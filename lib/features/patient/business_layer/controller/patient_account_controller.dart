import 'package:easy_localization/easy_localization.dart';
import 'dart:io';

import 'package:get/get.dart' hide Trans;
import 'package:share_plus/share_plus.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/features/patient/business_layer/controller/doctor_discovery_controller.dart';
import 'package:medora_git/features/patient/data/models/active_offer_model.dart';
import 'package:medora_git/features/patient/data/models/appointment_model.dart';
import 'package:medora_git/features/patient/data/models/appointment_record_model.dart';
import 'package:medora_git/features/patient/data/models/doctor_summary_model.dart';
import 'package:medora_git/features/patient/data/models/medical_record_model.dart';
import 'package:medora_git/features/patient/data/models/offer_model.dart';
import 'package:medora_git/features/patient/data/models/patient_profile_model.dart';
import 'package:medora_git/features/patient/data/src/patient_service.dart';

/// Patient account data: appointments, medical records and active offers,
/// plus the PDF export of the medical records.
class PatientAccountController extends GetxController {
  PatientAccountController({PatientService? service})
      : _service = service ?? PatientService();

  final PatientService _service;

  final RxBool isLoadingAppointments = false.obs;
  final RxString appointmentsError = ''.obs;
  final RxList<AppointmentRecordModel> appointments =
      <AppointmentRecordModel>[].obs;

  final RxBool isLoadingRecords = false.obs;
  final RxString recordsError = ''.obs;
  final RxList<MedicalRecordModel> medicalRecords =
      <MedicalRecordModel>[].obs;

  final RxBool isLoadingOffers = false.obs;
  final RxString offersError = ''.obs;
  final RxList<ActiveOfferModel> offers = <ActiveOfferModel>[].obs;

final RxBool isExportingPdf = false.obs;
  final RxInt processingAppointmentId = 0.obs;

  final Rx<PatientProfileModel?> profile = Rx<PatientProfileModel?>(null);
  final RxBool isLoadingProfile = false.obs;
  final RxString profileError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    fetchAppointments();
    fetchMedicalRecords();
    fetchOffers();
  }

  /// Loads the logged-in user's full profile (getMyProfile) so the profile
  /// and medical-file screens show real data instead of the session summary.
  Future<void> fetchProfile() async {
    if (isLoadingProfile.value) return;
    isLoadingProfile.value = true;
    profileError.value = '';
    try {
      profile.value = await _service.getMyProfile();
    } catch (e) {
      profileError.value = e.toString();
    } finally {
      isLoadingProfile.value = false;
    }
  }

  /// Offers mapped to the home slider's UI model.
  List<OfferModel> get offerModels =>
      offers.map((offer) => offer.toOfferModel()).toList();

  /// The next upcoming confirmed appointment, resolved against the doctors
  /// list so the home card can show the real doctor (the backend does not
  /// eager-load the doctor relation in getAppointmentPatient).
  AppointmentModel? get nextAppointment {
    final now = DateTime.now();
    final upcoming = appointments
        .where(
          (a) =>
              a.status == AppointmentStatus.confirmed &&
              a.appointmentTime.isAfter(now),
        )
        .toList()
      ..sort((a, b) => a.appointmentTime.compareTo(b.appointmentTime));
    if (upcoming.isEmpty) return null;

    final record = upcoming.first;
    DoctorSummaryModel? doctor;
    if (Get.isRegistered<DoctorDiscoveryController>()) {
      final match = Get.find<DoctorDiscoveryController>()
          .doctors
          .firstWhereOrNull(
            (d) => d.userId == record.doctorId || d.id == '${record.doctorId}',
          );
      if (match != null) {
        doctor = DoctorSummaryModel(
          id: match.id,
          name: match.name,
          specialty: match.specialty,
          imageUrl: match.imageUrl.isEmpty ? null : match.imageUrl,
        );
      }
    }
    return AppointmentModel(
      id: '${record.id}',
      doctor: doctor ?? const DoctorSummaryModel(
        id: '0',
        name: '',
        specialty: '',
        imageUrl: null,
      ),
      date: record.appointmentTime,
      time: DateFormat('h:mm a').format(record.appointmentTime),
      visitType: _visitTypeFor(record.type),
      meetLink: record.resolvedMeetLink,
    );
  }

  VisitType _visitTypeFor(String raw) {
    switch (raw) {
      case 'online':
        return VisitType.online;
      case 'home':
        return VisitType.home;
      default:
        return VisitType.clinic;
    }
  }

/// Resumes the deposit of a pending appointment with the simulated
  /// in-app payment (paymentSuccess) and refreshes the list.
  Future<void> resumePayment({required int appointmentId}) async {
    processingAppointmentId.value = appointmentId;
    try {
      await _service.confirmPaymentSuccess(appointmentId: appointmentId);
      Get.snackbar('success'.tr(), 'payment_confirmed'.tr());
      await fetchAppointments();
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      processingAppointmentId.value = 0;
    }
  }

/// Cancels a pending appointment (paymentCancel) and refreshes the list.
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

  /// Confirms a visit after the patient tapped an appointment-reminder
  /// notification (app-confirm). When the backend returns a `payment_url`
  /// ("please complete payment"), the Fatora checkout opens in the in-app
  /// WebView to finish the remaining payment.
  Future<void> confirmReminderAppointment(
      {required int appointmentId}) async {
    processingAppointmentId.value = appointmentId;
    try {
      final result = await _service.confirmAfterReminder(
        appointmentId: appointmentId,
      );
      final url = result.paymentUrl;
      if (url != null && url.isNotEmpty) {
        Get.toNamed(
          AppRouter.fatoraPayment,
          arguments: {
            'paymentUrl': url,
            'appointmentId': appointmentId,
            'flow': 'reminder',
          },
        );
      } else {
        Get.snackbar('success'.tr(), result.message);
      }
      await fetchAppointments();
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      processingAppointmentId.value = 0;
    }
  }

  /// Called by the Fatora WebView after the reminder-flow checkout
  /// redirected to /paymentSuccess: finalises the payment on the backend,
  /// refreshes the list and returns to the appointments tab.
  Future<void> completeReminderPayment({required int appointmentId}) async {
    processingAppointmentId.value = appointmentId;
    try {
      await _service.confirmPaymentSuccess(appointmentId: appointmentId);
      Get.snackbar('success'.tr(), 'payment_confirmed'.tr());
      await fetchAppointments();
      Get.offAllNamed(AppRouter.main, arguments: {'tab': 2});
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      processingAppointmentId.value = 0;
    }
  }

  /// Called by the Fatora WebView when the reminder-flow checkout redirected
  /// to /paymentCancel. The appointment stays confirmed server-side, so the
  /// patient just returns to the appointments tab to pay later.
  Future<void> cancelReminderPayment({required int appointmentId}) async {
    try {
      Get.snackbar('info'.tr(), 'payment_cancelled'.tr());
      await fetchAppointments();
      Get.offAllNamed(AppRouter.main, arguments: {'tab': 2});
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
    }
  }

  Future<void> fetchAppointments() async {
    isLoadingAppointments.value = true;
    appointmentsError.value = '';
    try {
      appointments.assignAll(await _service.getPatientAppointments());
    } catch (e) {
      appointmentsError.value = e.toString();
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      isLoadingAppointments.value = false;
    }
  }

  Future<void> fetchMedicalRecords() async {
    isLoadingRecords.value = true;
    recordsError.value = '';
    try {
      medicalRecords.assignAll(await _service.getMedicalRecords());
    } catch (e) {
      recordsError.value = e.toString();
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      isLoadingRecords.value = false;
    }
  }

  Future<void> fetchOffers() async {
    isLoadingOffers.value = true;
    offersError.value = '';
    try {
      offers.assignAll(await _service.getActiveOffers());
    } catch (e) {
      offersError.value = e.toString();
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      isLoadingOffers.value = false;
    }
  }

  /// Downloads the patient profile PDF, stores it in the system temp
  /// directory and opens the share sheet so it can be saved/shared.
  Future<void> exportMedicalRecordsPdf() async {
    isExportingPdf.value = true;
    try {
      final bytes = await _service.exportMedicalRecords();
      if (bytes.isEmpty) {
        Get.snackbar('error'.tr(), 'empty_pdf_response'.tr());
        return;
      }
      final file = File(
        '${Directory.systemTemp.path}/medical_records_'
        '${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/pdf')],
        ),
      );
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      isExportingPdf.value = false;
    }
  }
}