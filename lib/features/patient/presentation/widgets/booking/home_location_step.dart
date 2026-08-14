import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/patient/business_layer/controller/booking_controller.dart';
import 'package:medora_git/features/patient/presentation/screens/map_picker_screen.dart';

/// Step 3 of the booking flow -- only shown for [VisitType.home] (see
/// [BookingController.steps]). Tapping the card opens the full-screen
/// [MapPickerScreen] where the patient can search, use the current-location
/// button or drag the map to line up the centre pin. The address resolves
/// automatically and confirming calls [BookingController.confirmHomeLocation],
/// which saves the location via the addLocation endpoint and advances to
/// date & time.
class HomeLocationStep extends StatelessWidget {
  const HomeLocationStep({super.key});

  Future<void> _openPicker(BuildContext context) async {
    final controller = Get.find<BookingController>();
    final result = await Get.to<MapPickResult>(
      () => MapPickerScreen(
        initialLocation: controller.homeVisitLatLng.value,
        initialAddress: controller.homeVisitAddress.value,
      ),
    );
    if (result == null) return;
    await controller.confirmHomeLocation(
      location: LatLng(result.latitude, result.longitude),
      address: result.address,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'home_visit_location'.tr(),
            style: GoogleFonts.roboto(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'home_location_hint'.tr(),
            style: GoogleFonts.roboto(
              fontSize: 13,
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Obx(() {
            final latLng = controller.homeVisitLatLng.value;
            final address = controller.homeVisitAddress.value;
            final hasPick = latLng != null && address != null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () => _openPicker(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary700.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.secondary100,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.map_rounded,
                              color: AppColors.primary700,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hasPick ? 'picked_address' : 'pick_on_map',
                                  style: GoogleFonts.roboto(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: context.appColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  hasPick
                                      ? address
                                      : 'open_map_hint'.tr(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    color: context.appColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: context.appColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (hasPick) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: context.appColors.inputFill,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.my_location_rounded,
                          size: 16,
                          color: AppColors.primary700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${latLng.latitude.toStringAsFixed(5)}, '
                            '${latLng.longitude.toStringAsFixed(5)}',
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: context.appColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          }),
          const SizedBox(height: 20),
          Obx(
            () => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => _openPicker(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary900,
                  disabledBackgroundColor: context.appColors.border,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Obx(
                  () => controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          'pick_location'.tr(),
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
