import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medora_git/core/errors/error_handler.dart';
import 'package:medora_git/core/network/api_client.dart';
import 'package:medora_git/features/patient/data/models/active_offer_model.dart';
import 'package:medora_git/features/patient/data/models/appointment_record_model.dart';
import 'package:medora_git/features/patient/data/models/doctor_profile_model.dart';
import 'package:medora_git/features/patient/data/models/medical_record_model.dart';
import 'package:medora_git/features/patient/data/models/patient_profile_model.dart';
import 'package:medora_git/features/patient/data/models/specialization_model.dart';

class PatientService {
  Future<List<DoctorProfileModel>> getAllDoctorsForPatient() async {
    try {
      final response = await ApiClient.dio.get('/getAllDoctorsForPatient');
      final data = response.data as Map<String, dynamic>;
      final list = data['message'];
      if (list is! List) return const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(DoctorProfileModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  Future<List<SpecializationModel>> getSpecializations() async {
    try {
      final response = await ApiClient.dio.get('/getSpcialization');
      final data = response.data as Map<String, dynamic>;
      final list = data['message'];
      if (list is! List) return const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(SpecializationModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  Future<List<DoctorProfileModel>> filterDoctors({
    String? specialization,
    String? gender,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        '/filterDoctor',
        queryParameters: {
          if (specialization != null && specialization.isNotEmpty)
            'specialization': specialization,
          if (gender != null && gender.isNotEmpty) 'gender': gender,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['data'];
      if (list is! List) return const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(DoctorProfileModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  Future<List<AppointmentRecordModel>> getPatientAppointments() async {
    try {
      final response = await ApiClient.dio.get('/getAppointmentPatient');
      final data = response.data as Map<String, dynamic>;
      final list = data['message'];
      if (list is! List) return const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(AppointmentRecordModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

/// The patient's own medical records via the patient-scoped endpoint
  /// (getMedicaleRecord). The payload wraps the rows under `message`, each
  /// carrying diagnosis, prescription, tests, notes, images, appointment
  /// time/type and the attending doctor's name and specialization.
  Future<List<MedicalRecordModel>> getMedicalRecords() async {
    try {
      final response = await ApiClient.dio.get('/getMedicaleRecord');
      final data = response.data as Map<String, dynamic>;
      final list = data['message'];
      if (list is! List) return const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(MedicalRecordModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// The logged-in user's full profile (getMyProfile). The response wraps
  /// the user under `data` with the nested `patient` relation.
  Future<PatientProfileModel> getMyProfile() async {
    try {
      final response = await ApiClient.dio.get('/getMyProfile');
      final data = response.data as Map<String, dynamic>;
      final inner = data['data'];
      if (inner is! Map<String, dynamic>) {
        throw Exception('invalid_profile_response'.tr());
      }
      return PatientProfileModel.fromJson(inner);
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  Future<List<ActiveOfferModel>> getActiveOffers() async {
    try {
      final response = await ApiClient.dio.get('/getActiveOffers');
      final data = response.data as Map<String, dynamic>;
      final list = _unwrapMessageList(data['message']);
      return list
          .whereType<Map<String, dynamic>>()
          .map(ActiveOfferModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// Downloads the medical records PDF.
  Future<List<int>> exportMedicalRecords() async {
    try {
      final response = await ApiClient.dio.get<List<int>>(
        '/exportMedicalRecords',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data ?? const [];
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// Marks a booking as paid via the simulated payment endpoint
  /// (paymentSuccess) and refreshes the appointment list.
  Future<void> confirmPaymentSuccess({required int appointmentId}) async {
    try {
      await ApiClient.dio.get(
        '/paymentSuccess',
        queryParameters: {'appointment_id': appointmentId},
      );
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// Cancels a booking (app-cancel). The older paymentCancel endpoint was
  /// dropping 500s because the payments.status column rejects 'cancelled',
  /// so cancellations go through the appointment route instead.
  Future<void> cancelAppointment({required int appointmentId}) async {
    try {
      await ApiClient.dio.post('/appointments/$appointmentId/app-cancel');
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// Confirms an appointment after the patient received a reminder
  /// (app-confirm). Same endpoint the doctor side uses; here it is called
  /// with the patient's token after tapping a reminder notification.
  ///
  /// The backend responds with `{status, message, payment_url}`; the message
  /// is surfaced to the UI and the payment url opens the Fatora checkout so
  /// the patient can complete the remaining payment.
  Future<AppointmentConfirmResult> confirmAfterReminder({
    required int appointmentId,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/appointments/$appointmentId/app-confirm',
      );
      final data = response.data as Map<String, dynamic>;
      return AppointmentConfirmResult.fromJson(data);
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// getActiveOffers sometimes wraps the payload in a serialized Laravel
  /// Response object ({"headers":{},"original":{"message":[]},"exception":null}),
  /// so the offer list has to be unwrapped defensively.
  List<dynamic> _unwrapMessageList(dynamic message) {
    if (message is List) return message;
    if (message is Map) {
      final original = message['original'];
      if (original is Map) {
        final inner = original['message'];
        if (inner is List) return inner;
      }
    }
    return const [];
  }
}

/// Result of POST /appointments/{id}/app-confirm: the appointment is
/// confirmed and the backend may return a `payment_url` for the Fatora
/// checkout that completes the remaining payment.
class AppointmentConfirmResult {
  const AppointmentConfirmResult({
    required this.status,
    required this.message,
    this.paymentUrl,
  });

  final String status;
  final String message;
  final String? paymentUrl;

  factory AppointmentConfirmResult.fromJson(Map<String, dynamic> json) {
    return AppointmentConfirmResult(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? 'visit_confirmed'.tr(),
      paymentUrl: json['payment_url']?.toString(),
    );
  }
}