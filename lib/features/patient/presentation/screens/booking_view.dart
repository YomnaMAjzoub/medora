import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/patient/business_layer/controller/booking_controller.dart';
import 'package:medora_git/features/patient/presentation/widgets/booking/booking_step_progress.dart';
import 'package:medora_git/features/patient/presentation/widgets/booking/home_location_step.dart';
import 'package:medora_git/features/patient/presentation/widgets/booking/payment_step.dart';
import 'package:medora_git/features/patient/presentation/widgets/booking/select_doctor_step.dart';
import 'package:medora_git/features/patient/presentation/widgets/booking/select_time_step.dart';
import 'package:medora_git/features/patient/presentation/widgets/booking/select_visit_type_step.dart';

class BookingView extends GetView<BookingController> {
  const BookingView({super.key});

  static const _stepLabels = {
    BookingStep.selectDoctor: 'step_select_doctor',
    BookingStep.visitType: 'step_visit_type',
    BookingStep.homeLocation: 'step_home_location',
    BookingStep.dateTime: 'step_date_time',
    BookingStep.payment: 'step_payment',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Obx(
                    () => IconButton(
                      onPressed: controller.currentStep.value == 0
                          ? () => Get.back()
                          : controller.goToPreviousStep,
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.grey500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'book_appointment'.tr(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // balances the back button
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Obx(
                () => BookingStepProgress(
                  currentStep: controller.currentStep.value,
                  totalSteps: controller.steps.length,
                  stepLabel: _stepLabels[controller.currentBookingStep]!.tr(),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Obx(() {
                  switch (controller.currentBookingStep) {
                    case BookingStep.selectDoctor:
                      return const SelectDoctorStep();
                    case BookingStep.visitType:
                      return const SelectVisitTypeStep();
                    case BookingStep.homeLocation:
                      return const HomeLocationStep();
                    case BookingStep.dateTime:
                      return const SelectTimeStep();
                    case BookingStep.payment:
                      return const PaymentStep();
                  }
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
