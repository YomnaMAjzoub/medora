import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/patient/business_layer/controller/booking_controller.dart';
import 'package:medora_git/features/patient/business_layer/controller/patient_account_controller.dart';

/// Hosts Fatora's hosted checkout page inside the app.
///
/// The backend returns a `payment_url` from POST /addBooking (initial
/// deposit) and from POST /appointments/{id}/app-confirm (reminder flow,
/// remaining payment). This screen loads that URL in a WebView and watches
/// the navigation: when Fatora redirects to the backend callbacks
/// (`/paymentSuccess` or `/paymentCancel`), the screen hands control back to
/// the active flow's controller:
///  - flow 'booking'  (default): BookingController confirms/cancels the
///    booking and shows the result screen.
///  - flow 'reminder': PatientAccountController finalises the remaining
///    payment and returns to the appointments tab.
class FatoraPaymentScreen extends StatefulWidget {
  const FatoraPaymentScreen({super.key});

  @override
  State<FatoraPaymentScreen> createState() => _FatoraPaymentScreenState();
}

class _FatoraPaymentScreenState extends State<FatoraPaymentScreen> {
  late final WebViewController _webViewController;
  final RxDouble _progress = 0.0.obs;
  final RxBool _loadFailed = false.obs;

  String? get _paymentUrl =>
      (Get.arguments as Map?)?['paymentUrl'] as String?;

  bool get _isReminderFlow =>
      ((Get.arguments as Map?)?['flow'] as String?) == 'reminder';

  int? get _appointmentId {
    final raw = (Get.arguments as Map?)?['appointmentId'];
    return raw == null ? null : int.tryParse(raw.toString());
  }

  @override
  void initState() {
    super.initState();
    final url = _paymentUrl;

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) => _progress.value = progress / 100,
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            final path = uri?.path ?? '';
            final appointmentId = int.tryParse(
              uri?.queryParameters['appointment_id'] ?? '',
            );
            if (path.contains('paymentSuccess')) {
              // Cancel the navigation (the callback returns JSON, not a page)
              // and let the active flow's controller finalise the payment.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pop();
                final resolved = appointmentId ?? _appointmentId;
                if (resolved == null) return;
                if (_isReminderFlow) {
                  Get.find<PatientAccountController>()
                      .completeReminderPayment(appointmentId: resolved);
                } else {
                  Get.find<BookingController>().confirmPaymentAfterWebview(
                    appointmentId: resolved,
                  );
                }
              });
              return NavigationDecision.prevent;
            }
            if (path.contains('paymentCancel')) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pop();
                final resolved = appointmentId ?? _appointmentId;
                if (resolved == null) return;
                if (_isReminderFlow) {
                  Get.find<PatientAccountController>()
                      .cancelReminderPayment(appointmentId: resolved);
                } else {
                  Get.find<BookingController>().cancelPaymentAfterWebview(
                    appointmentId: resolved,
                  );
                }
              });
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (_) {
            _loadFailed.value = true;
          },
          onPageFinished: (_) {
            _loadFailed.value = false;
            _progress.value = 1.0;
          },
        ),
      );

    if (url != null && url.isNotEmpty) {
      _webViewController.loadRequest(Uri.parse(url));
    } else {
      _loadFailed.value = true;
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
          'secure_payment'.tr(),
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
          if (_loadFailed.value) {
            return _errorView(colors);
          }
          return Column(
            children: [
              Obx(
                () => LinearProgressIndicator(
                  value: _progress.value,
                  minHeight: 3,
                  color: AppColors.primary600,
                  backgroundColor: AppColors.primary100,
                ),
              ),
              Expanded(
                child: WebViewWidget(controller: _webViewController),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _errorView(AppThemeColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: AppColors.grey300,
            ),
            const SizedBox(height: 16),
            Text(
              'payment_page_error'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                final url = _paymentUrl;
                if (url == null || url.isEmpty) {
                  Get.snackbar('error'.tr(), 'payment_page_error'.tr());
                  return;
                }
                _loadFailed.value = false;
                _webViewController.loadRequest(Uri.parse(url));
              },
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
}