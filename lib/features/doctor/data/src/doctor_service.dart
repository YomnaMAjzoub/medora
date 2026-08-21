import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medora_git/core/errors/error_handler.dart';
import 'package:medora_git/core/network/api_client.dart';
import 'package:medora_git/core/services/meet_link.dart';
import 'package:medora_git/features/doctor/data/models/doctor_appointment_model.dart';
import 'package:medora_git/features/doctor/data/models/doctor_invoice_model.dart';
import 'package:medora_git/features/doctor/data/models/doctor_patient_model.dart';
import 'package:medora_git/features/doctor/data/models/doctor_work_schedule_model.dart';
import 'package:medora_git/features/doctor/data/models/patient_medical_record_model.dart';
import 'package:medora_git/features/patient/data/models/appointment_record_model.dart';
import 'package:medora_git/features/patient/data/models/doctor_profile_model.dart';

/// Doctor-facing endpoints.
class DoctorService {
  static const _daysOffKey = 'doctor_days_off';
  static const _peakHoursKey = 'doctor_peak_hours';
  static const _profileIdKey = 'doctor_profile_id';
  static const _specializationKey = 'doctor_specialization';
  static const _homeVisitKey = 'doctor_home_visit';
  static const _schedulesKey = 'doctor_schedules';

  /// The logged-in doctor's appointments.
  /// Optional filters: [period] is today|week|month, [type] is
  /// clinic|home|online. The Postman endpoint takes no query parameters,
  /// so the filters are applied client-side.
  Future<List<DoctorAppointmentModel>> getAppointments({
    String? period,
    String? type,
  }) async {
    try {
      final response = await ApiClient.dio.get('/appointmentForDoctor');
      final data = response.data as Map<String, dynamic>;
      final list = data['data'];
      if (list is! List) return const [];
      var items = list
          .whereType<Map<String, dynamic>>()
          .map(DoctorAppointmentModel.fromJson)
          .toList();
      items = _filterByPeriod(items, period);
      if (type != null && type.isNotEmpty) {
        items = items.where((a) => a.type == type).toList();
      }
      return items;
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// The logged-in doctor's consultations (online visits).
  /// Tries GET /getDoctorConsultations first; falls back to the online
  /// appointments of /appointmentForDoctor when the endpoint is missing.
  Future<List<DoctorAppointmentModel>> getConsultations() async {
    try {
      final response = await ApiClient.dio.get('/getDoctorConsultations');
      final data = response.data as Map<String, dynamic>;
      final list = data['message'] is List
          ? data['message']
          : (data['data'] is List ? data['data'] : null);
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(DoctorAppointmentModel.fromJson)
            .toList();
      }
    } on DioException {
      // Endpoint missing: fall back to the appointments payload.
    }
    return getAppointments().then(
      (items) => items.where((a) => a.isOnline).toList(),
    );
  }

  /// The doctor's patients. Tries GET /getDoctorPatients first; falls back
  /// to the unique patients of /appointmentForDoctor.
  Future<List<DoctorPatientModel>> getPatients() async {
    try {
      final response = await ApiClient.dio.get('/getDoctorPatients');
      final data = response.data as Map<String, dynamic>;
      final list = data['message'] is List
          ? data['message']
          : (data['data'] is List ? data['data'] : null);
      if (list is List) {
        final patients = list
            .whereType<Map<String, dynamic>>()
            .map(DoctorPatientModel.fromJson)
            .toList();
        if (patients.isNotEmpty) return patients;
      }
    } on DioException {
      // Endpoint missing: fall back to the appointments payload.
    }
    final appointments = await getAppointments();
    return appointments
        .map((a) => a.patient.id)
        .toSet()
        .map((patientId) {
          final patientAppointments = appointments
              .where((a) => a.patient.id == patientId)
              .toList()
            ..sort((a, b) => b.appointmentTime.compareTo(a.appointmentTime));
          final now = DateTime.now();
          final editable = patientAppointments
              .where((a) =>
                  a.status == AppointmentStatus.completed &&
                  !a.appointmentTime.isAfter(now))
              .toList();
          final latest = editable.isNotEmpty ? editable.first : patientAppointments.first;
          final patient = patientAppointments.first.patient;
          return DoctorPatientModel(
            id: patient.id,
            firstName: patient.firstName,
            lastName: patient.lastName,
            gender: patient.gender,
            phone: patient.phone,
            email: patient.email,
            appointmentsCount: patientAppointments.length,
            lastAppointmentId: latest.id,
            lastVisit: latest.appointmentTime,
          );
        })
        .toList();
  }

  /// The logged-in doctor's own profile.
  ///
  /// Tries the doctor-facing GET /getDoctorProfile first. When the endpoint
  /// is missing (not in the Postman collection yet) it falls back to the
  /// locally cached profile. The patient-only endpoint used before
  /// (/getAllDoctorsForPatient) rejected doctor tokens with
  /// "This service is only for patients", so it must never be called here.
  Future<DoctorProfileModel> getMyProfile() async {
    try {
      final response = await ApiClient.dio.get('/getDoctorProfile');
      final data = response.data as Map<String, dynamic>;
      final payload = data['message'] is Map<String, dynamic>
          ? data['message'] as Map<String, dynamic>
          : (data['data'] is Map<String, dynamic>
              ? data['data'] as Map<String, dynamic>
              : null);
      if (payload != null) {
        final profile = DoctorProfileModel.fromJson(payload);
        await _cacheProfile(profile);
        return profile;
      }
    } catch (_) {
      // Endpoint missing or rejected: fall back to the local profile.
    }
    return _localProfile();
  }

  /// Updates the doctor's own profile (updateDoctorProfile endpoint).
  Future<void> updateMyProfile({
    double? price,
    bool? homeVisit,
    String? specialization,
    String? photoPath,
    String? password,
  }) async {
    try {
      final formData = FormData.fromMap({
        if (homeVisit != null) 'home_visit': homeVisit ? '1' : '0',
        if (specialization != null && specialization.isNotEmpty)
          'specialization': specialization,
        if (price != null) 'price': price.toStringAsFixed(2),
        if (password != null && password.isNotEmpty)
          'password': password,
        if (password != null && password.isNotEmpty)
          'password_confirmation': password,
        if (photoPath != null)
          'profile_photo': await MultipartFile.fromFile(photoPath),
      });
      final response =
          await ApiClient.dio.post('/updateDoctorProfile', data: formData);
      final data = response.data as Map<String, dynamic>;
      final doctor = data['doctor'];
      if (doctor is Map<String, dynamic>) {
        final profile = DoctorProfileModel.fromJson(doctor);
        await _cacheProfile(profile);
      }
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// Persists the resolved profile so later loads work offline and the
  /// doctor's profile id (needed by updateDoctor) survives restarts.
  Future<void> _cacheProfile(DoctorProfileModel profile) async {
    final storage = GetStorage();
    await storage.write(_profileIdKey, profile.id);
    await storage.write(_specializationKey, profile.specialization);
    await storage.write(_homeVisitKey, profile.homeVisit);
    await storage.write(
      _schedulesKey,
      profile.schedules
          .map(
            (s) => {
              'id': s.id,
              'day': s.day,
              'start_time': s.startTime,
              'end_time': s.endTime,
              'price': s.price,
            },
          )
          .toList(),
    );
  }

  /// Builds the doctor profile from local storage when no doctor-facing
  /// profile endpoint is available yet.
  DoctorProfileModel _localProfile() {
    final storage = GetStorage();
    final userId = storage.read<int>('user_id') ?? 0;
    final fullName = storage.read<String>('user_name') ?? '';
    final parts = fullName.split(' ').where((p) => p.isNotEmpty).toList();
    return DoctorProfileModel(
      id: storage.read<int>(_profileIdKey) ?? 0,
      userId: userId,
      profilePhoto: storage.read<String>('user_photo') ?? '',
      specialization: storage.read<String>(_specializationKey) ?? '',
      isAvailable: true,
      homeVisit: storage.read<bool>(_homeVisitKey) ?? false,
      firstName: parts.isEmpty ? '' : parts.first,
      lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
      gender: '',
      schedules: _cachedSchedules(storage),
    );
  }

  List<DoctorScheduleModel> _cachedSchedules(GetStorage storage) {
    final raw = storage.read<List<dynamic>>(_schedulesKey) ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(DoctorScheduleModel.fromJson)
        .toList();
  }

  /// The doctor's work schedule. Tries GET /getDoctorSchedule first; falls
  /// back to the profile schedules plus locally stored days off / peak
  /// hours (the backend does not expose them yet).
  Future<DoctorWorkScheduleModel> getSchedule() async {
    try {
      final response = await ApiClient.dio.get('/getDoctorSchedule');
      final data = response.data as Map<String, dynamic>;
      final payload = data['message'] is Map<String, dynamic>
          ? data['message'] as Map<String, dynamic>
          : (data['data'] is Map<String, dynamic>
              ? data['data'] as Map<String, dynamic>
              : null);
      if (payload != null) {
        return DoctorWorkScheduleModel.fromJson(payload);
      }
    } on DioException {
      // Endpoint missing: fall back to the local plan below.
    }
    final profile = await getMyProfile();
    final storage = GetStorage();
    return DoctorWorkScheduleModel(
      workingDays: profile.schedules
          .map(
            (s) => DoctorWorkDayModel(
              day: s.day,
              startTime: s.startTime,
              endTime: s.endTime,
              price: s.price,
            ),
          )
          .toList(),
      daysOff: (storage.read<List<dynamic>>(_daysOffKey) ?? const [])
          .map((d) => d.toString())
          .toList(),
      peakHours: (storage.read<List<dynamic>>(_peakHoursKey) ?? const [])
          .map((d) => d.toString())
          .toList(),
    );
  }

  /// Persists the schedule. Tries POST /updateDoctorSchedule first; falls
  /// back to local storage so the edit screens stay functional.
  Future<void> updateSchedule(DoctorWorkScheduleModel schedule) async {
    try {
      await ApiClient.dio.post(
        '/updateDoctorSchedule',
        data: {
          'working_days': schedule.workingDays
              .map((d) => d.toJson())
              .toList(),
          'days_off': schedule.daysOff,
          'peak_hours': schedule.peakHours,
        },
      );
    } on DioException {
      // Endpoint missing: persist locally.
    }
    final storage = GetStorage();
    await storage.write(_daysOffKey, schedule.daysOff);
    await storage.write(_peakHoursKey, schedule.peakHours);
    await storage.write(
      _schedulesKey,
      schedule.workingDays
          .map(
            (d) => {
              'id': 0,
              'day': d.day,
              'start_time': d.startTime,
              'end_time': d.endTime,
              'price': d.price,
            },
          )
          .toList(),
    );
  }

  /// The doctor's invoices (view-only). Tries GET /getDoctorInvoices first;
  /// falls back to invoices derived from the doctor's appointments and
  /// session price (deposit = 50% of the fee, matching the booking flow).
  Future<List<DoctorInvoiceModel>> getInvoices() async {
    try {
      final response = await ApiClient.dio.get('/getDoctorInvoices');
      final data = response.data as Map<String, dynamic>;
      final list = data['message'] is List
          ? data['message']
          : (data['data'] is List ? data['data'] : null);
      if (list is List) {
        final invoices = list
            .whereType<Map<String, dynamic>>()
            .map(DoctorInvoiceModel.fromJson)
            .toList();
        if (invoices.isNotEmpty) return invoices;
      }
    } on DioException {
      // Endpoint missing: fall back to derived invoices below.
    }
    final profile = await getMyProfile();
    final appointments = await getAppointments();
    return appointments
        .where((a) => a.status != AppointmentStatus.cancelled)
        .map((a) => _invoiceFromAppointment(a, profile.pricePerSession))
        .toList()
      ..sort((a, b) => b.appointmentTime.compareTo(a.appointmentTime));
  }

  /// Confirms a pending appointment on the doctor side (app-confirm).
  Future<void> confirmAppointment({required int appointmentId}) async {
    try {
      await ApiClient.dio.post('/appointments/$appointmentId/app-confirm');
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// Cancels an appointment on the doctor side (app-cancel). The older
  /// paymentCancel endpoint 500s (payments.status rejects 'cancelled'), so
  /// cancellations go through the appointment route instead.
  Future<void> cancelAppointment({required int appointmentId}) async {
    try {
      await ApiClient.dio.post('/appointments/$appointmentId/app-cancel');
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// Ends an online consultation. Tries POST /endConsultation first; when
  /// the endpoint is missing it falls back to completeFinalPayment so the
  /// appointment moves to the completed state.
  Future<void> endConsultation({required int appointmentId}) async {
    try {
      await ApiClient.dio.post(
        '/endConsultation',
        data: {'appointment_id': appointmentId},
      );
      return;
    } on DioException {
      // Endpoint missing: fall through to the final-payment endpoint.
    }
    await completeFinalPayment(appointmentId: appointmentId);
  }

  /// A Google Meet room for a brand-new consultation (not tied to an
  /// appointment): deterministic code derived from the current time.
  String newConsultationMeetLink() {
    final userId = GetStorage().read<int>('user_id') ?? 0;
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return MeetLink.forAppointment(appointmentId: timestamp, seed: userId);
  }

  /// Medical records of a patient (the path id is the patient's user id).
  Future<PatientMedicalRecordModel> getPatientMedicalRecords(
    int patientId,
  ) async {
    try {
      final response =
          await ApiClient.dio.get('/getMedicalRecord/$patientId');
      final data = response.data as Map<String, dynamic>;
      final inner = data['data'];
      if (inner is! Map<String, dynamic>) {
        throw Exception('failed_to_load_records'.tr());
      }
      return PatientMedicalRecordModel.fromJson(inner);
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  Future<void> updateMedicalRecord({
    required int appointmentId,
    String? diagnosis,
    String? prescription,
    String? tests,
    String? notes,
    String? imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'appointment_id': appointmentId,
        if (diagnosis != null && diagnosis.isNotEmpty)
          'diagnosis': diagnosis,
        if (prescription != null && prescription.isNotEmpty)
          'prescription': prescription,
        if (tests != null && tests.isNotEmpty) 'tests': tests,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (imagePath != null)
          'images': await MultipartFile.fromFile(imagePath),
      });
      final response =
          await ApiClient.dio.post('/updateMedicalRecord', data: formData);
      final data = response.data as Map<String, dynamic>;
      final inner = data['data'];
      if (inner is Map<String, dynamic>) {
        final status = inner['status']?.toString();
        if (status != null && status != 'success') {
          throw Exception(inner['message']?.toString() ?? 'update_failed'.tr());
        }
        if (status == null && inner['message'] != null) {
          throw Exception(inner['message'].toString());
        }
      }
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// Marks a confirmed appointment as fully paid (completeFinalPayment).
  ///
  /// The endpoint returns HTTP 200 even when it rejects the request, wrapping
  /// the real result inside the serialized Laravel Response:
  /// `{"message": "...", "data": {"original": {"status": "error", "message": "..."}}}`
  /// (e.g. "this appointment is already completed and fully paid"). The
  /// wrapped `status` is checked so those errors surface to the UI instead
  /// of being silently treated as success.
  Future<void> completeFinalPayment({required int appointmentId}) async {
    try {
      final response = await ApiClient.dio.get(
        '/completeFinalPayment',
        queryParameters: {'appointment_id': appointmentId},
      );
      final data = response.data;
      if (data is Map) {
        final inner = data['data'];
        if (inner is Map) {
          final original = inner['original'];
          if (original is Map) {
            final status = original['status']?.toString();
            final message = original['message']?.toString();
            if (status != null && status.toLowerCase() == 'error') {
              throw Exception(message ?? 'final_payment_failed'.tr());
            }
          }
        }
      }
    } on DioException catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  /// Derives a view-only invoice from an appointment: the session price is
  /// the invoice total, the deposit is half of it (the booking flow charges
  /// 50% up front), the remainder is what is still due.
  DoctorInvoiceModel _invoiceFromAppointment(
    DoctorAppointmentModel appointment,
    double sessionPrice,
  ) {
    final total = sessionPrice;
    final deposit = total * 0.5;
    final remaining = switch (appointment.status) {
      AppointmentStatus.pendingDeposit => total,
      AppointmentStatus.confirmed => total - deposit,
      AppointmentStatus.completed => 0.0,
      _ => total,
    };
    final status = switch (appointment.status) {
      AppointmentStatus.pendingDeposit => InvoiceStatus.unpaid,
      AppointmentStatus.confirmed => InvoiceStatus.partial,
      AppointmentStatus.completed => InvoiceStatus.paid,
      _ => InvoiceStatus.unpaid,
    };
    return DoctorInvoiceModel(
      id: '${appointment.id}',
      patientName: appointment.patient.fullName,
      appointmentTime: appointment.appointmentTime,
      type: appointment.type,
      status: status,
      total: total,
      deposit: appointment.status == AppointmentStatus.completed
          ? total
          : deposit,
      remaining: remaining,
      paidAt: appointment.status == AppointmentStatus.completed
          ? appointment.appointmentTime
          : null,
    );
  }

  List<DoctorAppointmentModel> _filterByPeriod(
    List<DoctorAppointmentModel> items,
    String? period,
  ) {
    if (period == null || period.isEmpty) return items;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return items.where((a) {
      final date = a.appointmentTime;
      switch (period) {
        case 'today':
          final day = DateTime(date.year, date.month, date.day);
          return day == today;
        case 'week':
          final start = today.subtract(Duration(days: today.weekday - 1));
          final end = start.add(const Duration(days: 7));
          return !date.isBefore(start) && date.isBefore(end);
        case 'month':
          return date.year == now.year && date.month == now.month;
        default:
          return true;
      }
    }).toList();
  }
}