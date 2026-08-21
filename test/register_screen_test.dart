import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/auth/business_layer/controller/auth_controller.dart';
import 'package:medora_git/features/auth/presentation/screens/register_screen.dart';

/// Field order on the register form (matches the widget tree):
/// 0 first name, 1 last name, 2 birth, 3 email, 4 phone,
/// 5 password, 6 confirm password, 7 previous illnesses.
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

  Future<void> pumpRegister(WidgetTester tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    Get.put(AuthController());
    addTearDown(() {
      Get.deleteAll();
    });
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: GetMaterialApp(
          theme: AppTheme.light,
          home: RegisterScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openBirthPicker(WidgetTester tester) async {
    await tester.ensureVisible(find.byType(TextFormField).at(2));
    await tester.tap(find.byType(TextFormField).at(2), warnIfMissed: false);
    await tester.pumpAndSettle();
  }

  testWidgets('DOB picker opens from the birth field', (tester) async {
    await pumpRegister(tester);
    await openBirthPicker(tester);
    expect(find.byType(CalendarDatePicker), findsOneWidget);
  });

  testWidgets('Picking an adult date saves it and closes the sheet',
      (tester) async {
    await pumpRegister(tester);
    await openBirthPicker(tester);

    // Tap the day "15" on the current month grid (an adult date).
    await tester.tap(find.text('15').last);
    await tester.pumpAndSettle();

    final controller = Get.find<AuthController>();
    expect(controller.birthDate.value, isNotEmpty,
        reason: 'birthDate must be saved after picking a date');
    expect(find.byType(CalendarDatePicker), findsNothing,
        reason: 'bottom sheet should close after a valid pick');
  });

testWidgets('Eye icons actually toggle password obscuring', (tester) async {
    await pumpRegister(tester);

    List<bool> obscureStates() => tester
        .widgetList<EditableText>(find.byType(EditableText))
        .map((e) => e.obscureText)
        .toList();

    // Default: password + confirm password are obscured.
    expect(obscureStates(), [false, false, false, false, false, true, true, false]);

    // Toggle the password eye (shows visibility_off because it starts hidden).
    await tester.ensureVisible(find.byIcon(Icons.visibility_off).first);
    await tester.tap(find.byIcon(Icons.visibility_off).first);
    await tester.pump();
    expect(
      obscureStates(),
      [false, false, false, false, false, false, true, false],
      reason: 'password field must become visible after tapping its eye icon',
    );

    // Toggle the confirm-password eye too.
    await tester.ensureVisible(find.byIcon(Icons.visibility_off).first);
    await tester.tap(find.byIcon(Icons.visibility_off).first);
    await tester.pump();
    expect(
      obscureStates(),
      [false, false, false, false, false, false, false, false],
      reason: 'confirm password field must become visible after tapping its eye icon',
    );
  });

  testWidgets('Register fields map to the Postman payload contract',
      (tester) async {
    await pumpRegister(tester);
    final controller = Get.find<AuthController>();

    await tester.enterText(find.byType(TextFormField).at(0), 'manal');
    await tester.enterText(find.byType(TextFormField).at(1), 'alali');
    await tester.tap(find.text('female'));
    await tester.pump();
    await openBirthPicker(tester);
    await tester.tap(find.text('15').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(3), 'manal@test.com');
    await tester.enterText(find.byType(TextFormField).at(4), '093140480');
    await tester.enterText(find.byType(TextFormField).at(5), '12345679');
    await tester.enterText(find.byType(TextFormField).at(6), '12345679');
    await tester.enterText(find.byType(TextFormField).at(7), 'flu');

    expect(controller.gender.value, 'female');
    expect(controller.birthDate.value, isNotEmpty);
    expect(
      controller.birthDate.value,
      matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')),
      reason: 'birth must be sent as YYYY-MM-DD',
    );
  });
}