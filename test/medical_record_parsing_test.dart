import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medora_git/core/network/api_client.dart';
import 'package:medora_git/features/doctor/data/models/patient_medical_record_model.dart';
import 'package:medora_git/features/patient/data/src/patient_service.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.respondWith);

  final Map<String, dynamic> respondWith;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(respondWith),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// The exact payload the backend returned for GET /getMedicalRecord/18.
Map<String, dynamic> realMedicalRecordPayload() {
  return {
    'data': {
      'status': 'success',
      'patient_details': {
        'id': 6,
        'user_id': 18,
        'blood_type': 'A-',
        'previous_illnesses': null,
        'created_at': '2026-08-18T14:30:02.000000Z',
        'updated_at': '2026-08-18T14:30:02.000000Z',
        'user': {
          'id': 18,
          'first_name': 'yomna',
          'last_name': 'mj',
          'gender': 'female',
          'birth': '2000-01-03',
          'email': 'yomnamajzoub@gmail.com',
        },
      },
      'medical_records': [
        {
          'diagnosis': 'lkjhgfdeنمتالبي',
          'prescription': '.lkjhgfds',
          'tests': null,
          'images': null,
          'notes': ';olikujyhtgrte',
          'appointment_time': '2026-08-19 16:00:00',
          'type': 'clinic',
          'doctor_name': 'doctor fem',
          'doctor_specialization': null,
        },
      ],
    },
  };
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return Directory.systemTemp.path;
      }
      return null;
    });
    await GetStorage.init();
  });

  test('doctor medical record model parses the real getMedicalRecord payload',
      () {
    final model =
        PatientMedicalRecordModel.fromJson(realMedicalRecordPayload()['data'] as Map<String, dynamic>);

    expect(model.id, 6);
    expect(model.userId, 18);
    expect(model.bloodType, 'A-');
    expect(model.fullName, 'yomna mj');
    expect(model.gender, 'female');
    expect(model.email, 'yomnamajzoub@gmail.com');
    expect(model.records, hasLength(1));
    final record = model.records.first;
    expect(record.diagnosis, 'lkjhgfdeنمتالبي');
    expect(record.prescription, '.lkjhgfds');
    expect(record.notes, ';olikujyhtgrte');
    expect(record.doctorName, 'doctor fem');
    expect(record.type, 'clinic');
    expect(record.appointmentTime, DateTime(2026, 8, 19, 16, 0));
  });

  test('patient service fetches records via getMedicalRecord/{user_id}', () async {
    GetStorage().write('user_id', 18);
    ApiClient.dio.httpClientAdapter = _FakeAdapter(realMedicalRecordPayload());

    final service = PatientService();
    final records = await service.getMedicalRecords();

    expect(records, hasLength(1));
    expect(records.first.doctorName, 'doctor fem');
    expect(records.first.appointmentTime, DateTime(2026, 8, 19, 16, 0));
  });
}