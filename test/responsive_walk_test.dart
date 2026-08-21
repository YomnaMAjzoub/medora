import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/common/widgets/elevated_button.dart';
import 'package:medora_git/core/routing/app_pages.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/core/theme/settings_controller.dart';
import 'package:medora_git/core/theme/settings_screen.dart';
import 'package:medora_git/features/auth/business_layer/controller/auth_controller.dart';
import 'package:medora_git/features/auth/presentation/screens/login_screen.dart';
import 'package:medora_git/features/auth/presentation/screens/otp_screen.dart';
import 'package:medora_git/features/auth/presentation/screens/register_screen.dart';
import 'package:medora_git/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:medora_git/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:medora_git/features/start/presentation/screens/onboarding_screen.dart';
import 'package:medora_git/features/start/presentation/screens/splash_screen.dart';

/// Walks every pumpable screen at small-phone / normal-phone / tablet sizes
/// and fails on ANY layout overflow or unhandled exception.
void main() {
  const sizes = <(String, Size)>[
    ('small phone', Size(320, 568)),
    ('phone', Size(390, 844)),
    ('tablet', Size(800, 1280)),
  ];

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return Directory.systemTemp.path;
      }
      return null;
    });
    await GetStorage.init();
  });

  Future<void> pump(
    WidgetTester tester,
    Size size,
    Widget home,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: GetMaterialApp(
          theme: AppTheme.light,
          getPages: AppPages.pages,
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final (label, size) in sizes) {
    group('$label (${size.width}x${size.height})', () {
      testWidgets('OnboardingScreen lays out', (tester) async {
        await pump(tester, size, const OnboardingScreen());
        expect(tester.takeException(), isNull);
        await tester.tap(find.byType(CustomElevated).first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('SplashScreen lays out', (tester) async {
        await pump(tester, size, const SplashScreen());
        expect(tester.takeException(), isNull);
        // Let the splash's 3s redirect timer fire so no timers stay pending.
        await tester.pump(const Duration(seconds: 3));
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('RoleSelectionScreen lays out', (tester) async {
        Get.put(AuthController());
        addTearDown(Get.deleteAll);
        await pump(tester, size, RoleSelectionScreen());
        expect(tester.takeException(), isNull);
      });

      testWidgets('LoginScreen lays out', (tester) async {
        Get.put(AuthController());
        addTearDown(Get.deleteAll);
        await pump(tester, size, LoginScreen());
        expect(tester.takeException(), isNull);
      });

      testWidgets('RegisterScreen lays out', (tester) async {
        Get.put(AuthController());
        addTearDown(Get.deleteAll);
        await pump(tester, size, RegisterScreen());
        expect(tester.takeException(), isNull);
      });

      testWidgets('OTPScreen lays out', (tester) async {
        Get.put(AuthController());
        addTearDown(Get.deleteAll);
        await pump(
          tester,
          size,
          VerificationScreen(email: 'a@b.com', isRegister: true),
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('ResetPasswordScreen lays out', (tester) async {
        Get.put(AuthController());
        addTearDown(Get.deleteAll);
        await pump(
          tester,
          size,
          ResetPasswordScreen(email: 'a@b.com', otp: '123456'),
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('SettingsScreen lays out', (tester) async {
        Get.put(SettingsController());
        addTearDown(Get.deleteAll);
        await pump(tester, size, SettingsScreen());
        expect(tester.takeException(), isNull);
      });
    });
  }
}