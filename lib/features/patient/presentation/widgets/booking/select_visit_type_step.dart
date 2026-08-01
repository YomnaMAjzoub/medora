import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/features/patient/business_layer/controller/booking_controller.dart';
import 'package:medora_git/features/patient/data/models/appointment_model.dart';

/// Step 2 of the booking flow: pick how the appointment takes place.
/// Only the visit types the selected doctor actually supports are shown
/// (see [BookingController.availableVisitTypes]). Picking a type calls
/// [BookingController.selectVisitType], which stores the pick and advances
/// the wizard -- to the home-location step if [VisitType.home] was picked,
/// otherwise straight to date & time.
class SelectVisitTypeStep extends GetView<BookingController> {
  const SelectVisitTypeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SelectedDoctorSummary(),
          const SizedBox(height: 24),
          Text(
            'Choose Visit Type',
            style: GoogleFonts.roboto(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'How would you like to see the doctor?',
            style: GoogleFonts.roboto(fontSize: 13, color: AppColors.grey300),
          ),
          const SizedBox(height: 20),
          Obx(
            () => Column(
              children: controller.availableVisitTypes.map((type) {
                final isSelected = controller.selectedVisitType.value == type;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _VisitTypeOptionCard(
                    type: type,
                    isSelected: isSelected,
                    onTap: () => controller.selectVisitType(type),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small recap of the doctor picked in step 1, with a "Change" shortcut
/// back to that step -- keeps the patient oriented as they move forward.
class _SelectedDoctorSummary extends GetView<BookingController> {
  const _SelectedDoctorSummary();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final doctor = controller.selectedDoctor.value;
      if (doctor == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowb.withValues(alpha: .5),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                doctor.imageUrl,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 52,
                  height: 52,
                  color: AppColors.secondary100,
                  child: const Icon(Icons.person, color: AppColors.primary600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doctor.specialty,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: AppColors.grey300,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: controller.goToPreviousStep,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
              ),
              child: Text(
                'Change',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary700,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _VisitTypeOptionCard extends StatelessWidget {
  const _VisitTypeOptionCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final VisitType type;
  final bool isSelected;
  final VoidCallback onTap;

  static ({IconData icon, String title, String subtitle}) _contentFor(
    VisitType type,
  ) {
    switch (type) {
      case VisitType.clinic:
        return (
          icon: Icons.medical_services_rounded,
          title: 'Clinic Visit',
          subtitle: 'See the doctor in person at the clinic',
        );
      case VisitType.home:
        return (
          icon: Icons.home_rounded,
          title: 'Home Visit',
          subtitle: 'The doctor comes to your address',
        );
      case VisitType.online:
        return (
          icon: Icons.videocam_rounded,
          title: 'Online Visit',
          subtitle: 'Video consultation from anywhere',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _contentFor(type);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary100 : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary700 : AppColors.neutral200,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    color: AppColors.shadowb.withValues(alpha: .4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary700
                    : AppColors.secondary100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                content.icon,
                color: isSelected ? AppColors.white : AppColors.primary700,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content.subtitle,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: AppColors.grey300,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.primary700 : AppColors.grey200,
            ),
          ],
        ),
      ),
    );
  }
}
