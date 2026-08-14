import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/patient/business_layer/controller/doctor_discovery_controller.dart';

enum GenderFilter { any, male, female }

/// Filter selection for the "Select Doctor" step.
/// `gender` and `specialization` are sent to the backend
/// (GET /filterDoctor); `maxPrice` is applied locally since the API
/// has no price parameter.
class DoctorFilters {
  const DoctorFilters({
    this.gender = GenderFilter.any,
    this.specialization,
    this.maxPrice = 500,
  });

  final GenderFilter gender;
  final String? specialization;
  final double maxPrice;

  DoctorFilters copyWith({
    GenderFilter? gender,
    String? specialization,
    double? maxPrice,
  }) {
    return DoctorFilters(
      gender: gender ?? this.gender,
      specialization: specialization ?? this.specialization,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }
}

/// Opens the doctor-list filter sheet (gender, specialization, price range).
/// Returns the applied [DoctorFilters], or null if the sheet was dismissed
/// without tapping "Apply Filters".
Future<DoctorFilters?> showDoctorFilterSheet(
  BuildContext context,
  DoctorFilters current,
) {
  return showModalBottomSheet<DoctorFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.appColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _DoctorFilterSheet(initialFilters: current),
  );
}

class _DoctorFilterSheet extends StatefulWidget {
  const _DoctorFilterSheet({required this.initialFilters});

  final DoctorFilters initialFilters;

  @override
  State<_DoctorFilterSheet> createState() => _DoctorFilterSheetState();
}

class _DoctorFilterSheetState extends State<_DoctorFilterSheet> {
  late DoctorFilters _filters = widget.initialFilters;

  @override
  Widget build(BuildContext context) {
    final discovery = Get.find<DoctorDiscoveryController>();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'filters'.tr(),
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'specialization'.tr(),
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.appColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(
                  label: 'all'.tr(),
                  selected: _filters.specialization == null,
                  onTap: () => setState(
                    () => _filters = _filters.copyWith(specialization: null),
                  ),
                  colors: context.appColors,
                ),
                ...discovery.specialties.map(
                  (specialty) => _chip(
                    label: specialty.name,
                    selected: _filters.specialization == specialty.name,
                    onTap: () => setState(
                      () => _filters = _filters.copyWith(
                        specialization: specialty.name,
                      ),
                    ),
                    colors: context.appColors,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'doctor_gender'.tr(),
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.appColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: GenderFilter.values.map((gender) {
                final isSelected = _filters.gender == gender;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      switch (gender) {
                        GenderFilter.any => 'any'.tr(),
                        GenderFilter.male => 'male'.tr(),
                        GenderFilter.female => 'female'.tr(),
                      },
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(
                      () => _filters = _filters.copyWith(gender: gender),
                    ),
                    selectedColor: AppColors.primary900,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.white
                          : context.appColors.textSecondary,
                      fontSize: 12,
                    ),
                    backgroundColor: context.appColors.background,
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary900
                            : context.appColors.border,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'price_range'.tr(),
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.appColors.textSecondary,
              ),
            ),
            Slider(
              value: _filters.maxPrice,
              min: 0,
              max: 500,
              divisions: 20,
              activeColor: AppColors.primary700,
              onChanged: (value) =>
                  setState(() => _filters = _filters.copyWith(maxPrice: value)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$0',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.appColors.textSecondary,
                  ),
                ),
                Text(
                  'up_to'.tr().replaceFirst(
                        '{max}',
                        '\$${_filters.maxPrice.toStringAsFixed(0)}',
                      ),
                  style: TextStyle(
                    fontSize: 11,
                    color: context.appColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        setState(() => _filters = const DoctorFilters()),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: context.appColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('reset'.tr()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, _filters),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary900,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('apply_filters'.tr()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required AppThemeColors colors,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary900,
      labelStyle: TextStyle(
        color: selected ? AppColors.white : colors.textSecondary,
        fontSize: 12,
      ),
      backgroundColor: colors.background,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppColors.primary900 : colors.border,
        ),
      ),
    );
  }
}