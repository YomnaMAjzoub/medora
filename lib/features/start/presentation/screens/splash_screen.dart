import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/services/firebase_service.dart';
import 'package:medora_git/core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  double _scale = 0.8;

  @override
  void initState() {
    super.initState();

    // Best-effort: stays silent if Firebase config files are missing.
    FirebaseService.init();

    Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
        _scale = 1.0;
      });
    });

    Timer(const Duration(seconds: 3), _redirect);
  }

  void _redirect() {
    final storage = GetStorage();
    final token = storage.read<String>('access_token');
    if (token == null || token.isEmpty) {
      Get.offNamed(AppRouter.onboarding);
      return;
    }

    final role = storage.read<String>('role');
    if (role == 'doctor') {
      Get.offNamed(AppRouter.doctorHome);
    } else if (role == 'admin') {
      Get.offNamed(AppRouter.adminHome);
    } else {
      Get.offNamed(AppRouter.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 1),
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            child: Image.asset(
              'assets/images/splash.png',
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.75,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}
