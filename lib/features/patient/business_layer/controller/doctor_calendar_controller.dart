import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart' hide Trans;
import 'package:medora_git/features/patient/business_layer/controller/booking_controller.dart';
import 'package:medora_git/features/patient/data/models/appointment_model.dart';
import 'package:medora_git/features/patient/data/models/doctor_calendar_slot_model.dart';
import 'package:medora_git/features/patient/data/src/doctor_calendar_service.dart';

class DoctorCalendarController extends GetxController {
  DoctorCalendarController({DoctorCalendarService? service})
      : _service = service ?? DoctorCalendarService();

  final DoctorCalendarService _service;

  /// The clinic's fixed operating window: 8:00 AM - 10:00 PM. Home visit
  /// and online bookings may only be placed inside this window, outside
  /// the doctor's in-clinic hours.
  static const int clinicOpenHour = 8;
  static const int clinicCloseHour = 22;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<CalendarSlotModel> slots = <CalendarSlotModel>[].obs;
  final Rxn<CalendarSlotModel> selectedSlot = Rxn<CalendarSlotModel>();

  int _doctorId = 0;
  final Map<String, List<CalendarSlotModel>> _dayCache = {};

  @override
  void onInit() {
    super.onInit();
    _doctorId = _resolveDoctorId();
    // Changing the visit type (clinic -> home/online) flips which slots are
    // selectable, so any previously picked slot must be cleared.
    if (Get.isRegistered<BookingController>()) {
      ever(
        Get.find<BookingController>().selectedVisitType,
        (_) => selectedSlot.value = null,
      );
    }
    fetchCalendar(doctorId: _doctorId, date: _formatDate(selectedDate.value));
  }

  /// The visit type the booking flow is currently in. Defaults to clinic
  /// when no booking flow is active (e.g. standalone calendar usage).
  VisitType get _visitType {
    if (!Get.isRegistered<BookingController>()) return VisitType.clinic;
    return Get.find<BookingController>().selectedVisitType.value ??
        VisitType.clinic;
  }

  /// Whether a slot may be booked for the current visit type:
  ///  - Clinic (in-person): the doctor's normal in-clinic working hours.
  ///  - Home visit / Online: the hours OUTSIDE the doctor's in-clinic
  ///    schedule, within the clinic's 8:00 AM - 10:00 PM window.
  bool isSlotBookable(CalendarSlotModel slot) {
    final hour = int.tryParse(slot.time.split(':').first) ?? -1;
    if (hour < clinicOpenHour || hour >= clinicCloseHour) return false;
    return _visitType == VisitType.clinic
        ? slot.isBookable
        : slot.isOffClinicBookable;
  }

  /// Slots the user is allowed to book for the current visit type.
  List<CalendarSlotModel> get bookableSlots =>
      slots.where(isSlotBookable).toList();

  bool isDayCached(DateTime date) => _dayCache.containsKey(_formatDate(date));

  Future<void> fetchCalendar({
    required int doctorId,
    required String date,
  }) async {
    if (_dayCache.containsKey(date)) {
      slots.assignAll(_dayCache[date]!);
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _service.getDoctorMonthlyCalendar(
        doctorId: doctorId,
        date: date,
      );
      _dayCache[date] = response.slots;
      slots.assignAll(response.slots);
      selectedSlot.value = null;
    } catch (e) {
      errorMessage.value = e.toString();
      _showSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void selectSlot(CalendarSlotModel slot) {
    if (isSlotBookable(slot)) {
      selectedSlot.value = slot;
    } else {
      _showSnackbar(
        'warning'.tr(),
        'slot_not_available'.tr(),
      );
    }
  }

  void selectCalendarDate(DateTime date) {
    final key = _formatDate(date);
    selectedDate.value = date;
    if (_dayCache.containsKey(key)) {
      slots.assignAll(_dayCache[key]!);
      selectedSlot.value = null;
      return;
    }
    fetchCalendar(doctorId: _doctorId, date: key);
  }

  /// Loads availability for a specific doctor (used by the booking flow,
  /// where the doctor is only known once step 1 is completed).
  void loadForDoctor(int doctorId) {
    _doctorId = doctorId;
    _dayCache.clear();
    selectedSlot.value = null;
    fetchCalendar(doctorId: doctorId, date: _formatDate(selectedDate.value));
  }

  /// doctor_id resolution order: Get.arguments -> selected doctor from the
  /// booking flow -> fallback placeholder.
  int _resolveDoctorId() {
    final args = Get.arguments;
    if (args is int) return args;
    if (args is Map) {
      final id = _parseId(args['doctor_id'] ?? args['doctorId']);
      if (id != null) return id;
    }
    if (Get.isRegistered<BookingController>()) {
      final doctor = Get.find<BookingController>().selectedDoctor.value;
      final id = doctor == null ? null : int.tryParse(doctor.id);
      if (id != null) return id;
    }
    return 1;
  }

  int? _parseId(dynamic id) {
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  static String _formatDate(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  void _showSnackbar(String title, String message) {
    // The snackbar needs a live navigator; without one (e.g. during early
    // controller startup or tests) the rejection is silently ignored.
    if (Get.context == null) return;
    try {
      Get.closeAllSnackbars();
      Get.snackbar(title, message);
    } catch (_) {
      // Navigator not ready yet; nothing to show.
    }
  }
}
