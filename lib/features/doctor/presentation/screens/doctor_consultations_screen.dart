import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/common/widgets/search_field.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/doctor/business_layer/controller/doctor_controller.dart';
import 'package:medora_git/features/doctor/data/models/doctor_appointment_model.dart';
import 'package:medora_git/features/patient/data/models/appointment_record_model.dart';

/// Doctor "Consultations" tab: online consultations grouped by
/// Today / Week / Previous, with a patient search box.
class DoctorConsultationsScreen extends StatefulWidget {
  const DoctorConsultationsScreen({super.key});

  @override
  State<DoctorConsultationsScreen> createState() =>
      _DoctorConsultationsScreenState();
}

enum _ConsultationPeriod { today, week, previous }

class _DoctorConsultationsScreenState extends State<DoctorConsultationsScreen> {
  final _searchController = TextEditingController();
  _ConsultationPeriod _period = _ConsultationPeriod.today;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          'consultations'.tr(),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: SearchField(
                width: double.infinity,
                height: 46,
                hint: 'search_patients'.tr(),
                prefix: Icon(
                  Icons.search,
                  color: context.appColors.primary,
                  size: 22,
                ),
                suffix: const SizedBox.shrink(),
                onChanged: (value) => setState(() => _query = value.trim()),
              ),
            ),
            const SizedBox(height: 12),
            _periodFilter(context),
            Expanded(
              child: Obx(() {
                final controller = Get.find<DoctorController>();
                if (controller.isLoadingConsultations.value &&
                    controller.consultations.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: context.appColors.primary,
                    ),
                  );
                }
                if (controller.consultationsError.value.isNotEmpty &&
                    controller.consultations.isEmpty) {
                  return _ErrorRetry(
                    message: controller.consultationsError.value,
                    onRetry: controller.fetchConsultations,
                  );
                }
                final items = _filtered(controller.consultations);
                if (items.isEmpty) {
                  return _EmptyState();
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _ConsultationCard(consultation: items[index]);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _periodFilter(BuildContext context) {
    final options = <(_ConsultationPeriod, String)>[
      (_ConsultationPeriod.today, 'today'.tr()),
      (_ConsultationPeriod.week, 'week'.tr()),
      (_ConsultationPeriod.previous, 'previous'.tr()),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (final (period, label) in options)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _period = period),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: _period == period
                        ? context.appColors.primary
                        : context.appColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _period == period
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
                      color: _period == period
                          ? AppColors.white
                          : context.appColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<DoctorAppointmentModel> _filtered(
    List<DoctorAppointmentModel> items,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    final filtered = items.where((c) {
      final date = c.appointmentTime;
      final day = DateTime(date.year, date.month, date.day);
      switch (_period) {
        case _ConsultationPeriod.today:
          return day == today;
        case _ConsultationPeriod.week:
          return !date.isBefore(weekStart);
        case _ConsultationPeriod.previous:
          return date.isBefore(weekStart);
      }
    }).toList();

    if (_query.isEmpty) return filtered;
    final q = _query.toLowerCase();
    return filtered
        .where((c) => c.patient.fullName.toLowerCase().contains(q))
        .toList();
  }
}

class _ConsultationCard extends StatelessWidget {
  const _ConsultationCard({required this.consultation});

  final DoctorAppointmentModel consultation;

  Color _statusColor(BuildContext context) {
    switch (consultation.status) {
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
    switch (consultation.status) {
      case AppointmentStatus.pendingDeposit:
        return 'pending_deposit'.tr();
      case AppointmentStatus.confirmed:
        return 'confirmed'.tr();
      case AppointmentStatus.completed:
        return 'completed'.tr();
      case AppointmentStatus.cancelled:
        return 'cancelled'.tr();
      case AppointmentStatus.unknown:
        return consultation.status.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = consultation.appointmentTime;
    return InkWell(
      onTap: () => Get.toNamed(
        AppRouter.doctorConsultationChat,
        arguments: {
          'appointmentId': consultation.id,
          'patientId': consultation.patient.id,
          'title': consultation.patient.fullName,
        },
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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.appColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.videocam_rounded,
                color: context.appColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    consultation.patient.fullName,
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
                    '${DateFormat('EEE, d MMM').format(date)} - '
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              Icons.videocam_off_rounded,
              size: 36,
              color: context.appColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'no_consultations'.tr(),
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