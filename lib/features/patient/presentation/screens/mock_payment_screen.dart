import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/patient/business_layer/controller/booking_controller.dart';
import 'package:medora_git/features/patient/business_layer/controller/patient_account_controller.dart';

/// In-app MOCK payment screen (no real gateway).
///
/// The backend payment endpoints accept only `appointment_id` — they have no
/// redirect/callback URL parameter — so this flow is synchronous:
///  1. The patient reviews the mock payment details and taps Pay.
///  2. A mock confirmation (fake transaction reference) is shown.
///  3. Confirming sends the real backend request:
///     - mode 'deposit': GET /paymentSuccess -> appointment 'confirmed'
///       (handled by [BookingController.payDeposit], which then shows the
///       payment result screen).
///     - mode 'final': GET /completeFinalPayment -> appointment 'completed'
///       (handled by [PatientAccountController.completeReminderPayment]).
///  4. If the backend call fails, a failure state is shown with retry.
class MockPaymentScreen extends StatefulWidget {
  const MockPaymentScreen({super.key});

  @override
  State<MockPaymentScreen> createState() => _MockPaymentScreenState();
}

enum _MockStage { pay, confirm, processing, failure }

class _MockPaymentScreenState extends State<MockPaymentScreen> {
  final Rx<_MockStage> _stage = _MockStage.pay.obs;
  late final String _transactionRef;

  int? get _appointmentId {
    final raw = (Get.arguments as Map?)?['appointmentId'];
    return raw == null ? null : int.tryParse(raw.toString());
  }

  String get _amount => ((Get.arguments as Map?)?['amount'] ?? '') as String;

  String get _doctorName =>
      ((Get.arguments as Map?)?['doctorName'] ?? '') as String;

  /// 'deposit' (booking flow) or 'final' (reminder flow remaining payment).
  bool get _isFinalMode =>
      ((Get.arguments as Map?)?['mode'] ?? 'deposit') == 'final';

  @override
  void initState() {
    super.initState();
    _transactionRef = 'MOCK-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _confirmPayment() async {
    final id = _appointmentId;
    if (id == null || id == 0) {
      Get.snackbar('warning'.tr(), 'unable_start_payment'.tr());
      return;
    }
    _stage.value = _MockStage.processing;
    try {
      final success = _isFinalMode
          ? await Get.find<PatientAccountController>()
              .completeReminderPayment(appointmentId: id)
          : await Get.find<BookingController>().payDeposit(appointmentId: id);
      if (!success) {
        _stage.value = _MockStage.failure;
      }
      // On success the flow controllers navigate away (result screen or
      // appointments tab), so no navigation happens here.
    } catch (_) {
      _stage.value = _MockStage.failure;
    }
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
        leading: IconButton(
          icon: Icon(Icons.close, color: context.appColors.primary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          switch (_stage.value) {
            case _MockStage.pay:
              return _buildPayStage(colors);
            case _MockStage.confirm:
            case _MockStage.processing:
              return _buildConfirmStage(colors);
            case _MockStage.failure:
              return _buildFailureStage(colors);
          }
        }),
      ),
    );
  }

  Widget _buildPayStage(AppThemeColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                _row(
                  context,
                  icon: _isFinalMode
                      ? Icons.receipt_long_rounded
                      : Icons.savings_rounded,
                  label: _isFinalMode ? 'final_payment'.tr() : 'deposit'.tr(),
                  value: _amount.isNotEmpty
                      ? '\$$_amount'
                      : 'remaining_amount'.tr(),
                ),
                if (_doctorName.isNotEmpty)
                  _row(
                    context,
                    icon: Icons.person_rounded,
                    label: 'doctor_title'.tr(),
                    value: _doctorName,
                  ),
                _row(
                  context,
                  icon: Icons.credit_card,
                  label: 'payment_method'.tr(),
                  value: 'credit_debit_card'.tr(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'mock_payment_notice'.tr(),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _stage.value = _MockStage.confirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.appColors.primaryContainer,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'pay_now'.tr(),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmStage(AppThemeColors colors) {
    final isProcessing = _stage.value == _MockStage.processing;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.appColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: isProcessing
                ? SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: context.appColors.primary,
                    ),
                  )
                : Icon(
                    Icons.receipt_rounded,
                    color: context.appColors.primary,
                    size: 44,
                  ),
          ),
          const SizedBox(height: 18),
          Text(
            'mock_payment_review'.tr(),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 22),
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
                _row(
                  context,
                  icon: Icons.confirmation_number_rounded,
                  label: 'transaction_ref'.tr(),
                  value: _transactionRef,
                ),
                _row(
                  context,
                  icon: Icons.credit_card,
                  label: 'payment_method'.tr(),
                  value: 'credit_debit_card'.tr(),
                ),
                if (_amount.isNotEmpty)
                  _row(
                    context,
                    icon: Icons.payments_outlined,
                    label: 'amount_paid'.tr(),
                    value: '\$$_amount',
                    highlight: true,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'mock_payment_notice'.tr(),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: isProcessing ? null : _confirmPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.appColors.primaryContainer,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: isProcessing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.white,
                    ),
                  )
                : Text(
                    'confirm_payment'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          if (!isProcessing) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _stage.value = _MockStage.pay,
              child: Text(
                'cancel'.tr(),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFailureStage(AppThemeColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'payment_failed_hint'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 26),
            ElevatedButton.icon(
              onPressed: () => _stage.value = _MockStage.confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.primaryContainer,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'retry'.tr(),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
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
