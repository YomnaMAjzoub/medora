import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/patient/business_layer/controller/patient_account_controller.dart';
import 'package:medora_git/features/patient/data/models/appointment_record_model.dart';

/// "Schedules" tab: the patient's appointments fetched from
/// getAppointmentPatient, split into Confirmed / Pending / Cancelled tabs.
/// Online visits get a Join Meeting action, pending-deposit bookings get
/// resume/cancel actions.
class AppointmentsScreen extends GetView<PatientAccountController> {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          'schedules'.tr(),
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
          if (controller.isLoadingAppointments.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary700),
            );
          }
          if (controller.appointmentsError.value.isNotEmpty &&
              controller.appointments.isEmpty) {
            return _ErrorRetry(
              message: controller.appointmentsError.value,
              onRetry: controller.fetchAppointments,
            );
          }
          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Material(
                  color: context.appColors.background,
                  child: TabBar(
                    labelColor: AppColors.primary700,
                    unselectedLabelColor: context.appColors.textSecondary,
                    indicatorColor: AppColors.primary700,
                    indicatorWeight: 2.5,
                    labelStyle: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      Tab(text: 'confirmed_schedules'.tr()),
                      Tab(text: 'pending_schedules'.tr()),
                      Tab(text: 'cancelled_schedules'.tr()),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _AppointmentList(
                        appointments: _forStatuses(const {
                          AppointmentStatus.confirmed,
                          AppointmentStatus.completed,
                        }),
                      ),
                      _AppointmentList(
                        appointments: _forStatuses(const {
                          AppointmentStatus.pendingDeposit,
                          AppointmentStatus.unknown,
                        }),
                      ),
                      _AppointmentList(
                        appointments: _forStatuses(const {
                          AppointmentStatus.cancelled,
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  List<AppointmentRecordModel> _forStatuses(Set<AppointmentStatus> statuses) {
    return controller.appointments
        .where((a) => statuses.contains(a.status))
        .toList();
  }
}

class _AppointmentList extends StatelessWidget {
  const _AppointmentList({required this.appointments});

  final List<AppointmentRecordModel> appointments;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return _EmptyState(message: 'no_appointments'.tr());
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: appointments.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _AppointmentCard(
          appointment: appointments[index],
        );
      },
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment});

  final AppointmentRecordModel appointment;

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

  void _joinMeeting(BuildContext context) {
    final link = appointment.resolvedMeetLink;
    Get.defaultDialog(
      title: 'join_online_visit'.tr(),
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

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PatientAccountController>();
    final date = appointment.appointmentTime;
    final isProcessing =
        controller.processingAppointmentId.value == appointment.id;

    final actions = <Widget>[];
    if (appointment.isOnline) {
      actions.add(
        _ActionButton(
          icon: Icons.videocam_rounded,
          label: 'join_meeting'.tr(),
          onTap: () => _joinMeeting(context),
        ),
      );
    }
    if (appointment.status == AppointmentStatus.pendingDeposit) {
      actions.add(
        _ActionButton(
          icon: Icons.payment_rounded,
          label: 'complete_payment'.tr(),
          onTap: isProcessing
              ? null
              : () => controller.resumePayment(
                    appointmentId: appointment.id,
                  ),
        ),
      );
      actions.add(
        _ActionButton(
          icon: Icons.close_rounded,
          label: 'cancel'.tr(),
          isDestructive: true,
          onTap: isProcessing
              ? null
              : () => controller.cancelAppointment(
                    appointmentId: appointment.id,
                  ),
        ),
      );
    }

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary900.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_typeIcon, color: AppColors.primary800, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.type.capitalizeFirst ?? appointment.type,
                      style: GoogleFonts.roboto(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('EEE, d MMM yyyy').format(date)} - '
                      '${DateFormat('h:mm a').format(date)}',
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
            ],
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                for (final action in actions) ...[
                  Expanded(child: action),
                  if (action != actions.last) const SizedBox(width: 8),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.red : AppColors.primary900;
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w600,
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
              style: GoogleFonts.roboto(fontSize: 13, color: AppColors.grey300),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
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
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: GoogleFonts.roboto(fontSize: 14, color: AppColors.grey300),
      ),
    );
  }
}