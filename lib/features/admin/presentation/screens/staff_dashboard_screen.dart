import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/admin/business_layer/controller/admin_controller.dart';
import 'package:medora_git/features/auth/data/src/auth_service.dart';
import 'package:medora_git/features/notifications/business_layer/controller/notifications_controller.dart';

/// Staff (Admin) dashboard shell: quick access to every clinic module.
/// Only Doctors is functional this phase; the rest land on placeholder
/// screens until their modules are built.
class StaffDashboardScreen extends GetView<AdminController> {
  const StaffDashboardScreen({super.key});

  void _logout() {
    Get.defaultDialog(
      title: 'logout'.tr(),
      middleText: 'logout_confirm'.tr(),
      textCancel: 'cancel'.tr(),
      textConfirm: 'logout'.tr(),
      confirmTextColor: AppColors.white,
      buttonColor: Get.context!.appColors.primaryContainer,
      onConfirm: () async {
        Get.back();
        final service = AuthService();
        await service.logout();
        await service.clearSession();
        Get.offAllNamed(AppRouter.onboarding);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = GetStorage().read<String>('user_name') ?? '';
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          'staff_dashboard'.tr(),
          style: GoogleFonts.inter(
            color: context.appColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(
            () => IconButton(
              tooltip: 'notifications'.tr(),
              onPressed: () => Get.toNamed(AppRouter.adminNotifications),
              icon: Badge(
                isLabelVisible:
                    Get.find<NotificationsController>().unreadCount.value > 0,
                label: Text(
                  '${Get.find<NotificationsController>().unreadCount.value}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                backgroundColor: context.appColors.danger,
                child: Icon(
                  Icons.notifications_rounded,
                  color: context.appColors.primary,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'logout'.tr(),
            onPressed: _logout,
            icon: Icon(
              Icons.logout_rounded,
              color: context.appColors.primary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.appColors.primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: context.appColors.primaryContainer,
                    child: Icon(Icons.admin_panel_settings, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'welcome_staff'.tr(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: context.appColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          name.isEmpty ? 'staff'.tr() : name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'quick_access'.tr(),
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: context.appColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            _quickAccessGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _quickAccessGrid(BuildContext context) {
    final items = <(IconData, String, String)>[
      (
        Icons.medical_services_rounded,
        'doctors_title'.tr(),
        AppRouter.staffDoctors,
      ),
      (
        Icons.inventory_2_rounded,
        'inventory'.tr(),
        AppRouter.staffInventory,
      ),
      (
        Icons.local_offer_rounded,
        'offers'.tr(),
        AppRouter.staffOffers,
      ),
      (
        Icons.settings_rounded,
        'settings'.tr(),
        AppRouter.settings,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.15,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final (icon, label, route) = items[index];
        return InkWell(
          onTap: () => Get.toNamed(route),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: context.appColors.shadow.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: context.appColors.primary, size: 26),
                const SizedBox(height: 8),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}