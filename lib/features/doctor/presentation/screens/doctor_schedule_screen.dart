import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/doctor/business_layer/controller/doctor_controller.dart';
import 'package:medora_git/features/doctor/data/models/doctor_work_schedule_model.dart';

/// The doctor's schedule: working days/hours, days off and peak hours,
/// each editable from its own edit screen.
class DoctorScheduleScreen extends GetView<DoctorController> {
  const DoctorScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          'schedule'.tr(),
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
          if (controller.isLoadingSchedule.value &&
              controller.schedule.value == null) {
            return Center(
              child: CircularProgressIndicator(color: context.appColors.primary),
            );
          }
          if (controller.scheduleError.value.isNotEmpty &&
              controller.schedule.value == null) {
            return _ErrorRetry(
              message: controller.scheduleError.value,
              onRetry: controller.fetchSchedule,
            );
          }
          final schedule = controller.schedule.value;
          if (schedule == null) {
            return const SizedBox.shrink();
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _workingDaysCard(context, schedule),
              const SizedBox(height: 16),
              _daysOffCard(context, schedule),
              const SizedBox(height: 16),
              _peakHoursCard(context, schedule),
            ],
          );
        }),
      ),
    );
  }

  Widget _card(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onEdit,
    Widget child,
  ) {
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
          Row(
            children: [
              Icon(icon, color: context.appColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Text(
                  'edit'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _workingDaysCard(BuildContext context, DoctorWorkScheduleModel schedule) {
    return _card(
      context,
      'working_days'.tr(),
      Icons.calendar_month_rounded,
      () => Get.toNamed(AppRouter.doctorScheduleEdit, arguments: {'mode': 'workingDays'}),
      Column(
        children: [
          if (schedule.workingDays.isEmpty)
            Text(
              'no_working_days'.tr(),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: context.appColors.textSecondary,
              ),
            )
          else
            for (final day in schedule.workingDays)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        day.day,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${day.startTime} - ${day.endTime}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.appColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _daysOffCard(BuildContext context, DoctorWorkScheduleModel schedule) {
    return _card(
      context,
      'days_off'.tr(),
      Icons.beach_access_rounded,
      () => Get.toNamed(AppRouter.doctorScheduleEdit, arguments: {'mode': 'daysOff'}),
      schedule.daysOff.isEmpty
          ? Text(
              'no_days_off'.tr(),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: context.appColors.textSecondary,
              ),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final day in schedule.daysOff)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.appColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      day,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.appColors.danger,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _peakHoursCard(BuildContext context, DoctorWorkScheduleModel schedule) {
    return _card(
      context,
      'peak_hours'.tr(),
      Icons.schedule_rounded,
      () => Get.toNamed(AppRouter.doctorScheduleEdit, arguments: {'mode': 'peakHours'}),
      schedule.peakHours.isEmpty
          ? Text(
              'no_peak_hours'.tr(),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: context.appColors.textSecondary,
              ),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final range in schedule.peakHours)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      range,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.appColors.primary,
                      ),
                    ),
                  ),
              ],
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