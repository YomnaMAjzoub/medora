import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:medora_git/core/errors/error_handler.dart';
import 'package:medora_git/core/network/api_client.dart';
import 'package:medora_git/core/storage/appconfig.dart';
import 'package:medora_git/features/patient/data/models/add_booking_response_model.dart';
import 'package:medora_git/features/patient/data/models/appointment_model.dart';
import 'package:medora_git/features/patient/data/models/location_model.dart';
import 'package:medora_git/features/patient/data/models/payment_success_response_model.dart';

/// Patient-side booking endpoints, matching the Postman collection:
///   POST /addBooking        (requires api_key header)
///   POST /addLocation       (requires api_key header)
///   GET  /paymentSuccess    (simulated payment, no api_key header)
///   GET  /paymentCancel     (no api_key header)
class BookingService {
  Future<AddLocationResponseModel> addLocation({
    required String address,
    required String latitude,
    required String longitude,
  }) async {
    try {
      final formData = FormData.fromMap({
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      });

      final response = await ApiClient.dio.post(
        '/addLocation',
        data: formData,
        options: Options(headers: {'api_key': AppConfig.apiKey}),
      );

      return AddLocationResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// One method for all booking variants; the backend branches on [type].
  /// `locationId` is required by the backend only for type == home.
  Future<AddBookingResponseModel> addBooking({
    required int doctorId,
    required VisitType type,
    required DateTime appointmentTime,
    int? locationId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'doctor_id': doctorId,
        'type': type.name,
        'appointment_time': DateFormat('yyyy-MM-dd HH:mm').format(appointmentTime),
        if (locationId != null) 'location_id': locationId,
      });

      final response = await ApiClient.dio.post(
        '/addBooking',
        data: formData,
        options: Options(headers: {'api_key': AppConfig.apiKey}),
      );

      return AddBookingResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// Simulated payment: marks the booking as paid on the backend.
  Future<PaymentSuccessResponseModel> paymentSuccess({
    required int appointmentId,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        '/paymentSuccess',
        queryParameters: {'appointment_id': appointmentId},
      );

      return PaymentSuccessResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// Cancels the booking when the customer backs out of the Fatora checkout.
  Future<void> paymentCancel({required int appointmentId}) async {
    try {
      await ApiClient.dio.get(
        '/paymentCancel',
        queryParameters: {'appointment_id': appointmentId},
      );
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }
}