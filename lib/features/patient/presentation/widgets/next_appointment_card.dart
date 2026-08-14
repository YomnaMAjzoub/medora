import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';

import 'package:medora_git/features/patient/data/models/appointment_model.dart';

/// Card shown in the "Next Appointment" section with the doctor's photo,
/// name, specialty, a date/time badge and a primary action button
/// (Join Online Visit / Get Directions / View Details depending on
/// [AppointmentModel.visitType]).
class NextAppointmentCard extends StatelessWidget {
  const NextAppointmentCard({
    required this.appointment,
    required this.onTap,
    this.onActionTap,
    super.key,
  });

  final AppointmentModel appointment;

  /// Fires when the card itself is tapped.
  final VoidCallback onTap;

  /// Fires when the bottom action button is tapped.
  /// Defaults to [onTap] when not provided.
  final VoidCallback? onActionTap;

  IconData get _actionIcon {
    switch (appointment.visitType) {
      case VisitType.online:
        return Icons.videocam_rounded;
      case VisitType.clinic:
        return Icons.directions_rounded;
      case VisitType.home:
        return Icons.home_rounded;
    }
  }

  String get _actionLabel {
    switch (appointment.visitType) {
      case VisitType.online:
        return 'join_online_visit'.tr();
      case VisitType.clinic:
        return 'get_directions'.tr();
      case VisitType.home:
        return 'view_details'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = appointment.doctor;
    final hasDoctor = doctor.name.isNotEmpty;
    final formattedDate = DateFormat('EEE, d MMM').format(appointment.date);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary900.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Base gradient background.
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary900, AppColors.primary700],
                    ),
                  ),
                ),
              ),
              // Soft decorative glow, top-right, like the reference design.
              Positioned(
                top: -40,
                right: -30,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary500.withValues(alpha: 0.35),
                        AppColors.primary500.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.mainScreen,
                            backgroundImage: doctor.imageUrl != null
                                ? NetworkImage(doctor.imageUrl!)
                                : null,
                            onBackgroundImageError: doctor.imageUrl != null
                                ? (_, __) {}
                                : null,
                            child: const Icon(
                              Icons.person,
                              color: AppColors.primary800,
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasDoctor
                                    ? doctor.name
                                    : appointment.visitType.name
                                        .capitalizeFirst!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                hasDoctor
                                    ? doctor.specialty
                                    : 'next_title'.tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.roboto(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 15,
                            color: AppColors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$formattedDate, ${appointment.time}',
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: Material(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(30),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: onActionTap ?? onTap,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _actionIcon,
                                  size: 18,
                                  color: AppColors.primary700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _actionLabel,
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
