import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/admin/business_layer/controller/admin_controller.dart';
import 'package:medora_git/features/patient/data/models/appointment_model.dart';
import 'package:medora_git/features/patient/data/models/doctor_model.dart';
import 'package:medora_git/features/patient/data/models/doctor_profile_model.dart';

/// Staff doctor details: profile summary, working hours and edit / delete
/// actions.
class DoctorDetailsScreen extends GetView<AdminController> {
  const DoctorDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map? ?? const {};
    final initial = args['doctor'];
    final doctorId = initial is DoctorProfileModel
        ? initial.id.toString()
        : (initial as DoctorModel).id;

    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          'doctor_details'.tr(),
          style: GoogleFonts.inter(
            color: context.appColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            final profile = _liveProfile(doctorId);
            final doctorModel = _doctorModel(profile ?? initial);
            return IconButton(
              tooltip: 'edit'.tr(),
              onPressed: () => Get.toNamed(
                AppRouter.editDoctor,
                arguments: {'doctor': doctorModel},
              ),
              icon: Icon(
                Icons.edit_rounded,
                color: context.appColors.primary,
              ),
            );
          }),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final profile = _liveProfile(doctorId) ?? initial;
          final doctorModel = _doctorModel(profile);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _headerCard(context, doctorModel, profile),
              const SizedBox(height: 16),
              if (profile is DoctorProfileModel) ...[
                _workingHoursCard(context, profile),
                const SizedBox(height: 16),
              ],
              _infoCard(context, doctorModel, profile),
              const SizedBox(height: 24),
              Obx(
                () => OutlinedButton.icon(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () => _confirmDelete(context, doctorModel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.appColors.danger,
                    side: BorderSide(
                      color: context.appColors.danger.withValues(alpha: 0.4),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  label: Text(
                    'delete_doctor'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// The doctor's up-to-date profile from the controller, or null while
  /// the list is loading / the doctor was deleted.
  DoctorProfileModel? _liveProfile(String doctorId) {
    for (final profile in controller.doctorProfiles) {
      if (profile.id.toString() == doctorId) return profile;
    }
    return null;
  }

  DoctorModel _doctorModel(dynamic profile) {
    return profile is DoctorProfileModel
        ? profile.toDoctorModel()
        : profile as DoctorModel;
  }

  Widget _headerCard(
    BuildContext context,
    DoctorModel doctor,
    dynamic profile,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 96,
              height: 96,
              child: Image.network(
                doctor.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.secondary100,
                  child: const Icon(
                    Icons.person,
                    size: 48,
                    color: AppColors.primary600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            doctor.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            doctor.specialty,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              if (profile is DoctorProfileModel) ...[
                _chip(
                  context,
                  profile.isAvailable
                      ? 'available'.tr()
                      : 'not_available'.tr(),
                  color: profile.isAvailable
                      ? context.appColors.success
                      : context.appColors.danger,
                ),
                const SizedBox(width: 8),
                if (profile.homeVisit)
                  _chip(context, 'home_visit'.tr(),
                      color: context.appColors.primary),
              ] else ...[
                _chip(
                  context,
                  doctor.supports(VisitType.home)
                      ? 'home_visit'.tr()
                      : 'clinic_visit'.tr(),
                  color: context.appColors.primary,
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '\$${doctor.pricePerSession.toStringAsFixed(0)}/session',
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

  Widget _workingHoursCard(BuildContext context, DoctorProfileModel profile) {
    if (profile.schedules.isEmpty) {
      return _card(
        context,
        title: 'working_hours'.tr(),
        child: Text(
          'no_working_days'.tr(),
          style: GoogleFonts.inter(
            fontSize: 13,
            color: context.appColors.textSecondary,
          ),
        ),
      );
    }
    return _card(
      context,
      title: 'working_hours'.tr(),
      child: Column(
        children: [
          for (var i = 0; i < profile.schedules.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    profile.schedules[i].day,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: context.appColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_displayTime(profile.schedules[i].startTime)} - '
                    '${_displayTime(profile.schedules[i].endTime)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context, DoctorModel doctor, dynamic profile) {
    final rows = <(String, String)>[
      ('id'.tr(), '#${doctor.id}'),
      if (profile is DoctorProfileModel) ('gender'.tr(), profile.gender),
    ];
    return _card(
      context,
      title: 'personal_info'.tr(),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    rows[i].$1,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  rows[i].$2,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.appColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, {required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _displayTime(String raw) {
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return DateFormat('h:mm a').format(
      DateTime(2000, 1, 1, hour, minute),
    );
  }

  void _confirmDelete(BuildContext context, DoctorModel doctor) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_doctor'.tr()),
        content: Text('delete_doctor_confirm'.tr(args: [doctor.name])),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final deleted = await controller.deleteDoctor(doctor);
              if (deleted) Get.back();
            },
            child: Text(
              'delete'.tr(),
              style: TextStyle(color: context.appColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}