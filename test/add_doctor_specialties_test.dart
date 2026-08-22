import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/admin/business_layer/controller/admin_controller.dart';
import 'package:medora_git/features/admin/data/models/item_model.dart';
import 'package:medora_git/features/admin/data/src/admin_service.dart';
import 'package:medora_git/features/admin/presentation/screens/add_doctor_screen.dart';
import 'package:medora_git/features/patient/data/models/doctor_profile_model.dart';

class _FakeAdminService extends AdminService {
  int specializationCalls = 0;

  @override
  Future<List<DoctorProfileModel>> getAllDoctors() async => const [];

  @override
  Future<List<String>> getSpecializations() async {
    specializationCalls++;
    return const ['Cardiology', 'Dermatology', 'Neurology'];
  }

  @override
  Future<List<ItemModel>> getItems() async => const [];
}

void main() {
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
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpForm(WidgetTester tester) async {
    final controller = AdminController(service: _FakeAdminService());
    Get.put(controller);
    addTearDown(Get.deleteAll);
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: GetMaterialApp(
          theme: AppTheme.light,
          home: const AddDoctorScreen(),
        ),
      ),
    );
    // Allow the specializations fetch to complete.
    await tester.pumpAndSettle();
  }

  testWidgets(
      'specialization dropdown lists the backend values and selecting one works',
      (tester) async {
    await pumpForm(tester);

    // Open the specialization dropdown (first _dropdown on the form) â€”
    // scroll it into view first since the form is long.
    final dropdown = find.byType(DropdownButtonFormField<String>).first;
    await tester.scrollUntilVisible(
      dropdown,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    expect(find.text('Cardiology').last, findsOneWidget,
        reason: 'backend specialties must appear in the open menu');
    expect(find.text('Neurology').last, findsOneWidget);

    await tester.tap(find.text('Cardiology').last);
    await tester.pumpAndSettle();
  });
}
