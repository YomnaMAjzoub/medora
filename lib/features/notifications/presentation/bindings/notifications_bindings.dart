import 'package:get/get.dart';

import 'package:medora_git/features/notifications/business_layer/controller/notifications_controller.dart';

class NotificationsBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationsController>(() => NotificationsController());
  }
}