import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/admin/business_layer/controller/admin_controller.dart';
import 'package:medora_git/features/patient/data/models/doctor_model.dart';
import 'package:medora_git/features/patient/data/models/doctor_profile_model.dart';

/// Staff doctor management list: fetched from getAllDoctors, with tap to
/// details, add / edit / delete actions.
class StaffDoctorsScreen extends GetView<AdminController> {
  const StaffDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          'doctors_title'.tr(),
          style: GoogleFonts.inter(
            color: context.appColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRouter.addDoctor),
        backgroundColor: context.appColors.primaryContainer,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(
          'add_doctor'.tr(),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value && controller.doctors.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: context.appColors.primary),
            );
          }
          if (controller.errorMessage.value.isNotEmpty &&
              controller.doctors.isEmpty) {
            return _ErrorRetry(
              message: controller.errorMessage.value,
              onRetry: controller.fetchDoctors,
            );
          }
          if (controller.doctors.isEmpty) {
            return Center(
              child: Text(
                'no_doctors'.tr(),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: context.appColors.textSecondary,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
            itemCount: controller.doctors.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doctor = controller.doctors[index];
              return _DoctorRow(
                doctor: doctor,
                profile: _profileOf(doctor),
                onTap: () => Get.toNamed(
                  AppRouter.staffDoctorDetails,
                  arguments: {'doctor': _profileOf(doctor) ?? doctor},
                ),
                onEdit: () => Get.toNamed(
                  AppRouter.editDoctor,
                  arguments: {'doctor': doctor},
                ),
                onDelete: () => _confirmDelete(context, doctor),
              );
            },
          );
        }),
      ),
    );
  }

  DoctorProfileModel? _profileOf(DoctorModel doctor) {
    for (final profile in controller.doctorProfiles) {
      if (profile.id.toString() == doctor.id) return profile;
    }
    return null;
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
            onPressed: () {
              Get.back();
              controller.deleteDoctor(doctor);
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

class _DoctorRow extends StatelessWidget {
  const _DoctorRow({
    required this.doctor,
    required this.profile,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final DoctorModel doctor;
  final DoctorProfileModel? profile;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Image.network(
                      doctor.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.secondary100,
                        child: const Icon(
                          Icons.person,
                          size: 30,
                          color: AppColors.primary600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        doctor.specialty,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '\$${doctor.pricePerSession.toStringAsFixed(0)}/session',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: context.appColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (profile != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: (profile!.isAvailable
                              ? context.appColors.success
                              : context.appColors.danger)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      profile!.isAvailable
                          ? 'available'.tr()
                          : 'not_available'.tr(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: profile!.isAvailable
                            ? context.appColors.success
                            : context.appColors.danger,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: context.appColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '#${doctor.id}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: TextButton.icon(
                    onPressed: onEdit,
                    style: TextButton.styleFrom(
                      foregroundColor: context.appColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'edit'.tr(),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: TextButton.icon(
                    onPressed: onDelete,
                    style: TextButton.styleFrom(
                      foregroundColor: context.appColors.danger,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'delete'.tr(),
                        maxLines: 1,
                      ),
                    ),
                  ),
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