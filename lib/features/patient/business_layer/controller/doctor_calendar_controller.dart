import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medora_git/features/patient/business_layer/controller/booking_controller.dart';
import 'package:medora_git/features/patient/data/models/doctor_calendar_slot_model.dart';
import 'package:medora_git/features/patient/data/src/doctor_calendar_service.dart';

class DoctorCalendarController extends GetxController {
  DoctorCalendarController({DoctorCalendarService? service})
      : _service = service ?? DoctorCalendarService();

  final DoctorCalendarService _service;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<CalendarSlotModel> slots = <CalendarSlotModel>[].obs;
  final Rxn<CalendarSlotModel> selectedSlot = Rxn<CalendarSlotModel>();

  late final int _doctorId;
  final Map<String, List<CalendarSlotModel>> _dayCache = {};

  /// Slots the user is allowed to book (clinic hour + not booked + available).
  List<CalendarSlotModel> get bookableSlots =>
      slots.where((slot) => slot.isBookable).toList();

  bool isDayCached(DateTime date) => _dayCache.containsKey(_formatDate(date));

  @override
  void onInit() {
    super.onInit();
    _doctorId = _resolveDoctorId();
    fetchCalendar(doctorId: _doctorId, date: _formatDate(selectedDate.value));
  }

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
    if (slot.isBookable) {
      selectedSlot.value = slot;
    } else {
      _showSnackbar(
        'Warning',
        'This slot is not available, please pick another time.',
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
    Get.closeAllSnackbars();
    Get.snackbar(title, message);
  }
}
