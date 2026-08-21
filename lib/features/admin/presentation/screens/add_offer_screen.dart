import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/common/widgets/step_indicator.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/admin/business_layer/controller/admin_controller.dart';
import 'package:medora_git/features/admin/data/models/admin_offer_model.dart';

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

  Future<void> _submit() async {
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
    // Wait for the backend to confirm the offer was created. On success the
    // form stays open (cleared) so the confirmed offer card and the grown
    // step indicator are visible; failures keep the entered values for
    // retry.
    final added = await controller.addOffer(
      title: title,
      description: description,
      discountPercentage: discount,
      validFrom: _validFrom!,
      validUntil: _validUntil!,
    );
    if (added) {
      _title.clear();
      _description.clear();
      _discount.clear();
      setState(() {
        _validFrom = null;
        _validUntil = null;
      });
    }
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
          style: GoogleFonts.inter(
            color: context.appColors.primary,
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
              // One step per offer added so far — grows with every
              // successful save.
              Obx(() {
                final count = controller.createdOffers.length;
                if (count == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: StepIndicator(currentStep: count, totalSteps: count),
                );
              }),
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
                    backgroundColor: context.appColors.primaryContainer,
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
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              // Confirmed offers (backend-verified) with their discount.
              Obx(() {
                final offers = controller.createdOffers;
                if (offers.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
                    Text(
                      'added_offers'.tr(),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final offer in offers) ...[
                      _offerCard(context, offer),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _offerCard(BuildContext context, AdminOfferModel offer) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.appColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.appColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '-${offer.discountPercentage.toStringAsFixed(0)}%',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: context.appColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  offer.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: context.appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${offer.validFrom} → ${offer.validUntil}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            size: 20,
            color: context.appColors.success,
          ),
        ],
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
          style: GoogleFonts.inter(
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
            Icon(
              Icons.calendar_month_rounded,
              size: 18,
              color: context.appColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value == null
                    ? label
                    : DateFormat('yyyy-MM-dd').format(value),
                style: GoogleFonts.inter(
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