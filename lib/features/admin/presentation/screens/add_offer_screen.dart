import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/admin/business_layer/controller/admin_controller.dart';

/// Admin screen for creating a discount offer (addOffer). Dates are sent
/// as "yyyy-MM-dd" as expected by the API.
class AddOfferScreen extends StatefulWidget {
  const AddOfferScreen({super.key});

  @override
  State<AddOfferScreen> createState() => _AddOfferScreenState();
}

class _AddOfferScreenState extends State<AddOfferScreen> {
  AdminController get controller => Get.find<AdminController>();

  final _title = TextEditingController();
  final _description = TextEditingController();
  final _discount = TextEditingController();
  DateTime? _validFrom;
  DateTime? _validUntil;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _discount.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? (_validFrom ?? now) : (_validUntil ?? now),
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _validFrom = picked;
      } else {
        _validUntil = picked;
      }
    });
  }

  void _submit() {
    final title = _title.text.trim();
    final description = _description.text.trim();
    final discount = double.tryParse(_discount.text.trim());
    if (title.isEmpty || description.isEmpty || discount == null) {
      Get.snackbar('Warning', 'complete_all_fields'.tr());
      return;
    }
    if (_validFrom == null || _validUntil == null) {
      Get.snackbar('Warning', 'select_dates'.tr());
      return;
    }
    if (_validUntil!.isBefore(_validFrom!)) {
      Get.snackbar('Warning', 'invalid_dates'.tr());
      return;
    }
    controller.addOffer(
      title: title,
      description: description,
      discountPercentage: discount,
      validFrom: _validFrom!,
      validUntil: _validUntil!,
    );
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text(
          'add_offer'.tr(),
          style: GoogleFonts.roboto(
            color: AppColors.primary700,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field(context, 'offer_title'.tr(), _title),
              const SizedBox(height: 14),
              _field(context, 'offer_description'.tr(), _description,
                  maxLines: 3),
              const SizedBox(height: 14),
              _field(context, 'discount_percentage'.tr(), _discount,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: true,
                  )),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _dateField(
                      context,
                      label: 'valid_from'.tr(),
                      value: _validFrom,
                      onTap: () => _pickDate(isFrom: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dateField(
                      context,
                      label: 'valid_until'.tr(),
                      value: _validUntil,
                      onTap: () => _pickDate(isFrom: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary900,
                    disabledBackgroundColor: colors.border,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: controller.isSubmitting.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          'save'.tr(),
                          style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    BuildContext context,
    String label,
    TextEditingController textController, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.appColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: textController,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: true,
            fillColor: context.appColors.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateField(
    BuildContext context, {
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: context.appColors.inputFill,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              size: 18,
              color: AppColors.primary700,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value == null
                    ? label
                    : DateFormat('yyyy-MM-dd').format(value),
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  fontWeight: value == null
                      ? FontWeight.w400
                      : FontWeight.w600,
                  color: value == null
                      ? context.appColors.textHint
                      : context.appColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}