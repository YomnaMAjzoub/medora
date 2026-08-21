import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/doctor/business_layer/controller/doctor_controller.dart';
import 'package:medora_git/features/doctor/data/models/doctor_appointment_model.dart';
import 'package:medora_git/features/patient/data/models/appointment_record_model.dart';

/// Appointment details: the patient, the visit info and the actions the
/// doctor can take (confirm / complete / cancel / start consultation /
/// view medical file / chat).
class DoctorAppointmentDetailsScreen extends StatelessWidget {
  const DoctorAppointmentDetailsScreen({super.key});

  int get _appointmentId => (Get.arguments as Map)['appointmentId'] as int;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          'appointment_details'.tr(),
          style: GoogleFonts.inter(
            color: context.appColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final appointment = controller.appointmentById(_appointmentId);
          if (appointment == null) {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(color: context.appColors.primary),
              );
            }
            return Center(
              child: Text(
                'no_data'.tr(),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: context.appColors.textSecondary,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _patientHeader(context, appointment),
              const SizedBox(height: 16),
              _infoCard(context, appointment),
              const SizedBox(height: 16),
              _actionsSection(context, appointment),
            ],
          );
        }),
      ),
    );
  }

  DoctorController get controller => Get.find<DoctorController>();

  Widget _patientHeader(
    BuildContext context,
    DoctorAppointmentModel appointment,
  ) {
    final patient = appointment.patient;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.appColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: context.appColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.person_rounded,
              color: context.appColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  patient.gender.isEmpty ? patient.gender : patient.gender.capitalizeFirst!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: context.appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  patient.phone.isEmpty ? patient.email : patient.phone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: context.appColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'chat_title'.tr(),
            onPressed: () => Get.toNamed(
              AppRouter.chat,
              arguments: {
                'otherPartyId': '${patient.id}',
                'title': patient.fullName,
              },
            ),
            icon: Icon(
              Icons.chat_bubble_outline_rounded,
              color: context.appColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(
    BuildContext context,
    DoctorAppointmentModel appointment,
  ) {
    final date = appointment.appointmentTime;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.appColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(
            context,
            Icons.calendar_month_rounded,
            'date_time'.tr(),
            '${DateFormat('EEE, d MMM yyyy').format(date)} - '
                '${DateFormat('h:mm a').format(date)}',
          ),
          const SizedBox(height: 12),
          _infoRow(
            context,
            Icons.local_hospital_rounded,
            'visit_type'.tr(),
            appointment.type.capitalizeFirst ?? appointment.type,
          ),
          if (appointment.type == 'home' &&
              (appointment.locationAddress != null ||
                  appointment.locationId != null)) ...[
            const SizedBox(height: 12),
            _infoRow(
              context,
              Icons.location_on_rounded,
              'home_location'.tr(),
              appointment.locationAddress ??
                  '#${appointment.locationId}',
            ),
          ],
          const SizedBox(height: 12),
          _infoRow(
            context,
            Icons.info_outline_rounded,
            'status'.tr(),
            _statusLabel(appointment.status),
            valueColor: _statusColor(context, appointment.status),
          ),
          if (appointment.isOnline &&
              appointment.resolvedMeetLink != null) ...[
            const SizedBox(height: 12),
            _infoRow(
              context,
              Icons.videocam_rounded,
              'meeting_link'.tr(),
              appointment.resolvedMeetLink!,
              valueColor: context.appColors.primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: context.appColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: valueColor ?? context.appColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionsSection(
    BuildContext context,
    DoctorAppointmentModel appointment,
  ) {
    final isProcessing =
        controller.processingAppointmentId.value == appointment.id;

    final actions = <(IconData, String, Color, VoidCallback?)>[];

    if (appointment.status == AppointmentStatus.pendingDeposit) {
      actions.add((
        Icons.check_circle_rounded,
        'confirm_appointment'.tr(),
        AppColors.primary900,
        isProcessing
            ? null
            : () => controller.confirmAppointment(appointmentId: appointment.id),
      ));
    }
    if (appointment.status == AppointmentStatus.confirmed) {
      actions.add((
        Icons.payment_rounded,
        'complete_appointment'.tr(),
        context.appColors.success,
        isProcessing
            ? null
            : () => controller.completeFinalPayment(appointmentId: appointment.id),
      ));
    }
    if (appointment.status == AppointmentStatus.pendingDeposit ||
        appointment.status == AppointmentStatus.confirmed) {
      actions.add((
        Icons.close_rounded,
        'cancel_appointment'.tr(),
        context.appColors.danger,
        isProcessing
            ? null
            : () => _confirmCancel(appointment),
      ));
    }
    if (appointment.isOnline &&
        appointment.resolvedMeetLink != null &&
        appointment.status != AppointmentStatus.cancelled) {
      actions.add((
        Icons.videocam_rounded,
        'start_consultation'.tr(),
        context.appColors.primary,
        () => _startConsultation(context, appointment),
      ));
    }
    actions.add((
      Icons.folder_open_rounded,
      'view_medical_file'.tr(),
      context.appColors.primary,
      () => Get.toNamed(
        AppRouter.medicalRecord,
        arguments: {
          'appointmentId': appointment.id,
          'patientId': appointment.patient.id,
          'status': appointment.status.name,
        },
      ),
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (icon, label, color, onTap) in actions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _actionButton(context, icon, label, color, onTap),
          ),
      ],
    );
  }

  Widget _actionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback? onTap,
  ) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _confirmCancel(DoctorAppointmentModel appointment) {
    Get.defaultDialog(
      title: 'cancel_appointment'.tr(),
      middleText: 'cancel_appointment_confirm'.tr(),
      textCancel: 'not_yet'.tr(),
      textConfirm: 'cancel'.tr(),
      confirmTextColor: AppColors.white,
      buttonColor: Get.context!.appColors.danger,
      onConfirm: () {
        Get.back();
        controller.cancelAppointment(appointmentId: appointment.id);
      },
    );
  }

  /// Starts the online consultation using the Google Meet link the backend
  /// generated for this appointment (available once it is completed).
  void _startConsultation(
    BuildContext context,
    DoctorAppointmentModel appointment,
  ) {
    final link = appointment.resolvedMeetLink;
    if (link == null || link.isEmpty) {
      Get.snackbar('info'.tr(), 'no_meeting_link'.tr());
      return;
    }
    Get.defaultDialog(
      title: 'start_consultation'.tr(),
      middleText: link,
      textCancel: 'cancel'.tr(),
      textConfirm: 'start_video_call'.tr(),
      confirmTextColor: AppColors.white,
      buttonColor: Get.context!.appColors.primaryContainer,
      onConfirm: () {
        Get.back();
        launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
      },
      actions: [
        TextButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: link));
            Get.back();
            Get.snackbar('info'.tr(), 'link_copied'.tr());
          },
          icon: const Icon(Icons.copy_rounded, size: 16),
          label: Text('copy'.tr()),
        ),
      ],
    );
  }

  Color _statusColor(BuildContext context, AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pendingDeposit:
        return context.appColors.primary;
      case AppointmentStatus.confirmed:
        return context.appColors.primary;
      case AppointmentStatus.completed:
        return context.appColors.success;
      case AppointmentStatus.cancelled:
        return context.appColors.danger;
      case AppointmentStatus.unknown:
        return context.appColors.textSecondary;
    }
  }

  String _statusLabel(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pendingDeposit:
        return 'pending_deposit'.tr();
      case AppointmentStatus.confirmed:
        return 'confirmed'.tr();
      case AppointmentStatus.completed:
        return 'completed'.tr();
      case AppointmentStatus.cancelled:
        return 'cancelled'.tr();
      case AppointmentStatus.unknown:
        return status.name;
    }
  }
}