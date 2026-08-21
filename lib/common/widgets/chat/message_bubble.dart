import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:intl/intl.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/chat/business_layer/controller/chat_controller.dart';
import 'package:medora_git/features/chat/data/models/chat_message_model.dart';

/// A chat bubble shared by the patient/doctor chat screen and the doctor's
/// consultation chat.
class MessageBubble extends GetView<ChatController> {
  const MessageBubble({super.key, required this.message});

  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final isMine = message.senderId == controller.currentUserId;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMine ? context.appColors.primary : context.appColors.border,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color:
                    isMine ? AppColors.white : context.appColors.textPrimary,
                fontSize: 15,
              ),
            ),
            if (message.createdAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  DateFormat('HH:mm').format(message.createdAt!),
                  style: TextStyle(
                    fontSize: 11,
                    color: isMine
                        ? AppColors.white.withValues(alpha: 0.7)
                        : context.appColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}