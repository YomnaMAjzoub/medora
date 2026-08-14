import 'package:dio/dio.dart';
import 'package:medora_git/core/errors/error_handler.dart';
import 'package:medora_git/core/network/api_client.dart';
import 'package:medora_git/core/storage/appconfig.dart';
import 'package:medora_git/features/doctor/data/models/doctor_appointment_model.dart';
import 'package:medora_git/features/doctor/data/models/patient_medical_record_model.dart';

/// Doctor-facing endpoints.
class DoctorService {
  /// The logged-in doctor's appointments for today.
  Future<List<DoctorAppointmentModel>> getTodayAppointments() async {
    try {
      final response = await ApiClient.dio.get('/appointmentForDoctor');
      final data = response.data as Map<String, dynamic>;
      final list = data['data'];
      if (list is! List) return const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(DoctorAppointmentModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// Medical records of a patient (the path id is the patient's user id).
  Future<PatientMedicalRecordModel> getPatientMedicalRecords(
    int patientId,
  ) async {
    try {
      final response =
          await ApiClient.dio.get('/getMedicalRecord/$patientId');
      final data = response.data as Map<String, dynamic>;
      final inner = data['data'];
      if (inner is! Map<String, dynamic>) {
        throw Exception('Failed to load medical records');
      }
      return PatientMedicalRecordModel.fromJson(inner);
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  Future<void> updateMedicalRecord({
    required int appointmentId,
    String? diagnosis,
    String? prescription,
    String? tests,
    String? notes,
    String? imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'appointment_id': appointmentId,
        if (diagnosis != null && diagnosis.isNotEmpty)
          'diagnosis': diagnosis,
        if (prescription != null && prescription.isNotEmpty)
          'prescription': prescription,
        if (tests != null && tests.isNotEmpty) 'tests': tests,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (imagePath != null)
          'images': await MultipartFile.fromFile(imagePath),
      });
      final response =
          await ApiClient.dio.post('/updateMedicalRecord', data: formData);
      final data = response.data as Map<String, dynamic>;
      final inner = data['data'];
      if (inner is Map<String, dynamic> &&
          inner['status'] != null &&
          inner['status'] != 'success') {
        throw Exception(inner['message']?.toString() ?? 'Update failed');
      }
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// Marks a confirmed appointment as fully paid (completeFinalPayment).
  Future<void> completeFinalPayment({required int appointmentId}) async {
    try {
      await ApiClient.dio.get(
        '/completeFinalPayment',
        queryParameters: {'appointment_id': appointmentId},
        options: Options(headers: {'api_key': AppConfig.apiKey}),
      );
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }
}