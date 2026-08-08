import 'package:get/get.dart';
import 'package:medora_git/features/chat/business_layer/controller/chat_controller.dart';

class ChatBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(() => ChatController());
  }
}
