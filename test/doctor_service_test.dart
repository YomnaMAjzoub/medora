import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medora_git/core/network/api_client.dart';
import 'package:medora_git/features/doctor/data/src/doctor_service.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.respondWith);

  /// The exact body returned by the real backend (HTTP 200).
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

  test('completeFinalPayment surfaces the wrapped backend error', () async {
    ApiClient.dio.httpClientAdapter = _FakeAdapter({
      'message': 'Final payment completed and appointment marked as completed',
      'data': {
        'headers': <String, dynamic>{},
        'original': {
          'status': 'error',
          'message': 'Sorry, this appointment is already completed '
              'and fully paid. You cannot make another payment.',
        },
        'exception': null,
      },
    });

    final service = DoctorService();
    expect(
      () => service.completeFinalPayment(appointmentId: 20),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('already completed'),
        ),
      ),
    );
  });

  test('completeFinalPayment succeeds when there is no wrapped error', () async {
    ApiClient.dio.httpClientAdapter = _FakeAdapter({
      'message': 'Final payment completed and appointment marked as completed',
      'data': {
        'headers': <String, dynamic>{},
        'original': {
          'status': 'success',
          'message': 'Payment completed',
        },
        'exception': null,
      },
    });

    final service = DoctorService();
    await service.completeFinalPayment(appointmentId: 20);
  });
}