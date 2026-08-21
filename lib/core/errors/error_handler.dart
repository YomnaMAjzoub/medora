import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

class ErrorHandler {
  static String handleDioError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
switch(e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
        return 'connection_error'.tr();
      case DioExceptionType.receiveTimeout:
        return 'server_timeout'.tr();
      case DioExceptionType.badCertificate:
        return 'security_error'.tr();
        case DioExceptionType.badResponse:  
        if (data is Map && data.containsKey('message')) {
          return data['data']?['message'] ?? data['message'];
        }
        break;
      case DioExceptionType.cancel:
        return 'request_cancelled'.tr();
      case DioExceptionType.unknown:
        if (e.error is String) {
          return e.error.toString();
        }

        return 'unexpected_error'.tr();
      default:
        if (e.response != null) {
          final data = e.response?.data;
          if (data is Map && data['message'] is String) {
            return data['message'];
          }

          if (data is Map && data['message'] is Map) {
            return _extractError(data['message']);
          }

          if (data is Map && data['errors'] is Map) {
            return _extractError(data['errors']);
          }

          switch (status) {
            case 401:
              return 'unauthorized'.tr();
            case 403:
              return 'forbidden'.tr();
            case 404:
              return 'not_found'.tr();
            case 500:
              return 'server_error'.tr();
          }
        }
        return 'unexpected_error'.tr();
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'connection_error'.tr();
    }

    if (e.type == DioExceptionType.receiveTimeout) {
      return 'server_timeout'.tr();
    }

    if (e.type == DioExceptionType.badCertificate) {
      return 'security_error'.tr();
    }

    if (e.type == DioExceptionType.cancel) {
      return 'request_cancelled'.tr();
    }

    if (e.response != null) {
      if (data is Map && data['message'] is String) {
        return data['message'];
      }

      if (data is Map && data['message'] is Map) {
        return _extractError(data['message']);
      }

      if (data is Map && data['errors'] is Map) {
        return _extractError(data['errors']);
      }

      switch (e.response?.statusCode) {
        case 401:
          return 'unauthorized'.tr();
        case 403:
          return 'forbidden'.tr();
        case 404:
          return 'not_found'.tr();
        case 500:
          return 'server_error'.tr();
      }
    }

    return 'unexpected_error'.tr();
  }
  static String _extractError(Map errors) {
    try {
      final firstKey = errors.keys.first;
      final value = errors[firstKey];

      if (value is List) {
        return value.first.toString();
      } else {
        return value.toString();
      }
    } catch (e) {
      return 'validation_error'.tr();
    }
  }

  /// True when the raw message is a low-level gateway/server failure
  /// (Laravel surfaces its own cURL/SSL exceptions verbatim in debug mode,
  /// e.g. "Exception: cURL error 28: SSL connection timeout ... for
  /// https://api.fatora.io/v1/payments/checkout"). Such text must never be
  /// shown to end users.
  static bool isGatewayFailure(String rawMessage) {
    final lower = rawMessage.toLowerCase();
    return lower.contains('curl error') ||
        lower.contains('ssl') ||
        lower.contains('timed out') ||
        lower.contains('connection refused') ||
        lower.contains('could not resolve') ||
        lower.contains('guzzle');
  }

  /// Maps a raw error into a user-safe message: known gateway/SSL failures
  /// become a friendly translated notice; anything else passes through.
  static String friendly(String rawMessage,
      {String friendlyKey = 'payment_service_unavailable'}) {
    if (isGatewayFailure(rawMessage)) {
      return friendlyKey.tr();
    }
    return rawMessage;
  }
}
