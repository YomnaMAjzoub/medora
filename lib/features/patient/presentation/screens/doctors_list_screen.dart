import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/patient/business_layer/controller/doctor_discovery_controller.dart';
import 'package:medora_git/features/patient/presentation/widgets/booking/doctor_card.dart';

/// Doctor results screen. Opened with a `specialization` argument from the
/// home specialties grid (filtered list), or without one (full list).
/// Every entry re-fetches from the backend: with the requested filter when
/// given, otherwise filters are cleared so ALL doctors are shown — never a
/// stale subset left over from a previous visit.
class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  DoctorDiscoveryController get controller =>
      Get.find<DoctorDiscoveryController>();

  String? specialization;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    specialization = args is Map ? args['specialization'] as String? : null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (specialization != null && specialization!.isNotEmpty) {
        controller.applyFilter(specialization: specialization);
      } else {
        controller.clearFilters();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: Obx(() {
          final doctors = controller.doctors;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        specialization != null
                            ? 'doctors_title'.tr().replaceFirst(
                                '{specialization}', specialization!)
                            : 'doctors_title'.tr(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  'doctors_found'.tr().replaceFirst(
                    '{count}', '${doctors.length}'),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: context.appColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: controller.isLoading.value
                    ? Center(
                        child: CircularProgressIndicator(
                          color: context.appColors.primary,
                        ),
                      )
                    : controller.errorMessage.value.isNotEmpty &&
                            doctors.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  controller.errorMessage.value,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: context.appColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: controller.fetchDoctors,
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
                          )
                        : doctors.isEmpty
                            ? Center(
                                child: Text(
                                  'no_doctors'.tr(),
                                  style: GoogleFonts.inter(
                                    color: context.appColors.textSecondary,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  16,
                                  20,
                                  24,
                                ),
                                itemCount: doctors.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final doctor = doctors[index];
                                  return DoctorCard(
                                    doctor: doctor,
                                    onBook: () => Get.toNamed(
                                      AppRouter.book,
                                      arguments: {'doctor_id': doctor.id},
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          );
        }),
      ),
    );
  }
}