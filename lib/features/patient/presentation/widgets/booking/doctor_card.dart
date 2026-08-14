import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/patient/data/models/doctor_model.dart';
import 'package:medora_git/features/patient/presentation/widgets/booking/visit_type_row.dart';

/// Card representing a single doctor in the "Select Doctor" step.
/// Top-rated doctors get a taller photo, a "Top Rated" badge and a
/// highlight note, mirroring the featured card in the design.
class DoctorCard extends StatelessWidget {
  const DoctorCard({required this.doctor, required this.onBook, super.key});

  final DoctorModel doctor;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: .5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Photo(doctor: doctor),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  doctor.name,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'yrs_exp'.tr().replaceFirst(
                        '{count}',
                        '${doctor.experienceYears}',
                      ),
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            doctor.specialty,
            style: GoogleFonts.roboto(
              fontSize: 13,
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: VisitTypeRow(
                  supportedTypes: doctor.supportedVisitTypes,
                  showLabels: doctor.isTopRated,
                ),
              ),
              if (doctor.isTopRated)
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: Color(0xFFFFB800),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${doctor.rating} (${doctor.reviewsCount})',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  '\$${doctor.pricePerSession.toStringAsFixed(0)}'
                  '${'per_session'.tr()}',
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary700,
                  ),
                ),
            ],
          ),
          if (doctor.isTopRated) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '\$${doctor.pricePerSession.toStringAsFixed(0)}'
                  '${'per_session'.tr()}',
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary700,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary900,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                'book_appointment'.tr(),
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: doctor.isTopRated ? 16 / 11 : 16 / 9,
            child: Image.network(
              doctor.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.secondary100,
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: AppColors.primary600,
                ),
              ),
            ),
          ),
          if (doctor.isTopRated)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tertiary700,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'top_rated'.tr(),
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary900,
                  ),
                ),
              ),
            )
          else
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.appColors.surface.withValues(alpha: .9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: Color(0xFFFFB800),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${doctor.rating}',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (doctor.isTopRated && doctor.highlightNote != null)
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: context.appColors.surface.withValues(alpha: .85),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: AppColors.primary600,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        doctor.highlightNote!,
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
