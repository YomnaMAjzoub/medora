import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/features/patient/business_layer/controller/booking_controller.dart';

class PaymentStep extends StatelessWidget {
  const PaymentStep({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
          Text(
            "Payment Summary",
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 24),

          // FEE BREAKDOWN CARD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _feeRow(
                  "Consultation Fee",
                  "\$${controller.consultationFee.value.toStringAsFixed(2)}",
                ),
                _feeRow("Service Charge", "\$0.00"),
                const Divider(height: 24),
                _feeRow(
                  "Total Fee",
                  "\$${controller.consultationFee.value.toStringAsFixed(2)}",
                  isBold: true,
                ),
                const SizedBox(height: 12),
                _feeRow(
                  "Required Deposit (50%)",
                  "\$${controller.depositAmount.toStringAsFixed(2)}",
                  isBold: true,
                  color: AppColors.primary700,
                ),
                const SizedBox(height: 4),
                Text(
                  "Pay now to secure your appointment.",
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // PAYMENT METHOD (ONE OPTION ONLY)
          Text(
            "Payment Method",
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary700.withOpacity(.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.credit_card, color: AppColors.primary700, size: 28),
                const SizedBox(width: 16),
                Text(
                  "Credit / Debit Card",
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey700,
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
                backgroundColor: AppColors.primary700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: controller.confirmPayment,
              child: Text(
                "Pay Deposit & Confirm",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            "By clicking confirm, you agree to our Cancellation Policy.\nDeposits are 100% refundable if cancelled 24 hours prior.",
            style: GoogleFonts.roboto(fontSize: 12, color: AppColors.grey500),
          ),
        ],
      ),
    );
  }

  Widget _feeRow(
    String label,
    String value, {
    bool isBold = false,
    Color color = AppColors.grey700,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(fontSize: 15, color: AppColors.grey600),
          ),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
