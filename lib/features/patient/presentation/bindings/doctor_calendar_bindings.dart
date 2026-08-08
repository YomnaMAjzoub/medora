import 'package:get/get.dart';
import 'package:medora_git/features/patient/business_layer/controller/doctor_calendar_controller.dart';
import 'package:medora_git/features/patient/data/src/doctor_calendar_service.dart';

class DoctorCalendarBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorCalendarService>(() => DoctorCalendarService());
    Get.lazyPut<DoctorCalendarController>(
      () => DoctorCalendarController(
        service: Get.find<DoctorCalendarService>(),
      ),
    );
  }
}
