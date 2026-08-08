import 'package:dio/dio.dart';

class ErrorHandler {
  static String handleDioError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
switch(e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
        return 'Connection error, please try again';
      case DioExceptionType.receiveTimeout:
        return 'Server is taking too long to respond';
      case DioExceptionType.badCertificate:
        return 'Security error';
        case DioExceptionType.badResponse:  
        if (data is Map && data.containsKey('message')) {
          return data['data']?['message'] ?? data['message'];
        }
        break;
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.unknown:
        if (e.error is String) {
          return e.error.toString();
        }

        return 'Unexpected error occurred';
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
              return 'Unauthorized';
            case 403:
              return 'Forbidden';
            case 404:
              return 'Not found';
            case 500:
              return 'Server error, try again later';
          }
        }
        return 'Unexpected error occurred';
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Connection error, please try again';
    }

    if (e.type == DioExceptionType.receiveTimeout) {
      return 'Server is taking too long to respond';
    }

    if (e.type == DioExceptionType.badCertificate) {
      return 'Security error';
    }

    if (e.type == DioExceptionType.cancel) {
      return 'Request was cancelled';
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
          return 'Unauthorized';
        case 403:
          return 'Forbidden';
        case 404:
          return 'Not found';
        case 500:
          return 'Server error, try again later';
      }
    }

    return 'Unexpected error occurred';
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
      return 'Validation error';
    }
  }
}
