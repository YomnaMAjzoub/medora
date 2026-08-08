import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:medora_git/core/errors/error_handler.dart';
import 'package:medora_git/core/network/api_client.dart';
import 'package:medora_git/core/storage/appconfig.dart';
import 'package:medora_git/features/patient/data/models/add_booking_response_model.dart';
import 'package:medora_git/features/patient/data/models/app_confirm_response_model.dart';
import 'package:medora_git/features/patient/data/models/appointment_model.dart';
import 'package:medora_git/features/patient/data/models/complete_final_payment_response_model.dart';
import 'package:medora_git/features/patient/data/models/location_model.dart';
import 'package:medora_git/features/patient/data/models/payment_success_response_model.dart';

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

  Future<PaymentSuccessResponseModel> paymentSuccess({
    required int appointmentId,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        '/paymentSuccess',
        queryParameters: {'appointment_id': appointmentId},
        options: Options(headers: {'api_key': AppConfig.apiKey}),
      );

      return PaymentSuccessResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  Future<AppConfirmResponseModel> confirmAppointment({
    required int appointmentId,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/appointments/$appointmentId/app-confirm',
        options: Options(headers: {'api_key': AppConfig.apiKey}),
      );

      return AppConfirmResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  Future<CompleteFinalPaymentResponseModel> completeFinalPayment({
    required int appointmentId,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        '/completeFinalPayment',
        queryParameters: {'appointment_id': appointmentId},
        options: Options(headers: {'api_key': AppConfig.apiKey}),
      );

      return CompleteFinalPaymentResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }
}
