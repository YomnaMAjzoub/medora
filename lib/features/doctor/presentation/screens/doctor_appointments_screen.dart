import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/doctor/business_layer/controller/doctor_controller.dart';
import 'package:medora_git/features/doctor/data/models/doctor_appointment_model.dart';
import 'package:medora_git/features/patient/data/models/appointment_record_model.dart';

/// Doctor "Appointments" tab: today / week / month list filterable by
/// visit type (clinic / home / online). Rows open the appointment details.
class DoctorAppointmentsScreen extends GetView<DoctorController> {
  const DoctorAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          'appointments'.tr(),
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
        child: Column(
          children: [
            _periodFilter(context),
            _typeFilter(context),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.appointments.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: context.appColors.primary,
                    ),
                  );
                }
                if (controller.errorMessage.value.isNotEmpty &&
                    controller.appointments.isEmpty) {
                  return _ErrorRetry(
                    message: controller.errorMessage.value,
                    onRetry: controller.fetchAppointments,
                  );
                }
                final items = controller.filteredAppointments;
                if (items.isEmpty) {
                  return _EmptyState();
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchAppointments,
                  color: context.appColors.primary,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _AppointmentCard(appointment: items[index]);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _periodFilter(BuildContext context) {
    final options = <(String, String)>[
      ('today', 'today'.tr()),
      ('week', 'week'.tr()),
      ('month', 'month'.tr()),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Row(
        children: [
          for (final (value, label) in options)
            Expanded(
              child: Obx(
                () => GestureDetector(
                  onTap: () => controller.periodFilter.value = value,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: controller.periodFilter.value == value
                          ? context.appColors.primary
                          : context.appColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: controller.periodFilter.value == value
                            ? context.appColors.primary
                            : context.appColors.border,
                      ),
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: controller.periodFilter.value == value
                            ? AppColors.white
                            : context.appColors.textSecondary,
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

  Widget _typeFilter(BuildContext context) {
    final options = <(String, String)>[
      ('', 'all'.tr()),
      ('clinic', 'clinic'.tr()),
      ('home', 'home'.tr()),
      ('online', 'online'.tr()),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final (value, label) in options)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Obx(
                  () => ChoiceChip(
                    label: Text(label),
                    selected: controller.typeFilter.value == value,
                    onSelected: (_) =>
                        controller.typeFilter.value = value,
                    selectedColor: context.appColors.primary,
                    backgroundColor: context.appColors.surface,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: controller.typeFilter.value == value
                          ? AppColors.white
                          : context.appColors.textSecondary,
                    ),
                    side: BorderSide(color: context.appColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment});

  final DoctorAppointmentModel appointment;

  IconData get _typeIcon {
    switch (appointment.type) {
      case 'home':
        return Icons.home_rounded;
      case 'online':
        return Icons.videocam_rounded;
      default:
        return Icons.local_hospital_rounded;
    }
  }

  Color _statusColor(BuildContext context) {
    switch (appointment.status) {
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
    final date = appointment.appointmentTime;
    return InkWell(
      onTap: () => Get.toNamed(
        AppRouter.doctorAppointmentDetails,
        arguments: {'appointmentId': appointment.id},
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.appColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_typeIcon, color: context.appColors.primary, size: 24),
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
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('EEE, d MMM yyyy').format(date)} - '
                        '${DateFormat('h:mm a').format(date)}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor(context).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _typeIcon,
                  size: 16,
                  color: context.appColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  appointment.type.capitalizeFirst ?? appointment.type,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: context.appColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.appColors.primary,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});

  final String message;
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
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: context.appColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
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

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.appColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy_rounded,
              size: 36,
              color: context.appColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'no_appointments'.tr(),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: context.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}