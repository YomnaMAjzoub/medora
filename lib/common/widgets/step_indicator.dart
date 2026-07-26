
import 'package:flutter/material.dart';
import 'package:medora_git/core/const/app_colors.dart';


class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        bool isActive = index - 1 < currentStep;

        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 8),
            height: 8.5,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary900 : AppColors.grey100,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        );
      }),
    );
  }
}
