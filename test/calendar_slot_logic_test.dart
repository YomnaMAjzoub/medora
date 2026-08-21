import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:medora_git/features/patient/business_layer/controller/booking_controller.dart';
import 'package:medora_git/features/patient/business_layer/controller/doctor_calendar_controller.dart';
import 'package:medora_git/features/patient/data/models/appointment_model.dart';
import 'package:medora_git/features/patient/data/models/doctor_calendar_slot_model.dart';
import 'package:medora_git/features/patient/data/src/booking_service.dart';

/// Regression test for the booking time-slot logic (Bug 2):
///  - Clinic: only in-clinic hours are bookable.
///  - Home/Online: only hours OUTSIDE the doctor's in-clinic schedule, within
///    the clinic's 8 AM - 10 PM window, are bookable.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
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

  // Real response captured from GET /getDoctorMonthlyCalendar (doctor_id=1,
  // 2026-08-22): in-clinic 09:00-18:30, off-clinic 19:00-21:30.
  List<CalendarSlotModel> buildSlots() {
    List<Map<String, dynamic>> rows() {
      final out = <Map<String, dynamic>>[];
      for (var h = 9; h <= 21; h++) {
        for (final m in [0, 30]) {
          final isClinic = h <= 18;
          out.add({
            'time': '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}',
            'full_date': '2026-08-22 ${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:00',
            'is_booked': false,
            'status': 'available',
            'is_clinic_hour': isClinic,
            'display_type': isClinic ? 'available' : 'clinic_offline',
          });
        }
      }
      return out;
    }

    return rows().map(CalendarSlotModel.fromJson).toList();
  }

  test('parses the real backend response structure correctly', () {
    final resp = DoctorCalendarResponseModel.fromJson({'slots': buildSlots().map((s) => s.toJson()).toList()});
    expect(resp.slots.length, 26);
    expect(resp.slots.first.isClinicHour, isTrue);
    expect(resp.slots.last.isClinicHour, isFalse);
  });

  group('slot bookability by visit type', () {
    late DoctorCalendarController controller;
    late BookingController booking;

    setUp(() {
      Get.reset();
      booking = BookingController(bookingService: BookingService());
      Get.put<BookingController>(booking);
      controller = DoctorCalendarController();
      controller.slots.assignAll(buildSlots());
    });

    tearDown(() => Get.reset());

    test('clinic visit bookable slots are exactly the in-clinic hours', () {
      booking.selectedVisitType.value = VisitType.clinic;
      final bookable = controller.bookableSlots;
      expect(bookable, isNotEmpty);
      for (final slot in bookable) {
        expect(slot.isClinicHour, isTrue, reason: '${slot.time} must be in-clinic');
        final hour = int.parse(slot.time.split(':').first);
        expect(hour, inInclusiveRange(8, 18));
      }
      expect(bookable.map((s) => s.time), contains('09:00'));
      expect(bookable.map((s) => s.time), contains('18:30'));
      expect(bookable.map((s) => s.time), isNot(contains('19:00')));
    });

    test('home visit bookable slots are only outside in-clinic hours', () {
      booking.selectedVisitType.value = VisitType.home;
      final bookable = controller.bookableSlots;
      expect(bookable, isNotEmpty);
      for (final slot in bookable) {
        expect(slot.isClinicHour, isFalse, reason: '${slot.time} must be OFF clinic');
        final hour = int.parse(slot.time.split(':').first);
        expect(hour, inInclusiveRange(8, 21));
        expect(hour, greaterThanOrEqualTo(19));
      }
      expect(bookable.map((s) => s.time), contains('19:00'));
      expect(bookable.map((s) => s.time), contains('21:30'));
      expect(bookable.map((s) => s.time), isNot(contains('09:00')));
      expect(bookable.map((s) => s.time), isNot(contains('18:30')));
    });

    test('online visit bookable slots are only outside in-clinic hours', () {
      booking.selectedVisitType.value = VisitType.online;
      final bookable = controller.bookableSlots;
      expect(bookable, isNotEmpty);
      for (final slot in bookable) {
        expect(slot.isClinicHour, isFalse);
      }
      expect(bookable.map((s) => s.time), contains('19:00'));
      expect(bookable.map((s) => s.time), contains('21:30'));
    });

    test('changing visit type updates which slots are bookable', () {
      booking.selectedVisitType.value = VisitType.clinic;
      expect(controller.isSlotBookable(controller.slots.first), isTrue);
      booking.selectedVisitType.value = VisitType.home;
      expect(controller.isSlotBookable(controller.slots.first), isFalse);
      expect(
        controller.isSlotBookable(controller.slots.last),
        isTrue,
      );
    });

    test('selecting a non-bookable slot is rejected', () {
      booking.selectedVisitType.value = VisitType.online;
      final inClinicSlot = controller.slots.firstWhere((s) => s.isClinicHour);
      controller.selectSlot(inClinicSlot);
      expect(controller.selectedSlot.value, isNull);
    });
  });
}