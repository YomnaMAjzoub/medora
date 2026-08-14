import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:medora_git/core/routing/app_pages.dart';
import 'package:medora_git/core/theme/settings_controller.dart';
import 'package:medora_git/main.dart';

void main() {
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

  testWidgets('App boots and shows the splash screen', (tester) async {
    // Tests have no network; fall back to the default font instead of
    // fetching Roboto at runtime.
    GoogleFonts.config.allowRuntimeFetching = false;

    Get.put(SettingsController());
    addTearDown(() {
      Get.deleteAll();
    });

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: const MyApp(),
      ),
    );
    await tester.pump();

    // The splash route is the initial route and renders an image.
    expect(find.byType(Image), findsWidgets);
    expect(Get.currentRoute, '/');

    // Let the splash timers fire so nothing stays pending.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('All registered routes are reachable by name', (tester) async {
    expect(AppPages.pages, isNotEmpty);
    final names = AppPages.pages.map((page) => page.name).toList();
    expect(names, contains('/onboarding'));
    expect(names, contains('/login'));
    expect(names, contains('/main'));
    expect(names, contains('/adminHome'));
    expect(names, contains('/doctorHome'));
    expect(names, contains('/addOffer'));
    expect(names, contains('/medicalRecord'));
  });
}
