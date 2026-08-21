
import 'package:flutter/material.dart';
import 'package:medora_git/core/theme/app_theme.dart';


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
    final inactiveColor = context.appColors.border;
    return Row(
      children: List.generate(totalSteps, (index) {
        bool isActive = index - 1 < currentStep;

        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 8),
            height: 8.5,
            decoration: BoxDecoration(
              color: isActive ? context.appColors.primary : inactiveColor,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        );
      }),
    );
  }
}
