import 'dart:io';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/core/theme/settings_controller.dart';
import 'package:medora_git/core/theme/settings_screen.dart';

/// Verifies the language toggle actually switches the UI language, flips
/// the layout direction for Arabic and persists the choice.
void main() {
  final arabicScript = RegExp(r'[\u0600-\u06FF]');

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory' ||
          call.method == 'getTemporaryDirectory') {
        return Directory.systemTemp.path;
      }
      return null;
    });
    await GetStorage.init();
    // Use the Inter TTFs bundled in assets/fonts/ instead of fetching from
    // fonts.gstatic.com (unreachable in the test sandbox).
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  /// A fresh controller per test so state from a previous test cannot leak.
  Future<SettingsController> freshController({String startLocale = 'en'}) async {
    await GetStorage().write('locale', startLocale);
    final controller = SettingsController();
    Get.put(controller);
    addTearDown(Get.deleteAll);
    return controller;
  }

  // Mirrors the real app wiring from main.dart: GetMaterialApp's locale is
  // driven by the settings controller's Rx so switches rebuild the app.
  Future<void> pumpSettings(WidgetTester tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: Builder(
          builder: (context) => Obx(() {
            final settings = Get.find<SettingsController>();
            return GetMaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: settings.locale.value,
              theme: AppTheme.light,
              home: const SettingsScreen(),
            );
          }),
        ),
      ),
    );
    // easy_localization loads its translation assets asynchronously; keep
    // pumping until .tr() resolves real strings instead of raw keys.
    for (var i = 0; i < 10 && find.text('Settings').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }

  ui.TextDirection bodyDirection(WidgetTester tester) {
    return Directionality.maybeOf(
      tester.element(find.byType(ListView).first),
    )!;
  }

  /// Any Text rendering Arabic-script characters.
  Finder arabicText() => find.byWidgetPredicate(
        (w) => w is Text && arabicScript.hasMatch(w.data ?? ''),
      );
  testWidgets(
      'language toggle: en -> ar (RTL) -> en, strings translate and persist',
      (tester) async {
    await freshController();
    await pumpSettings(tester);

    // English initially; the ONLY Arabic-script text on screen is the
    // Arabic option's own label (shown in Arabic script by design).
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(bodyDirection(tester), ui.TextDirection.ltr);
    expect(arabicText(), findsOneWidget);

    // Tap the Arabic option tile.
    await tester.tap(arabicText().first);
    await tester.pumpAndSettle();

    // Static UI strings are translated (backend data is untouched).
    expect(find.text('Settings'), findsNothing);
    expect(arabicText(), findsWidgets,
        reason: 'UI labels must render in Arabic script');
    expect(bodyDirection(tester), ui.TextDirection.rtl,
        reason: 'Arabic must switch the layout direction to RTL');
    expect(GetStorage().read<String>('locale'), 'ar');

    // Switch back to English via its tile (label stays "English" in both
    // languages by design).
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(bodyDirection(tester), ui.TextDirection.ltr);
    expect(GetStorage().read<String>('locale'), 'en');
  });
}
