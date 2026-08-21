import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/patient/data/models/payment_success_response_model.dart';

/// In-app payment result shown after the simulated payment succeeds.
/// Displays exactly what the backend returned (message, appointment,
/// payment amounts) and returns to the main screen.
class PaymentResultScreen extends StatelessWidget {
  const PaymentResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map;
    final result = args['result'] as PaymentSuccessResponseModel;
    final doctorName = args['doctorName'] as String? ?? '';
    final appointment = result.appointment;
    final payment = result.payment;

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.appColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: context.appColors.success,
                  size: 56,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                result.message.isEmpty
                    ? 'payment_success'.tr()
                    : result.message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                result.detailMessage ?? 'payment_result_hint'.tr(),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: context.appColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: context.appColors.primary.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (doctorName.isNotEmpty)
                      _row(
                        context,
                        icon: Icons.person_rounded,
                        label: 'doctor_title'.tr(),
                        value: doctorName,
                      ),
                    if (appointment != null) ...[
                      _row(
                        context,
                        icon: Icons.local_hospital_rounded,
                        label: 'visit_type'.tr(),
                        value: appointment.type,
                      ),
                      if (appointment.appointmentTime.isNotEmpty)
                        _row(
                          context,
                          icon: Icons.schedule_rounded,
                          label: 'date_time'.tr(),
                          value: appointment.appointmentTime,
                        ),
                      if (appointment.status.isNotEmpty)
                        _row(
                          context,
                          icon: Icons.info_outline_rounded,
                          label: 'status'.tr(),
                          value: appointment.status,
                        ),
                    ],
                    if (payment != null) ...[
                      const Divider(height: 24),
                      _row(
                        context,
                        icon: Icons.payments_outlined,
                        label: 'amount_paid'.tr(),
                        value: payment.amountPaid,
                        highlight: true,
                      ),
                      if (payment.totalAmount != payment.amountPaid)
                        _row(
                          context,
                          icon: Icons.receipt_long_rounded,
                          label: 'remaining_amount'.tr(),
                          value: payment.remainingAmount,
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Get.offAllNamed(AppRouter.main),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appColors.primaryContainer,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'done'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.appColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: context.appColors.textSecondary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
                color: highlight
                    ? context.appColors.success
                    : context.appColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}