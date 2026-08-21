import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:medora_git/common/widgets/chat/chat_input_bar.dart';
import 'package:medora_git/common/widgets/chat/message_bubble.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/chat/business_layer/controller/chat_controller.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    final otherPartyId = args['otherPartyId'] as String;
    Get.find<ChatController>().openConversation(otherPartyId: otherPartyId);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _send() {
    Get.find<ChatController>().sendMessage(_inputController.text);
    _inputController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final title = args['title'] as String? ?? 'chat_title'.tr();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.appColors.primaryContainer,
        foregroundColor: AppColors.white,
        title: Text(title),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final controller = Get.find<ChatController>();
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(color: context.appColors.primary),
                );
              }
              if (controller.errorMessage.value.isNotEmpty &&
                  controller.messages.isEmpty) {
                return Center(child: Text(controller.errorMessage.value));
              }
              if (controller.messages.isEmpty) {
                return Center(child: Text('no_data'.tr()));
              }
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(12),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message =
                      controller.messages[controller.messages.length - 1 - index];
                  return MessageBubble(message: message);
                },
              );
            }),
          ),
          ChatInputBar(controller: _inputController, onSend: _send),
        ],
      ),
    );
  }
}