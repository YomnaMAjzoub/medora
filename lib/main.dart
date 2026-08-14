import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medora_git/core/routing/app_pages.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/services/firebase_service.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/core/theme/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await GetStorage.init();
  // Must run before runApp so terminated-state notifications are handled.
  await FirebaseService.registerBackgroundHandler();
  Get.put(SettingsController());

  final storage = GetStorage();
  final savedLocale = storage.read<String>('locale') ?? 'en';

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: Locale(savedLocale),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: Get.find<SettingsController>().themeMode.value,
        initialRoute: AppRouter.splash,
        getPages: AppPages.pages,
      ),
    );
  }
}