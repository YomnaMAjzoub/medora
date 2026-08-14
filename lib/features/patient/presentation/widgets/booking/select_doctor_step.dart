import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/patient/business_layer/controller/booking_controller.dart';
import 'package:medora_git/features/patient/business_layer/controller/doctor_discovery_controller.dart';
import 'package:medora_git/features/patient/data/models/doctor_model.dart';
import 'package:medora_git/features/patient/presentation/widgets/booking/doctor_card.dart';
import 'package:medora_git/features/patient/presentation/widgets/booking/doctor_filter_sheet.dart';

/// Step 1 of the booking flow: pick a doctor.
/// The list comes from [DoctorDiscoveryController]; picking a doctor calls
/// [BookingController.selectDoctor], which is the one piece of state that
/// actually needs to survive into later steps.
class SelectDoctorStep extends StatefulWidget {
  const SelectDoctorStep({super.key});

  @override
  State<SelectDoctorStep> createState() => _SelectDoctorStepState();
}

class _SelectDoctorStepState extends State<SelectDoctorStep> {
  final BookingController controller = Get.find<BookingController>();
  final DoctorDiscoveryController discovery =
      Get.find<DoctorDiscoveryController>();

  DoctorFilters _filters = const DoctorFilters();

  List<DoctorModel> get _filteredDoctors {
    return discovery.doctors.where((doctor) {
      return doctor.pricePerSession <= _filters.maxPrice;
    }).toList();
  }

  Future<void> _openFilterSheet() async {
    final result = await showDoctorFilterSheet(context, _filters);
    if (result != null) {
      setState(() => _filters = result);
      discovery.applyFilter(
        specialization: result.specialization,
        gender: result.gender == GenderFilter.any ? null : result.gender.name,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final doctors = _filteredDoctors;

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'available_doctors'.tr(),
                        style: GoogleFonts.roboto(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'doctors_found'
                            .tr()
                            .replaceFirst('{count}', '${doctors.length}'),
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _FilterButton(onTap: _openFilterSheet),
              ],
            ),
            const SizedBox(height: 20),
            if (discovery.isLoading.value)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary700,
                  ),
                ),
              )
            else if (discovery.errorMessage.value.isNotEmpty &&
                discovery.doctors.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        discovery.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: discovery.fetchDoctors,
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
              )
            else if (doctors.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Text(
                    'no_doctors_match'.tr(),
                    style: GoogleFonts.roboto(
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: doctors.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  return DoctorCard(
                    doctor: doctor,
                    onBook: () => controller.selectDoctor(doctor),
                  );
                },
              ),
          ],
        ),
      );
    });
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary900,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.filter_list_rounded,
              size: 18,
              color: AppColors.white,
            ),
            const SizedBox(width: 6),
            Text(
              'filter'.tr(),
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}