import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/admin/business_layer/controller/admin_controller.dart';
import 'package:medora_git/features/patient/data/models/doctor_model.dart';

/// Admin panel home: the doctors managed by the logged-in admin,
/// fetched from getAllDoctors, with add / edit / delete actions.
class AdminHomeScreen extends GetView<AdminController> {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          'admin_panel'.tr(),
          style: GoogleFonts.roboto(
            color: AppColors.primary700,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'add_offer'.tr(),
            onPressed: () => Get.toNamed(AppRouter.addOffer),
            icon: const Icon(
              Icons.local_offer_outlined,
              color: AppColors.primary700,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRouter.addDoctor),
        backgroundColor: AppColors.primary700,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(
          'add_doctor'.tr(),
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
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
              controller.doctors.isEmpty) {
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
                      onPressed: controller.fetchDoctors,
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
          if (controller.doctors.isEmpty) {
            return Center(
              child: Text(
                'no_doctors'.tr(),
                style: GoogleFonts.roboto(
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
              return _AdminDoctorRow(
                doctor: controller.doctors[index],
                onEdit: () => Get.toNamed(
                  AppRouter.editDoctor,
                  arguments: {'doctor': controller.doctors[index]},
                ),
                onDelete: () =>
                    _confirmDelete(context, controller.doctors[index]),
              );
            },
          );
        }),
      ),
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

class _AdminDoctorRow extends StatelessWidget {
  const _AdminDoctorRow({
    required this.doctor,
    required this.onEdit,
    required this.onDelete,
  });

  final DoctorModel doctor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  doctor.specialty,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: context.appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '\$${doctor.pricePerSession.toStringAsFixed(0)}/session',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary700.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '#${doctor.id}',
              style: GoogleFonts.roboto(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary700,
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_rounded,
              size: 20,
              color: AppColors.primary700,
            ),
            tooltip: 'edit'.tr(),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: context.appColors.danger,
            ),
            tooltip: 'delete'.tr(),
          ),
        ],
      ),
    );
  }
}