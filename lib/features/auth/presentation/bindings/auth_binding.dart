import 'package:get/get.dart';
import 'package:medora_git/features/auth/business_layer/controller/auth_controller.dart';


class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }

}