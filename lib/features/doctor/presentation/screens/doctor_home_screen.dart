import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/doctor/business_layer/controller/doctor_controller.dart';
import 'package:medora_git/features/doctor/data/models/doctor_appointment_model.dart';
import 'package:medora_git/features/notifications/business_layer/controller/notifications_controller.dart';
import 'package:medora_git/features/patient/data/models/appointment_record_model.dart';

/// Doctor dashboard (Home tab): today's numbers, the peak hour window, the
/// last diagnosis/prescription and quick access to every doctor feature.
class DoctorHomeScreen extends GetView<DoctorController> {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final name = storage.read<String>('user_name') ?? '';
    final unread = Get.isRegistered<NotificationsController>()
        ? Get.find<NotificationsController>().unreadCount.value
        : 0;

    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'good_morning'.tr(),
              style: GoogleFonts.inter(
                color: context.appColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              name.isEmpty ? 'doctor_title'.tr() : name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: context.appColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: 'notifications'.tr(),
                onPressed: () => Get.toNamed(AppRouter.doctorNotifications),
                icon: SvgPicture.asset(
                  'assets/icons/notify.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    context.appColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              if (unread > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
        actionsPadding: const EdgeInsetsDirectional.only(end: 12),
      ),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.appointments.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: context.appColors.primary),
            );
          }
          if (controller.errorMessage.value.isNotEmpty &&
              controller.appointments.isEmpty) {
            return _ErrorRetry(
              message: controller.errorMessage.value,
              onRetry: controller.fetchAppointments,
            );
          }
          return RefreshIndicator(
            onRefresh: controller.fetchAppointments,
            color: context.appColors.primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
              children: [
              _statsGrid(context),
              const SizedBox(height: 16),
              _lastEntriesCard(context),
              const SizedBox(height: 24),
              _quickAccessTitle(context),
              const SizedBox(height: 10),
              _quickAccessGrid(context),
              const SizedBox(height: 24),
              _todayAppointmentsTitle(context),
              const SizedBox(height: 10),
              if (controller.appointments.isEmpty)
                Text(
                  'no_appointments_today'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: context.appColors.textSecondary,
                  ),
                )
              else
                ...controller.appointments.take(4).map(
                      (a) => _AppointmentRow(
                        appointment: a,
                        onTap: () => Get.toNamed(
                          AppRouter.doctorAppointmentDetails,
                          arguments: {'appointmentId': a.id},
                        ),
                      ),
                    ),
            ],
            ),
          );
        }),
      ),
    );
  }

  Widget _statsGrid(BuildContext context) {
    final stats = <(IconData, Color, String, String)>[
      (
        Icons.event_available_rounded,
        context.appColors.primary,
        '${controller.todayAppointmentsCount}',
        'today_appointments'.tr(),
      ),
      (
        Icons.videocam_rounded,
        context.appColors.primary,
        '${controller.todayConsultationsCount}',
        'today_consultations'.tr(),
      ),
      (
        Icons.person_add_alt_1_rounded,
        context.appColors.success,
        '${controller.newPatientsCount}',
        'new_patients'.tr(),
      ),
      (
        Icons.event_busy_rounded,
        context.appColors.danger,
        '${controller.noShowRate.toStringAsFixed(0)}%',
        'no_show_rate'.tr(),
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _statCard(context, stats[0])),
            const SizedBox(width: 10),
            Expanded(child: _statCard(context, stats[1])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _statCard(context, stats[2])),
            const SizedBox(width: 10),
            Expanded(child: _statCard(context, stats[3])),
          ],
        ),
        const SizedBox(height: 10),
        _peakHoursCard(context),
      ],
    );
  }

  Widget _statCard(BuildContext context, (IconData, Color, String, String) stat) {
    final (icon, color, value, label) = stat;
    return Container(
      padding: const EdgeInsets.all(14),
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: context.appColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _peakHoursCard(BuildContext context) {
    final peak = controller.peakHours;
    return Container(
      padding: const EdgeInsets.all(14),
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: context.appColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.schedule_rounded,
              color: context.appColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'peak_hours'.tr(),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
            ),
          ),
          Text(
            peak.isEmpty ? '--:--' : peak,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.appColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lastEntriesCard(BuildContext context) {
    final diagnosis = controller.lastDiagnosis.value;
    final prescription = controller.lastPrescription.value;
    if (diagnosis.isEmpty && prescription.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary50.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'last_entries'.tr(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: context.appColors.primary,
            ),
          ),
          if (diagnosis.isNotEmpty) ...[
            const SizedBox(height: 8),
            _lastEntryRow(context, 'last_diagnosis'.tr(), diagnosis,
                Icons.medical_information_rounded),
          ],
          if (prescription.isNotEmpty) ...[
            const SizedBox(height: 6),
            _lastEntryRow(context, 'last_prescription'.tr(), prescription,
                Icons.medication_rounded),
          ],
        ],
      ),
    );
  }

  Widget _lastEntryRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: context.appColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.primary,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: context.appColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickAccessTitle(BuildContext context) {
    return Text(
      'quick_access'.tr(),
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: context.appColors.primary,
      ),
    );
  }

  Widget _quickAccessGrid(BuildContext context) {
    final items = <(IconData, String, VoidCallback)>[
      (
        Icons.calendar_month_rounded,
        'appointments'.tr(),
        () => Get.toNamed(AppRouter.doctorAppointments),
      ),
      (
        Icons.videocam_rounded,
        'consultations'.tr(),
        () => Get.toNamed(AppRouter.doctorConsultations),
      ),
      (
        Icons.group_rounded,
        'patients'.tr(),
        () => Get.toNamed(AppRouter.doctorPatients),
      ),
      (
        Icons.schedule_rounded,
        'schedule'.tr(),
        () => Get.toNamed(AppRouter.doctorSchedule),
      ),
      (
        Icons.receipt_long_rounded,
        'invoices'.tr(),
        () => Get.toNamed(AppRouter.doctorInvoices),
      ),
      (
        Icons.settings_rounded,
        'settings'.tr(),
        () => Get.toNamed(AppRouter.doctorSettings),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.15,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final (icon, label, onTap) = items[index];
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: context.appColors.primary.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: context.appColors.primary, size: 26),
                const SizedBox(height: 8),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _todayAppointmentsTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'today_appointments'.tr(),
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: context.appColors.primary,
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(AppRouter.doctorAppointments),
          child: Text(
            'view_all'.tr(),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: context.appColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  const _AppointmentRow({required this.appointment, required this.onTap});

  final DoctorAppointmentModel appointment;
  final VoidCallback onTap;

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
    final time = appointment.appointmentTime;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.appColors.primary.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.appColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                Icons.person_rounded,
                color: context.appColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.patient.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${DateFormat('h:mm a').format(time)} - '
                    '${appointment.type.capitalizeFirst ?? appointment.type}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(context).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusLabel,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _statusColor(context),
                ),
              ),
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