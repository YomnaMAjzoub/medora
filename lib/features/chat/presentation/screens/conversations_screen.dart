import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';
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
        title: Text('conversations'.tr()),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.conversations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.conversations.isEmpty) {
          return Center(
            child: Text('no_data'.tr()),
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

  bool get _isDoctor => GetStorage().read('role') == 'doctor';

  String get _otherPartyId =>
      _isDoctor ? conversation.patientId : conversation.doctorId;

  String get _title =>
      _isDoctor
          ? '${'patient_title'.tr()} ${conversation.patientId}'
          : '${'doctor_title'.tr()} ${conversation.doctorId}';

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: AppColors.primary100,
        child: Icon(Icons.medical_services, color: AppColors.primary900),
      ),
      title: Text(_title),
      subtitle: Text(
        conversation.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: conversation.lastMessageAt != null
          ? Text(
              DateFormat('HH:mm').format(conversation.lastMessageAt!),
              style: TextStyle(
                fontSize: 12,
                color: context.appColors.textSecondary,
              ),
            )
          : null,
      onTap: () => Get.toNamed(
        AppRouter.chat,
        arguments: {
          'otherPartyId': _otherPartyId,
          'title': _title,
        },
      ),
    );
  }
}
