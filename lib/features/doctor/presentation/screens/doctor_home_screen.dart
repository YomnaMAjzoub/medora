import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/doctor/business_layer/controller/doctor_controller.dart';
import 'package:medora_git/features/doctor/data/models/doctor_appointment_model.dart';
import 'package:medora_git/features/patient/data/models/appointment_record_model.dart';

/// Doctor panel home: the logged-in doctor's appointments for today,
/// fetched from appointmentForDoctor.
class DoctorHomeScreen extends GetView<DoctorController> {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          'doctor_panel'.tr(),
          style: GoogleFonts.roboto(
            color: AppColors.primary700,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary700),
            );
          }
          if (controller.errorMessage.value.isNotEmpty &&
              controller.appointments.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: controller.fetchAppointments,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary900,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('retry'.tr()),
                    ),
                  ],
                ),
              ),
            );
          }
          if (controller.appointments.isEmpty) {
            return Center(
              child: Text(
                'no_appointments_today'.tr(),
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: context.appColors.textSecondary,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            itemCount: controller.appointments.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final appointment = controller.appointments[index];
              return _AppointmentRow(
                appointment: appointment,
                onTap: () => Get.toNamed(
                  AppRouter.medicalRecord,
                  arguments: {
                    'appointmentId': appointment.id,
                    'patientId': appointment.patient.id,
                    'status': appointment.status.name,
                  },
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  const _AppointmentRow({required this.appointment, required this.onTap});

  final DoctorAppointmentModel appointment;
  final VoidCallback onTap;

  Color get _statusColor {
    switch (appointment.status) {
      case AppointmentStatus.pendingDeposit:
        return AppColors.primary800;
      case AppointmentStatus.confirmed:
        return AppColors.primary700;
      case AppointmentStatus.completed:
        return const Color(0xFF2E7D32);
      case AppointmentStatus.cancelled:
        return const Color(0xFFC62828);
      case AppointmentStatus.unknown:
        return AppColors.grey500;
    }
  }

  String get _statusLabel {
    switch (appointment.status) {
      case AppointmentStatus.pendingDeposit:
        return 'pending_deposit'.tr();
      case AppointmentStatus.confirmed:
        return 'confirmed'.tr();
      case AppointmentStatus.completed:
        return 'completed'.tr();
      case AppointmentStatus.cancelled:
        return 'cancelled'.tr();
      case AppointmentStatus.unknown:
        return appointment.status.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = appointment.appointmentTime;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary900.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary900.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.primary800,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.patient.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('h:mm a').format(time)} - '
                    '${appointment.type.capitalizeFirst ?? appointment.type}',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusLabel,
                style: GoogleFonts.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _statusColor,
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'chat_title'.tr(),
              onPressed: () => Get.toNamed(
                AppRouter.chat,
                arguments: {
                  'otherPartyId': '${appointment.patient.id}',
                  'title': appointment.patient.fullName,
                },
              ),
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              color: AppColors.primary700,
              iconSize: 20,
              padding: const EdgeInsets.all(6),
            ),
            if (appointment.isOnline) ...[
              const SizedBox(width: 2),
              IconButton(
                tooltip: 'join_meeting'.tr(),
                onPressed: () => _joinMeeting(context),
                icon: const Icon(Icons.videocam_rounded),
                color: AppColors.primary700,
                iconSize: 20,
                padding: const EdgeInsets.all(6),
              ),
            ],
            Icon(
              Icons.chevron_right_rounded,
              color: context.appColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _joinMeeting(BuildContext context) {
    final link = appointment.resolvedMeetLink;
    Get.defaultDialog(
      title: 'join_meeting'.tr(),
      middleText: link,
      textCancel: 'cancel'.tr(),
      textConfirm: 'join'.tr(),
      confirmTextColor: AppColors.white,
      buttonColor: AppColors.primary900,
      onConfirm: () {
        Get.back();
        launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
      },
    );
  }
}