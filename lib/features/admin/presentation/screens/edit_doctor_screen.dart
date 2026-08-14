import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/admin/business_layer/controller/admin_controller.dart';
import 'package:medora_git/features/patient/data/models/appointment_model.dart';
import 'package:medora_git/features/patient/data/models/doctor_model.dart';

/// "Edit Doctor" form (updateDoctor endpoint). The backend only supports
/// updating price, home visit, specialization, photo and password.
class EditDoctorScreen extends StatefulWidget {
  const EditDoctorScreen({super.key});

  @override
  State<EditDoctorScreen> createState() => _EditDoctorScreenState();
}

class _EditDoctorScreenState extends State<EditDoctorScreen> {
  AdminController get controller => Get.find<AdminController>();

  late final DoctorModel _doctor =
      (Get.arguments as Map)['doctor'] as DoctorModel;
  late final TextEditingController _price = TextEditingController(
    text: _doctor.pricePerSession.toStringAsFixed(0),
  );
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  late String _specialization = _doctor.specialty;
  late bool _homeVisit = _doctor.supports(VisitType.home);
  String? _photoPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          'edit_doctor'.tr(),
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
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: Image.network(
                        _doctor.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.secondary100,
                          child: const Icon(
                            Icons.person,
                            size: 32,
                            color: AppColors.primary600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _doctor.name,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _doctor.specialty,
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            color: context.appColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final picked = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setState(() => _photoPath = picked.path);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: context.appColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary700.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _photoPath == null
                            ? Icons.photo_library_rounded
                            : Icons.check_circle_rounded,
                        size: 22,
                        color: AppColors.primary700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _photoPath == null
                            ? 'change_photo'.tr()
                            : 'photo_selected'.tr(),
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary900.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _dropdown(
                      context,
                      label: 'specialization'.tr(),
                      value: _specialization,
                      items: controller.specialties
                          .map(
                            (s) => DropdownMenuItem(
                              value: s.name,
                              child: Text(s.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => _specialization = v ?? '',
                    ),
                    const SizedBox(height: 14),
                    _field(context, 'price'.tr(), _price,
                        keyboard: const TextInputType.numberWithOptions(
                          decimal: true,
                        )),
                    const SizedBox(height: 14),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'home_visit'.tr(),
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      activeTrackColor: AppColors.primary700,
                      value: _homeVisit,
                      onChanged: (v) => setState(() => _homeVisit = v),
                    ),
                    const SizedBox(height: 14),
                    _field(context, 'new_password'.tr(), _password,
                        obscure: true),
                    const SizedBox(height: 14),
                    _field(
                      context,
                      'confirm_password'.tr(),
                      _confirmPassword,
                      obscure: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => ElevatedButton(
                  onPressed:
                      controller.isSubmitting.value ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary900,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
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

  void _submit() {
    if (_password.text != _confirmPassword.text) {
      Get.snackbar('error'.tr(), 'passwords_not_match'.tr());
      return;
    }
    controller.updateDoctor(
      doctor: _doctor,
      price: _price.text.isNotEmpty ? (double.tryParse(_price.text) ?? 0) : null,
      homeVisit: _homeVisit,
      specialization: _specialization,
      photoPath: _photoPath,
      password: _password.text.isEmpty ? null : _password.text,
    );
    Get.back();
  }

  Widget _field(
    BuildContext context,
    String label,
    TextEditingController controller, {
    TextInputType? keyboard,
    bool obscure = false,
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
          controller: controller,
          keyboardType: keyboard,
          obscureText: obscure,
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

  Widget _dropdown<T>(
    BuildContext context, {
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
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
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
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
}