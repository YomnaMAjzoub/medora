import 'package:get/get.dart';

import 'package:medora_git/features/patient/business_layer/controller/doctor_discovery_controller.dart';

class DoctorDiscoveryBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorDiscoveryController>(() => DoctorDiscoveryController());
  }
}