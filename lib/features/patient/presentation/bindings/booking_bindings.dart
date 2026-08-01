import 'package:get/get.dart';

import 'package:medora_git/features/patient/business_layer/controller/booking_controller.dart';

class BookingBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingController>(() => BookingController());
  }
}
