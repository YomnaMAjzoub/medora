import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/patient/business_layer/controller/patient_account_controller.dart';
import 'package:medora_git/features/patient/data/models/appointment_record_model.dart';

/// Reached when a patient taps an appointment-reminder push. Shows the
/// appointment being reminded and a "Confirm visit" action that calls
/// POST /appointments/{id}/app-confirm.
class ReminderConfirmScreen extends GetView<PatientAccountController> {
  const ReminderConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointmentId =
        (Get.arguments as Map<String, dynamic>?)?['appointment_id'] as int? ??
            0;

    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          'appointment_reminder'.tr(),
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Obx(() {
            if (controller.isLoadingAppointments.value &&
                controller.appointments.isEmpty) {
              return Center(
                child:
                    CircularProgressIndicator(color: context.appColors.primary),
              );
            }
            final appointment = controller.appointments
                .firstWhereOrNull((a) => a.id == appointmentId);
            if (appointment == null) {
              return _MissingAppointment(
                onRetry: controller.fetchAppointments,
              );
            }
            return _ReminderBody(
              appointment: appointment,
              isProcessing:
                  controller.processingAppointmentId.value == appointment.id,
              onConfirm: () => controller.confirmReminderAppointment(
                appointmentId: appointment.id,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ReminderBody extends StatelessWidget {
  const _ReminderBody({
    required this.appointment,
    required this.isProcessing,
    required this.onConfirm,
  });

  final AppointmentRecordModel appointment;
  final bool isProcessing;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final date = appointment.appointmentTime;
    final alreadyConfirmed = appointment.status == AppointmentStatus.confirmed;
    return SingleChildScrollView(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.notifications_active_rounded,
          size: 56,
          color: context.appColors.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'confirm_visit_prompt'.tr(),
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        Container(
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
                icon: Icons.event_rounded,
                label: DateFormat('EEE, d MMM yyyy - h:mm a').format(date),
              ),
              const SizedBox(height: 12),
              _infoRow(
                context,
                icon: Icons.local_hospital_rounded,
                label: appointment.type.capitalizeFirst ?? appointment.type,
              ),
              if (appointment.doctor != null &&
                  appointment.doctor!.name.isNotEmpty) ...[
                const SizedBox(height: 12),
                _infoRow(
                  context,
                  icon: Icons.person_rounded,
                  label: appointment.doctor!.name,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (alreadyConfirmed) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.appColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'appointment_already_confirmed'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.appColors.success,
              ),
            ),
          ),
        ] else
          ElevatedButton(
            onPressed: isProcessing ? null : onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.appColors.primaryContainer,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.grey300,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isProcessing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'confirm_visit'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
      ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: context.appColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _MissingAppointment extends StatelessWidget {
  const _MissingAppointment({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'no_appointment_to_confirm'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: context.appColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.primaryContainer,
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
}