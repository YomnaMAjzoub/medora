import 'package:get/get.dart';

import 'package:medora_git/features/doctor/business_layer/controller/doctor_controller.dart';

class DoctorBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorController>(() => DoctorController());
  }
}