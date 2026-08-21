import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/patient/business_layer/controller/booking_controller.dart';

class PaymentStep extends StatelessWidget {
  const PaymentStep({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
          Text(
            'payment_summary'.tr(),
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          // FEE BREAKDOWN CARD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: .05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _feeRow(
                  'consultation_fee'.tr(),
                  "\$${controller.consultationFee.toStringAsFixed(2)}",
                  colors: colors,
                ),
                _feeRow('service_charge'.tr(), '\$0.00', colors: colors),
                const Divider(height: 24),
                _feeRow(
                  'total_fee'.tr(),
                  controller.amountToPayNow.value > 0
                      ? "\$${controller.amountToPayNow.value}"
                      : "\$${controller.consultationFee.toStringAsFixed(2)}",
                  isBold: true,
                  colors: colors,
                ),
                const SizedBox(height: 12),
                _feeRow(
                  'required_deposit'.tr(),
                  controller.amountToPayNow.value > 0
                      ? "\$${controller.amountToPayNow.value}"
                      : "\$${controller.depositAmount.toStringAsFixed(2)}",
                  isBold: true,
                  color: context.appColors.primary,
                  colors: colors,
                ),
                const SizedBox(height: 4),
                Text(
                  'pay_now_secure'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // PAYMENT METHOD (ONE OPTION ONLY)
          Text(
            'payment_method'.tr(),
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.appColors.primary.withValues(alpha: .3)),
            ),
            child: Row(
              children: [
                Icon(Icons.credit_card, color: context.appColors.primary, size: 28),
                const SizedBox(width: 16),
                Text(
                  'credit_debit_card'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // CONFIRM BUTTON
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.primaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: controller.isLoading.value
                  ? null
                  : controller.payNow,
              child: Obx(
                () => controller.isLoading.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'pay_deposit_confirm'.tr(),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'simulated_payment_hint'.tr(),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'payment_terms'.tr(),
            style: GoogleFonts.inter(
              fontSize: 12,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _feeRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
    required AppThemeColors colors,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: color ?? colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
