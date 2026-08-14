import 'package:dio/dio.dart';
import 'package:medora_git/core/errors/error_handler.dart';
import 'package:medora_git/core/network/api_client.dart';
import 'package:medora_git/core/storage/appconfig.dart';
import 'package:medora_git/features/patient/data/models/active_offer_model.dart';
import 'package:medora_git/features/patient/data/models/appointment_record_model.dart';
import 'package:medora_git/features/patient/data/models/doctor_profile_model.dart';
import 'package:medora_git/features/patient/data/models/medical_record_model.dart';
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

  /// Re-confirms an existing pending-deposit appointment (app-confirm) and
  /// returns the fresh payment gateway URL for resuming the deposit.
  Future<String> resumePayment({required int appointmentId}) async {
    try {
      final response = await ApiClient.dio.post(
        '/appointments/$appointmentId/app-confirm',
        options: Options(headers: {'api_key': AppConfig.apiKey}),
      );
      final data = response.data as Map<String, dynamic>;
      return data['payment_url'] as String? ?? '';
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// Marks a booking as paid after returning from the gateway (paymentSuccess).
  Future<void> confirmPaymentSuccess({required int appointmentId}) async {
    try {
      await ApiClient.dio.get(
        '/paymentSuccess',
        queryParameters: {'appointment_id': appointmentId},
        options: Options(headers: {'api_key': AppConfig.apiKey}),
      );
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// Cancels a pending booking (paymentCancel).
  Future<void> cancelAppointment({required int appointmentId}) async {
    try {
      await ApiClient.dio.get(
        '/paymentCancel',
        queryParameters: {'appointment_id': appointmentId},
        options: Options(headers: {'api_key': AppConfig.apiKey}),
      );
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