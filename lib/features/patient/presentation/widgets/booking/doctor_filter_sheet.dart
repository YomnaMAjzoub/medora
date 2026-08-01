import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';

enum GenderFilter { any, male, female }

/// Filter selection for the "Select Doctor" step. Purely local UI state
/// for now -- once doctors are fetched from the backend, this same shape
/// can be sent along with the request instead of being applied locally.
class DoctorFilters {
  const DoctorFilters({
    this.gender = GenderFilter.any,
    this.maxPrice = 500,
    this.availableTodayOnly = false,
    this.acceptsInsuranceOnly = false,
  });

  final GenderFilter gender;
  final double maxPrice;
  final bool availableTodayOnly;
  final bool acceptsInsuranceOnly;

  DoctorFilters copyWith({
    GenderFilter? gender,
    double? maxPrice,
    bool? availableTodayOnly,
    bool? acceptsInsuranceOnly,
  }) {
    return DoctorFilters(
      gender: gender ?? this.gender,
      maxPrice: maxPrice ?? this.maxPrice,
      availableTodayOnly: availableTodayOnly ?? this.availableTodayOnly,
      acceptsInsuranceOnly: acceptsInsuranceOnly ?? this.acceptsInsuranceOnly,
    );
  }
}

/// Opens the doctor-list filter sheet (gender, price range, availability).
/// Returns the applied [DoctorFilters], or null if the sheet was dismissed
/// without tapping "Apply Filters".
Future<DoctorFilters?> showDoctorFilterSheet(
  BuildContext context,
  DoctorFilters current,
) {
  return showModalBottomSheet<DoctorFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey500,
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
            'Doctor Gender',
            style: GoogleFonts.roboto(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.grey300,
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
                    gender.name[0].toUpperCase() + gender.name.substring(1),
                  ),
                  selected: isSelected,
                  onSelected: (_) => setState(
                    () => _filters = _filters.copyWith(gender: gender),
                  ),
                  selectedColor: AppColors.primary900,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.grey400,
                    fontSize: 12,
                  ),
                  backgroundColor: AppColors.mainScreen,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary900
                          : AppColors.neutral200,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            'Price Range (Session)',
            style: GoogleFonts.roboto(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.grey300,
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
              const Text(
                '\$0',
                style: TextStyle(fontSize: 11, color: AppColors.grey300),
              ),
              Text(
                'Up to \$${_filters.maxPrice.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 11, color: AppColors.grey300),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Availability',
            style: GoogleFonts.roboto(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.grey300,
            ),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              'Available Today',
              style: TextStyle(fontSize: 13),
            ),
            value: _filters.availableTodayOnly,
            activeColor: AppColors.primary700,
            onChanged: (value) => setState(
              () => _filters = _filters.copyWith(
                availableTodayOnly: value ?? false,
              ),
            ),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              'Accepts Insurance',
              style: TextStyle(fontSize: 13),
            ),
            value: _filters.acceptsInsuranceOnly,
            activeColor: AppColors.primary700,
            onChanged: (value) => setState(
              () => _filters = _filters.copyWith(
                acceptsInsuranceOnly: value ?? false,
              ),
            ),
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
                    side: const BorderSide(color: AppColors.neutral300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Reset'),
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
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
