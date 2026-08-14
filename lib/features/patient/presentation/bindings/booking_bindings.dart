import 'package:get/get.dart';

import 'package:medora_git/features/patient/business_layer/controller/booking_controller.dart';
import 'package:medora_git/features/patient/business_layer/controller/doctor_discovery_controller.dart';

class BookingBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingController>(() => BookingController());
    if (!Get.isRegistered<DoctorDiscoveryController>()) {
      Get.lazyPut<DoctorDiscoveryController>(
        () => DoctorDiscoveryController(),
      );
    }
  }
}
