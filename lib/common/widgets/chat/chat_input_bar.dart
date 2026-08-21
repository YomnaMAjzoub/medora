import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';

/// The message input bar shared by the chat screens.
class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.onAttach,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onAttach;

  void _submit() {
    if (controller.text.trim().isEmpty) return;
    onSend();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          border: Border(top: BorderSide(color: context.appColors.border)),
        ),
        child: Row(
          children: [
            if (onAttach != null) ...[
              IconButton(
                onPressed: onAttach,
                icon: Icon(
                  Icons.attach_file_rounded,
                  color: context.appColors.primary,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: 'message_hint'.tr(),
                  filled: true,
                  fillColor: context.appColors.inputFill,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _submit,
              icon: const Icon(Icons.send),
              style: IconButton.styleFrom(
                backgroundColor: context.appColors.primaryContainer,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}