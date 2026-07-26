import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medora_git/core/errors/error_handler.dart';
import 'package:medora_git/core/storage/appconfig.dart';

class AuthService {
  final Dio dio = Dio();
  final GetStorage storage = GetStorage();

  Future<bool> register(
    String firstName,
    String lastName,
    String gender,
    String birth,
    String email,
    String phone,
    String password,
    String confirmPass,
    String? bloodType,
    String? illness,
  ) async {
    try {
      final Map<String, dynamic> data = {
        'first_name': firstName,
        'last_name': lastName,
        'gender': gender,
        'birth': birth,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': confirmPass,
      };
      if (bloodType != null && bloodType.isNotEmpty) {
        data['blood_type'] = bloodType;
      }

      if (illness != null && illness.isNotEmpty) {
        data['previous_illnesses'] = illness;
      }
      Response response = await dio.post(
        '${AppConfig.baseUrl}/register',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'content-type': 'application/json',
          },
        ),
        data: data,
      );
      log('Register Response: ${response.data.toString()}');
      if (response.statusCode == 201 &&
          response.data['message'] ==
              'Registration successful. Please check your email for the OTP to verify your account.') {
        final token = response.data['user']['access_token'];
        if (token != null) {
          await storage.write('access_token', token);
        }
        return true;
      } else {
        throw response.data?['message'] ?? response.statusMessage ?? 'Registration failed';
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<bool> verifyCode(String email, String code) async {
    try {
      Response response = await dio.post(
        '${AppConfig.baseUrl}/verify-otp',
        options: Options(headers: {'Accept': 'application/json'}),
        data: {'email': email, 'otp_code': code},
      );
      log('verification Response: ${response.data.toString()}');
      if (response.statusCode == 200 || response.data['message'] == 'success') {
        final token = response.data['user']['access_token'];
        if (token != null) {
          await storage.write('access_token', token);
        }
        return true;
      } else {
        throw response.data['message'] ?? 'verification failed';
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      Response response = await dio.post(
        '${AppConfig.baseUrl}/login',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'content-type': 'application/json',
          },
        ),
        data: {'email': email, 'password': password},
      );
      log(response.data.toString());
      if (response.statusCode == 200 || response.data['message'] == 'success') {
        final token = response.data['access_token'];
        
        if (token != null) {
          storage.write('access_token', token);
          return true;
        } else {
          throw 'Token not found in response';
        }
      } else {
        throw response.data['message'] ?? 'Login failed';
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
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
