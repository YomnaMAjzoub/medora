import 'package:get/get.dart';

import 'package:medora_git/features/admin/business_layer/controller/admin_controller.dart';

class AdminBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminController>(() => AdminController());
  }
}