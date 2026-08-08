import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medora_git/core/errors/error_handler.dart';
import 'package:medora_git/core/storage/appconfig.dart';
import 'package:medora_git/features/patient/data/models/doctor_calendar_slot_model.dart';

class DoctorCalendarService {
  DoctorCalendarService({Dio? dio, GetStorage? storage})
      : dio = dio ?? Dio(),
        storage = storage ?? GetStorage();

  final Dio dio;
  final GetStorage storage;

  Future<DoctorCalendarResponseModel> getDoctorMonthlyCalendar({
    required int doctorId,
    required String date,
  }) async {
    try {
      final token = storage.read<String>('access_token');

      final response = await dio.get(
        '${AppConfig.baseUrl}/getDoctorMonthlyCalendar',
        queryParameters: {'doctor_id': doctorId, 'date': date},
        options: Options(
          headers: {
            'Accept': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      return DoctorCalendarResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }
}
