import 'package:get/get.dart';

import 'package:medora_git/features/patient/business_layer/controller/patient_account_controller.dart';

class PatientAccountBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PatientAccountController>(() => PatientAccountController());
  }
}