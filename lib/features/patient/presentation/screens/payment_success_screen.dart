import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/patient/business_layer/controller/booking_controller.dart';
import 'package:medora_git/features/patient/business_layer/controller/patient_account_controller.dart';
import 'package:medora_git/features/patient/data/models/payment_success_response_model.dart';
import 'package:medora_git/features/patient/data/src/booking_service.dart';
import 'package:medora_git/features/patient/data/src/patient_service.dart';

/// Payment SUCCESS screen.
///
/// Opened when the Fatora checkout (in-app WebView) redirects to the
/// gateway's post-payment success URL. This is the point where the app
/// confirms the payment with the backend:
///  - mode 'deposit': GET /paymentSuccess -> appointment 'confirmed'
///  - mode 'final'  : GET /completeFinalPayment -> appointment 'completed'
/// The real backend response (message, appointment, payment amounts) is
/// displayed once confirmed.
class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

enum _ConfirmStage { processing, success, failure }

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  final Rx<_ConfirmStage> _stage = _ConfirmStage.processing.obs;
  final RxString _error = ''.obs;
  PaymentSuccessResponseModel? _result;

  int? get _appointmentId {
    final raw = (Get.arguments as Map?)?['appointmentId'];
    return raw == null ? null : int.tryParse(raw.toString());
  }

  /// 'deposit' (booking flow) or 'final' (reminder flow remaining payment).
  bool get _isFinalMode =>
      ((Get.arguments as Map?)?['mode'] ?? 'deposit') == 'final';

  String get _doctorName =>
      ((Get.arguments as Map?)?['doctorName'] ?? '') as String;

  @override
  void initState() {
    super.initState();
    _confirmWithBackend();
  }

  Future<void> _confirmWithBackend() async {
    final id = _appointmentId;
    if (id == null || id == 0) {
      _error.value = 'unable_start_payment'.tr();
      _stage.value = _ConfirmStage.failure;
      return;
    }
    _stage.value = _ConfirmStage.processing;
    try {
      final result = await _confirm(id);
      _result = result;
      _stage.value = _ConfirmStage.success;
      // Keep the appointments tab (and any meet link) in sync with the
      // status the backend just changed.
      if (Get.isRegistered<PatientAccountController>()) {
        Get.find<PatientAccountController>().fetchAppointments();
      }
    } catch (e) {
      _error.value = e.toString();
      _stage.value = _ConfirmStage.failure;
    }
  }

  /// Confirms the payment with the backend through the active flow's
  /// controller when it is registered (booking flow -> BookingController,
  /// reminder flow -> PatientAccountController), falling back to a direct
  /// service call otherwise.
  Future<PaymentSuccessResponseModel> _confirm(int id) {
    if (_isFinalMode) {
      return Get.isRegistered<PatientAccountController>()
          ? Get.find<PatientAccountController>()
              .finalizeReminderPayment(appointmentId: id)
          : PatientService().completeFinalPayment(appointmentId: id);
    }
    return Get.isRegistered<BookingController>()
        ? Get.find<BookingController>().finalizeDepositPayment(
            appointmentId: id,
          )
        : BookingService().paymentSuccess(appointmentId: id);
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
        child: Obx(() {
          switch (_stage.value) {
            case _ConfirmStage.processing:
              return _processingView(colors);
            case _ConfirmStage.success:
              return _successView(colors);
            case _ConfirmStage.failure:
              return _failureView(colors);
          }
        }),
      ),
    );
  }

  Widget _processingView(AppThemeColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              strokeWidth: 3.5,
              color: context.appColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'payment'.tr(),
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _successView(AppThemeColors colors) {
    final result = _result;
    final appointment = result?.appointment;
    final payment = result?.payment;
    final meetLink = appointment?.meetLink;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
            result?.detailMessage?.isNotEmpty == true
                ? result!.detailMessage!
                : 'payment_success'.tr(),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'payment_result_hint'.tr(),
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
                if (_doctorName.isNotEmpty)
                  _row(
                    context,
                    icon: Icons.person_rounded,
                    label: 'doctor_title'.tr(),
                    value: _doctorName,
                  ),
                if (appointment != null) ...[
                  if (appointment.type.isNotEmpty)
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
                  if (payment.remainingAmount != '0' &&
                      payment.remainingAmount != payment.amountPaid)
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
          // Online consultations: the backend generates the Google Meet link
          // at this exact point (final payment completion) and returns it in
          // this response — show it with open/copy actions.
          if (meetLink != null && meetLink.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.appColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.videocam_rounded,
                        size: 20,
                        color: context.appColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'meeting_link'.tr(),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: context.appColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    meetLink,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => launchUrl(
                            Uri.parse(meetLink),
                            mode: LaunchMode.externalApplication,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.appColors.primary,
                            side: BorderSide(
                              color:
                                  context.appColors.primary.withValues(alpha: 0.4),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.videocam_rounded, size: 16),
                          label: Text(
                            'join_meeting'.tr(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: meetLink));
                            Get.snackbar('info'.tr(), 'link_copied'.tr());
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.appColors.primary,
                            side: BorderSide(
                              color:
                                  context.appColors.primary.withValues(alpha: 0.4),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: Text(
                            'copy'.tr(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Get.offAllNamed(
              AppRouter.main,
              arguments: {'tab': 2},
            ),
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
    );
  }

  Widget _failureView(AppThemeColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 52,
              color: context.appColors.danger,
            ),
            const SizedBox(height: 16),
            Text(
              _error.value,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _confirmWithBackend,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.primaryContainer,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('retry'.tr()),
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
