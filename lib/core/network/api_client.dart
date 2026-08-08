import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medora_git/core/storage/appconfig.dart';

/// Shared Dio instance for all API calls.
/// Adds the Bearer token automatically on every request when present.
class ApiClient {
  ApiClient._();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      headers: {'Accept': 'application/json'},
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = GetStorage().read<String>('access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
}
