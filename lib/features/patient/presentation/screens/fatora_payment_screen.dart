import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';

/// Hosts Fatora's hosted checkout page inside the app.
///
/// The backend returns a `payment_url` from POST /addBooking (initial
/// deposit) and from POST /appointments/{id}/app-confirm (reminder flow,
/// remaining payment). This screen loads that URL in a WebView and watches
/// the navigation.
///
/// Post-payment redirect handling (verified against the Laravel backend):
/// the checkout is created with hardcoded gateway redirect targets
/// `http://domain.com/payments/success` / `http://domain.com/payments/failure`
/// (AppointmentServices::generateFatoraLink). When Fatora redirects the
/// WebView to either of them, this screen stops that navigation and instead
/// routes the app to the matching in-app result screen:
///  - success -> PaymentSuccessScreen, which confirms the payment with the
///    backend (GET /paymentSuccess for the deposit flow, GET
///    /completeFinalPayment for the reminder flow).
///  - failure/cancel -> PaymentFailureScreen, which offers a retry of the
///    same checkout.
/// The legacy backend callback paths (/paymentSuccess | /paymentCancel,
/// which return JSON) are intercepted the same way as a safety net.
class FatoraPaymentScreen extends StatefulWidget {
  const FatoraPaymentScreen({super.key});

  @override
  State<FatoraPaymentScreen> createState() => _FatoraPaymentScreenState();
}

/// Classifies a navigated URL as one of the backend/gateway post-payment
/// redirect targets, so the WebView can stop it and hand control back to
/// the app.
///
/// Verified against the Laravel backend: the Fatora checkout is created
/// with hardcoded redirect targets `http://domain.com/payments/success`
/// and `http://domain.com/payments/failure`
/// (AppointmentServices::generateFatoraLink). The backend also exposes its
/// own JSON callbacks under `/api/paymentSuccess` and `/api/paymentCancel`,
/// intercepted as a safety net.
/// The outcome a redirect URL represents.
enum PaymentRedirectOutcome { success, failure, none }

class PaymentRedirectMatcher {
  PaymentRedirectMatcher._();

  static PaymentRedirectOutcome classify(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return PaymentRedirectOutcome.none;
    final path = uri.path.toLowerCase();
    if (path.contains('paymentsuccess') ||
        path.startsWith('/payments/success')) {
      return PaymentRedirectOutcome.success;
    }
    if (path.contains('paymentcancel') ||
        path.startsWith('/payments/failure')) {
      return PaymentRedirectOutcome.failure;
    }
    // The placeholder gateway domain used by the backend's checkout request;
    // anything landing there is a terminal post-payment redirect.
    if (uri.host.toLowerCase() == 'domain.com') {
      return path.contains('success')
          ? PaymentRedirectOutcome.success
          : PaymentRedirectOutcome.failure;
    }
    return PaymentRedirectOutcome.none;
  }

  /// The appointment id echoed back in the redirect query when present
  /// (`appointment_id` on backend callbacks, `order_id` on the gateway's).
  static int? appointmentIdFrom(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    return int.tryParse(
      uri.queryParameters['appointment_id'] ??
          uri.queryParameters['order_id'] ??
          '',
    );
  }
}

class _FatoraPaymentScreenState extends State<FatoraPaymentScreen> {
  late final WebViewController _webViewController;
  final RxDouble _progress = 0.0.obs;
  final RxBool _loadFailed = false.obs;

  /// Set once a terminal redirect was detected so no further navigation or
  /// duplicate handling happens while the screen tears down.
  bool _finished = false;

  String? get _paymentUrl =>
      (Get.arguments as Map?)?['paymentUrl'] as String?;

  bool get _isReminderFlow =>
      ((Get.arguments as Map?)?['flow'] as String?) == 'reminder';

  int? get _appointmentId {
    final raw = (Get.arguments as Map?)?['appointmentId'];
    return raw == null ? null : int.tryParse(raw.toString());
  }

  String get _doctorName =>
      ((Get.arguments as Map?)?['doctorName'] ?? '') as String;

  String get _amount => ((Get.arguments as Map?)?['amount'] ?? '') as String;

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
            if (_finished) return NavigationDecision.prevent;
            final outcome = PaymentRedirectMatcher.classify(request.url);
            if (outcome == PaymentRedirectOutcome.none) {
              return NavigationDecision.navigate;
            }

            // Prefer the appointment id echoed back in query params
            // (appointment_id on backend callbacks, order_id on Fatora's),
            // falling back to the id this flow started with.
            final resolvedId = PaymentRedirectMatcher.appointmentIdFrom(
                  request.url,
                ) ??
                _appointmentId;
            _finished = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              if (outcome == PaymentRedirectOutcome.success) {
                Get.offNamed(
                  AppRouter.paymentSuccessScreen,
                  arguments: {
                    'appointmentId': resolvedId,
                    'mode': _isReminderFlow ? 'final' : 'deposit',
                    'doctorName': _doctorName,
                  },
                );
              } else {
                Get.offNamed(
                  AppRouter.paymentFailureScreen,
                  arguments: {
                    'appointmentId': resolvedId,
                    'mode': _isReminderFlow ? 'final' : 'deposit',
                    'doctorName': _doctorName,
                    'paymentUrl': _paymentUrl ?? '',
                    'amount': _amount,
                  },
                );
              }
            });
            return NavigationDecision.prevent;
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