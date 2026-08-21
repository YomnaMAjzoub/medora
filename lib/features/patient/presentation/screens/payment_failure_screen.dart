import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';

/// Payment FAILURE screen.
///
/// Opened when the Fatora checkout (in-app WebView) redirects to the
/// gateway's post-payment failure URL (or the patient cancels there).
/// The appointment is left untouched server-side so the patient can retry
/// the same checkout, or leave and pay later from the appointments tab.
class PaymentFailureScreen extends StatelessWidget {
  const PaymentFailureScreen({super.key});

  int? get _appointmentId {
    final raw = (Get.arguments as Map?)?['appointmentId'];
    return raw == null ? null : int.tryParse(raw.toString());
  }

  /// 'deposit' (booking flow) or 'final' (reminder flow remaining payment).
  bool get _isFinalMode =>
      ((Get.arguments as Map?)?['mode'] ?? 'deposit') == 'final';

  String get _doctorName =>
      ((Get.arguments as Map?)?['doctorName'] ?? '') as String;

  String get _paymentUrl =>
      ((Get.arguments as Map?)?['paymentUrl'] ?? '') as String;

  String get _amount => ((Get.arguments as Map?)?['amount'] ?? '') as String;

  void _retry() {
    final arguments = {
      if (_appointmentId != null) 'appointmentId': _appointmentId,
      'flow': _isFinalMode ? 'reminder' : 'booking',
      'doctorName': _doctorName,
      if (_paymentUrl.isNotEmpty) 'paymentUrl': _paymentUrl,
      if (_amount.isNotEmpty) 'amount': _amount,
    };
    if (_paymentUrl.isNotEmpty) {
      // Re-open the same Fatora checkout page in the in-app WebView.
      Get.offNamed(AppRouter.fatoraPayment, arguments: arguments);
      return;
    }
    // No checkout URL available (gateway link was never generated):
    // fall back to the in-app mock payment for this appointment.
    Get.offNamed(
      AppRouter.mockPayment,
      arguments: {
        'appointmentId': _appointmentId,
        'doctorName': _doctorName,
        'mode': _isFinalMode ? 'final' : 'deposit',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text(
          'payment'.tr(),
          style: GoogleFonts.inter(
            color: context.appColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.appColors.danger.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cancel_rounded,
                    color: context.appColors.danger,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'payment_failed'.tr(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'payment_failed_hint'.tr(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: context.appColors.textSecondary,
                  ),
                ),
                if (_doctorName.isNotEmpty || _amount.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.appColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              context.appColors.primary.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (_doctorName.isNotEmpty)
                          _row(
                            context,
                            icon: Icons.person_rounded,
                            label: 'doctor_title'.tr(),
                            value: _doctorName,
                          ),
                        if (_amount.isNotEmpty)
                          _row(
                            context,
                            icon: Icons.payments_outlined,
                            label: _isFinalMode
                                ? 'final_payment'.tr()
                                : 'deposit'.tr(),
                            value: '\$$_amount',
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: _retry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.appColors.primaryContainer,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(
                    'try_again'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Get.offAllNamed(
                    AppRouter.main,
                    arguments: {'tab': 2},
                  ),
                  child: Text(
                    'pay_later'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
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
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
