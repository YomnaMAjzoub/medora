import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';

/// Segmented progress indicator for the booking wizard, e.g. "Step 2 of 4".
class BookingStepProgress extends StatelessWidget {
  const BookingStepProgress({
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabel,
    super.key,
  });

  /// 0-based index of the current step.
  final int currentStep;
  final int totalSteps;
  final String stepLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            final isActive = index <= currentStep;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 6),
                height: 4,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary700 : AppColors.neutral200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          'Step ${currentStep + 1} of $totalSteps · $stepLabel',
          style: GoogleFonts.roboto(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.grey300,
          ),
        ),
      ],
    );
  }
}
