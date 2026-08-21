import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medora_git/common/widgets/chat/chat_input_bar.dart';
import 'package:medora_git/common/widgets/chat/message_bubble.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/chat/business_layer/controller/chat_controller.dart';
import 'package:medora_git/features/doctor/business_layer/controller/doctor_controller.dart';

/// An online consultation: chat with the patient plus a video-call shortcut
/// (Google Meet) and an "End consultation" action that completes the
/// appointment.
class ConsultationChatScreen extends StatefulWidget {
  const ConsultationChatScreen({super.key});

  @override
  State<ConsultationChatScreen> createState() => _ConsultationChatScreenState();
}

class _ConsultationChatScreenState extends State<ConsultationChatScreen> {
  final TextEditingController _inputController = TextEditingController();

  late final int _appointmentId =
      (Get.arguments as Map)['appointmentId'] as int;
  late final String _patientId =
      (Get.arguments as Map)['patientId'].toString();
  late final String _title = (Get.arguments as Map)['title'] as String? ?? '';

  @override
  void initState() {
    super.initState();
    Get.find<ChatController>().openConversation(otherPartyId: _patientId);
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

  /// Opens the Google Meet link the backend generated for this appointment
  /// (available once the final payment completes it).
  void _startVideoCall() {
    final appointment =
        Get.find<DoctorController>().appointmentById(_appointmentId);
    final link = appointment?.resolvedMeetLink;
    if (link == null || link.isEmpty) {
      Get.snackbar('info'.tr(), 'no_meeting_link'.tr());
      return;
    }
    Get.defaultDialog(
      title: 'start_video_call'.tr(),
      middleText: link,
      textCancel: 'cancel'.tr(),
      textConfirm: 'join'.tr(),
      confirmTextColor: AppColors.white,
      buttonColor: Get.context!.appColors.primaryContainer,
      onConfirm: () {
        Get.back();
        launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
      },
    );
  }

  void _endConsultation() {
    Get.defaultDialog(
      title: 'end_consultation'.tr(),
      middleText: 'end_consultation_confirm'.tr(),
      textCancel: 'not_yet'.tr(),
      textConfirm: 'end_consultation'.tr(),
      confirmTextColor: AppColors.white,
      buttonColor: context.appColors.danger,
      onConfirm: () async {
        Get.back();
        await Get.find<DoctorController>()
            .endConsultation(appointmentId: _appointmentId);
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.primaryContainer,
        foregroundColor: AppColors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _title.isEmpty ? 'consultation'.tr() : _title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'online'.tr(),
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'start_video_call'.tr(),
            onPressed: _startVideoCall,
            icon: const Icon(Icons.videocam_rounded),
          ),
        ],
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
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                border: Border(
                  top: BorderSide(color: context.appColors.border),
                ),
              ),
              child: Obx(
                () => OutlinedButton.icon(
                  onPressed:
                      Get.find<DoctorController>()
                                  .processingAppointmentId.value ==
                              _appointmentId
                          ? null
                          : _endConsultation,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.appColors.danger,
                    side: BorderSide(
                      color: context.appColors.danger,
                      width: 1.2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.call_end_rounded, size: 18),
                  label: Text(
                    'end_consultation'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}