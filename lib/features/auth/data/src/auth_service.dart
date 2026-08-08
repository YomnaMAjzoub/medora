import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medora_git/core/errors/error_handler.dart';
import 'package:medora_git/core/storage/appconfig.dart';
import 'package:medora_git/features/auth/data/models/login_response_model.dart';
import 'package:medora_git/features/auth/data/models/register_response_model.dart';
import 'package:medora_git/features/auth/data/models/verify_otp_response_model.dart';

class AuthService {
  final Dio dio = Dio();
  final GetStorage storage = GetStorage();

  Future<RegisterResponseModel> register({
    required String firstName,
    required String lastName,
    required String gender,
    required String birth,
    required String email,
    required String phone,
    required String password,
    required String confirmPass,
    String? bloodType,
    String? illness,
  }) async {
    try {
      final formData = FormData.fromMap({
        'first_name': firstName,
        'last_name': lastName,
        'gender': gender,
        'birth': birth,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': confirmPass,
        if (bloodType != null && bloodType.isNotEmpty) 'blood_type': bloodType,
        if (illness != null && illness.isNotEmpty)
          'previous_illnesses': illness,
      });

      final response = await dio.post(
        '${AppConfig.baseUrl}/register',
        data: formData,
        options: Options(headers: {'Accept': 'application/json'}),
      );

      return RegisterResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  Future<VerifyOtpResponseModel> verifyCode({
    required String email,
    required String code,
  }) async {
    try {
      final formData = FormData.fromMap({
        'email': email,
        'otp_code': code,
      });

      final response = await dio.post(
        '${AppConfig.baseUrl}/verify-otp',
        data: formData,
        options: Options(headers: {'Accept': 'application/json'}),
      );

      return VerifyOtpResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final fcmToken = storage.read<String>('fcm_token');
      final formData = FormData.fromMap({
        'email': email,
        'password': password,
        if (fcmToken != null && fcmToken.isNotEmpty)
          'fcm_token': fcmToken,
      });

      final response = await dio.post(
        '${AppConfig.baseUrl}/login',
        data: formData,
        options: Options(headers: {'Accept': 'application/json'}),
      );

      final result = LoginResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      await storage.write('access_token', result.accessToken);

      return result;
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  Future<bool> forgotPass(String email) async {
    try {
      Response response = await dio.post(
        '${AppConfig.baseUrl}/forgotPassword',
        options: Options(headers: {'Accept': 'application/json'}),
        data: {'email': email},
      );
      if (response.statusCode == 200) {
        log(response.data['message']);
        return true;
      }else {
      throw response.data['message'] ?? 'Something went wrong';
    }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      Response response = await dio.post(
        '${AppConfig.baseUrl}/verifyResetOtp',
        options: Options(headers: {'Accept': 'application/json'}),
        data: {'email': email, 'otp_code': otp},
      );
      if (response.statusCode == 200) {
      log(response.data['message']);
      return true;
    } else {
      throw response.data['message'] ?? 'OTP verification failed';
    }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<bool> resetPass(String email, String pass) async {
    try {
      Response response = await dio.post(
        '${AppConfig.baseUrl}/resetPassword',
        options: Options(headers: {'Accept': 'application/json'}),
        data: {'email': email, 'new_password': pass},
      );
      if (response.statusCode == 200) {
      log(response.data['message']);
      return true;
    } else {
      throw response.data['message'] ?? 'Password reset failed';
    }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
