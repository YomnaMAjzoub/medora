import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/storage/appconfig.dart';

/// Shared Dio instance for all API calls.
/// Adds the Bearer token automatically on every request when present, and
/// kicks the user back to the login screen when the token is rejected
/// (401 / expired) so expired sessions are never left in a broken state.
class ApiClient {
  ApiClient._();

  /// Guards against multiple parallel requests all failing with 401 and
  /// triggering several redirects at once.
  static bool _loggingOut = false;

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
        onError: (error, handler) {
          if (error.response?.statusCode == 401 &&
              !_loggingOut &&
              GetStorage().read<String>('access_token')?.isNotEmpty == true) {
            _loggingOut = true;
            final storage = GetStorage();
            storage.remove('access_token');
            storage.remove('user_id');
            storage.remove('role');
            storage.remove('user_name');
            storage.remove('user_email');
            storage.remove('fcm_token');
            if (Get.context != null) {
              Get.snackbar(
                'session_expired_title'.tr(),
                'session_expired'.tr(),
              );
            }
            Get.offAllNamed(AppRouter.login);
            _loggingOut = false;
          }
          handler.next(error);
        },
      ),
    );
}