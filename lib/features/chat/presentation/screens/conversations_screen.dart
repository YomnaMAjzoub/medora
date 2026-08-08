import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/features/chat/business_layer/controller/chat_controller.dart';
import 'package:medora_git/features/chat/data/models/conversation_model.dart';

class ConversationsScreen extends GetView<ChatController> {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary900,
        foregroundColor: AppColors.white,
        title: const Text('Chats'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.conversations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.conversations.isEmpty) {
          return const Center(
            child: Text('No conversations yet.'),
          );
        }
        return ListView.separated(
          itemCount: controller.conversations.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final conversation = controller.conversations[index];
            return _ConversationTile(conversation: conversation);
          },
        );
      }),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation});

  final ConversationModel conversation;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: AppColors.primary100,
        child: Icon(Icons.medical_services, color: AppColors.primary900),
      ),
      title: Text('Doctor ${conversation.doctorId}'),
      subtitle: Text(
        conversation.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: conversation.lastMessageAt != null
          ? Text(
              DateFormat('HH:mm').format(conversation.lastMessageAt!),
              style: const TextStyle(fontSize: 12, color: AppColors.neutral500),
            )
          : null,
      onTap: () => Get.toNamed(
        AppRouter.chat,
        arguments: {
          'doctorId': conversation.doctorId,
          'title': 'Doctor ${conversation.doctorId}',
        },
      ),
    );
  }
}
