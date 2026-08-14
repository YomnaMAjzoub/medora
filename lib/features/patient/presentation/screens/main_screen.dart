import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:medora_git/common/widgets/nav_bar_painter.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/patient/presentation/screens/appointments_screen.dart';
import 'package:medora_git/features/patient/presentation/screens/medical_records_screen.dart';
import 'package:medora_git/features/patient/presentation/screens/patient_home_screen.dart';
import 'package:medora_git/features/patient/presentation/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double getSelectorPosition(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    double itemWidth = width / 5;

    num positionIndex = selectedIndex < 2 ? selectedIndex : selectedIndex + 1;

    return itemWidth * positionIndex + (itemWidth / 2) - 26.36;
  }

  int selectedIndex = 0;

  final pages = [
    PatientHomeScreen(),
    MedicalRecordsScreen(),
    AppointmentsScreen(),
    ProfileScreen(),
  ];

  void changeTab(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget navItem(int index, String label, String icon, String selectedIcon) {
    final selected = index == selectedIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => changeTab(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              selected ? selectedIcon : icon,
              width: 24.81,
              height: 24,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: selected
                    ? AppColors.primary800
                    : context.appColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      extendBody: true,
      body: pages[selectedIndex],

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      floatingActionButton: Transform.translate(
        offset: Offset(0, -10),
        child: InkWell(
          onTap: () {
            Get.toNamed(AppRouter.book);
          },
          child: Container(
            height: 64.09,
            width: 62.01,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary700,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: .25),
                  blurRadius: 7,
                  spreadRadius: 0,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                "assets/icons/add.svg",
                width: 16.63,
                height: 16.63,
                fit: BoxFit.none,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 69.22,
        child: Stack(
          children: [
            CustomPaint(
              size: const Size(double.infinity, 69.22),
              painter: NavBarPainter(
                fabRadius: 37.78,
                fillColor: colors.surface,
                shadowColor: colors.shadow,
                borderColor: colors.border,
              ),
            ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              top: 0,
              left: getSelectorPosition(context),
              child: Container(
                width: 52.72,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.primary600,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
              ),
            ),

            Row(
              children: [
                navItem(
                  0,
                  "home".tr(),
                  "assets/icons/home.svg",
                  "assets/icons/homes2.svg",
                ),

                navItem(
                  1,
                  "records".tr(),
                  "assets/icons/records.svg",
                  "assets/icons/records2.svg",
                ),

                Spacer(),

                navItem(
                  2,
                  "schedules".tr(),
                  "assets/icons/schedules.svg",
                  "assets/icons/schedules2.svg",
                ),

                navItem(
                  3,
                  "profile".tr(),
                  "assets/icons/person.svg",
                  "assets/icons/profile2.svg",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
