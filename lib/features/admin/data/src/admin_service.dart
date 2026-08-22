import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medora_git/core/errors/error_handler.dart';
import 'package:medora_git/core/network/api_client.dart';
import 'package:medora_git/features/admin/data/models/admin_offer_model.dart';
import 'package:medora_git/features/admin/data/models/item_model.dart';
import 'package:medora_git/features/patient/data/models/doctor_profile_model.dart';

/// Admin-facing endpoints (doctor management).
class AdminService {
  /// Doctors managed by the logged-in admin. The backend wraps the list in
  /// a serialized Laravel Response object, so it has to be unwrapped first.
  Future<List<DoctorProfileModel>> getAllDoctors() async {
    try {
      final response = await ApiClient.dio.get('/getAllDoctors');
      final data = response.data as Map<String, dynamic>;
      final list = _unwrapNestedList(data['doctors'], 'doctors');
      return list
          .whereType<Map<String, dynamic>>()
          .map(DoctorProfileModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  Future<DoctorProfileModel> addDoctor({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String specialization,
    required String phone,
    required String gender,
    required String day,
    required String startTime,
    required String endTime,
    required bool homeVisit,
    required double price,
    String? photoPath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'specialization': specialization,
        'phone': phone,
        'gender': gender,
        'day': day,
        'start_time': startTime,
        'end_time': endTime,
        'home_visit': homeVisit ? '1' : '0',
        'price': price.toStringAsFixed(2),
        if (photoPath != null && photoPath.isNotEmpty)
          'profile_photo': await MultipartFile.fromFile(photoPath),
      });
      final response = await ApiClient.dio.post('/addDoctor', data: formData);
      final data = response.data as Map<String, dynamic>;
      final doctor = data['doctor'];
      final inner = doctor is Map<String, dynamic>
          ? doctor['doctor']
          : null;
      if (inner is! Map<String, dynamic>) {
        throw Exception(data['message']?.toString() ?? 'failed_to_add_doctor'.tr());
      }
      // addDoctor nests the user fields at the top level, so rebuild the
      // DoctorProfileModel shape ({...doctorRow, user:{...}}).
      final profile = Map<String, dynamic>.from(inner)
        ..['user'] = {
          'id': doctor['id'],
          'first_name': doctor['first_name'],
          'last_name': doctor['last_name'],
          'gender': doctor['gender'],
        };
      return DoctorProfileModel.fromJson(profile);
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  Future<DoctorProfileModel> updateDoctor({
    required int doctorId,
    double? price,
    bool? homeVisit,
    String? specialization,
    String? photoPath,
    String? password,
    String? day,
    String? startTime,
    String? endTime,
  }) async {
    try {
      final formData = FormData.fromMap({
        '_method': 'Put',
        if (price != null) 'price': price.toStringAsFixed(2),
        if (homeVisit != null) 'home_visit': homeVisit ? '1' : '0',
        if (specialization != null && specialization.isNotEmpty)
          'specialization': specialization,
        if (password != null && password.isNotEmpty) 'password': password,
        if (password != null && password.isNotEmpty)
          'password_confirmation': password,
        if (day != null && day.isNotEmpty) 'day': day,
        if (startTime != null && startTime.isNotEmpty) 'start_time': startTime,
        if (endTime != null && endTime.isNotEmpty) 'end_time': endTime,
        if (photoPath != null)
          'profile_photo': await MultipartFile.fromFile(photoPath),
      });
      final response = await ApiClient.dio.post(
        '/updateDoctor',
        data: formData,
        queryParameters: {'doctorId': doctorId},
      );
      final data = response.data as Map<String, dynamic>;
      final doctor = data['doctor'];
      if (doctor is! Map<String, dynamic>) {
        throw Exception(data['message']?.toString() ?? 'failed_to_update_doctor'.tr());
      }
      return DoctorProfileModel.fromJson(doctor);
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  Future<void> deleteDoctor(int doctorId) async {
    try {
      await ApiClient.dio.delete(
        '/deleteDoctor',
        queryParameters: {'doctorId': doctorId},
      );
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// Creates a discount offer (addOffer). Dates use the "yyyy-MM-dd"
  /// format expected by the API. Returns the created offer exactly as the
  /// backend confirms it (HTTP 200 `{"message": {...offer...}}`), so the
  /// caller can display it immediately.
  Future<AdminOfferModel> addOffer({
    required String title,
    required String description,
    required double discountPercentage,
    required DateTime validFrom,
    required DateTime validUntil,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'description': description,
        'discount_percentage': discountPercentage.toStringAsFixed(2),
        'valid_from': DateFormat('yyyy-MM-dd').format(validFrom),
        'valid_until': DateFormat('yyyy-MM-dd').format(validUntil),
      });
      final response = await ApiClient.dio.post('/addOffer', data: formData);
      final data = response.data;
      final offerJson = data is Map
          ? (data['message'] is Map<String, dynamic>
              ? data['message'] as Map<String, dynamic>
              : null)
          : null;
      if (offerJson == null) {
        throw Exception('offer_add_failed'.tr());
      }
      return AdminOfferModel.fromJson(offerJson);
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// Inventory items (getItems).
  Future<List<ItemModel>> getItems() async {
    try {
      final response = await ApiClient.dio.get('/getItems');
      final data = response.data as Map<String, dynamic>;
      final list = data['items'];
      if (list is! List) return const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(ItemModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// Consumes one unit of an item (useItem). Returns false when the backend
  /// reports the item is missing or out of stock (item payload is null).
  Future<bool> useItem(int itemId) async {
    try {
      final response =
          await ApiClient.dio.post('/useItem/$itemId');
      final data = response.data as Map<String, dynamic>;
      return data['item'] is Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// Distinct specializations from the backend (GET /getSpcialization,
  /// `{"message":[{"specialization":"Cardiology"},...]}`), used by the
  /// Add/Edit Doctor forms so no specialty list is hardcoded.
  Future<List<String>> getSpecializations() async {
    try {
      final response = await ApiClient.dio.get('/getSpcialization');
      final data = response.data as Map<String, dynamic>;
      final list = data['message'];
      if (list is! List) return const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map((s) => s['specialization']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// Unwraps `{"headers":{},"original":{<key>:[...]},"exception":null}` and
  /// `{"<key>":[...]}` envelopes into the plain list.
  List<dynamic> _unwrapNestedList(dynamic container, String key) {
    if (container is List) return container;
    if (container is Map) {
      final original = container['original'];
      if (original is Map) {
        final inner = original[key];
        if (inner is List) return inner;
      }
    }
    return const [];
  }
}