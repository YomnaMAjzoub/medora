import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/admin/business_layer/controller/admin_controller.dart';

/// "Add Doctor" form (addDoctor endpoint).
class AddDoctorScreen extends StatefulWidget {
  const AddDoctorScreen({super.key});

  @override
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  AdminController get controller => Get.find<AdminController>();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _price = TextEditingController();

  String _specialization = '';
  String _gender = 'male';
  String _day = 'All';
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  bool _homeVisit = false;
  String? _photoPath;

  static const _days = [
    'All',
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _photoPath = picked.path);
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary700,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submit() {
    final fields = [
      _firstName.text,
      _lastName.text,
      _email.text,
      _phone.text,
      _password.text,
      _confirmPassword.text,
      _price.text,
    ];
    if (fields.any((f) => f.trim().isEmpty)) {
      Get.snackbar('error'.tr(), 'please_fill_all'.tr());
      return;
    }
    if (_password.text != _confirmPassword.text) {
      Get.snackbar('error'.tr(), 'passwords_not_match'.tr());
      return;
    }
    if (_specialization.isEmpty) {
      Get.snackbar('error'.tr(), 'choose_specialization'.tr());
      return;
    }
    if (_photoPath == null) {
      Get.snackbar('error'.tr(), 'choose_profile_photo'.tr());
      return;
    }
    controller.addDoctor(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      specialization: _specialization,
      phone: _phone.text.trim(),
      gender: _gender,
      day: _day,
      startTime: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      homeVisit: _homeVisit,
      price: double.tryParse(_price.text) ?? 0,
      photoPath: _photoPath!,
    );
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final specializations = controller.specialties;
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          'add_doctor'.tr(),
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
              _buildPhotoPicker(context),
              const SizedBox(height: 16),
              _card(
                context,
                children: [
                  _field(context, 'first_name'.tr(), _firstName),
                  _field(context, 'last_name'.tr(), _lastName),
                  _field(
                    context,
                    'email'.tr(),
                    _email,
                    keyboard: TextInputType.emailAddress,
                  ),
                  _field(
                    context,
                    'phone'.tr(),
                    _phone,
                    keyboard: TextInputType.phone,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _card(
                context,
                children: [
                  _dropdown<String>(
                    context,
                    label: 'specialization'.tr(),
                    value: _specialization,
                    items: specializations
                        .map(
                          (s) => DropdownMenuItem(
                            value: s.name,
                            child: Text(s.name),
                          ),
                        )
                        .toList(),
                    hint: controller.isLoadingSpecializations.value
                        ? 'loading'.tr()
                        : null,
                    onChanged: (v) => _specialization = v ?? '',
                  ),
                  _dropdown<String>(
                    context,
                    label: 'gender'.tr(),
                    value: _gender,
                    items: [
                      DropdownMenuItem(value: 'male', child: Text('male'.tr())),
                      DropdownMenuItem(
                        value: 'female',
                        child: Text('female'.tr()),
                      ),
                    ],
                    onChanged: (v) => _gender = v ?? 'male',
                  ),
                  _dropdown<String>(
                    context,
                    label: 'working_days'.tr(),
                    value: _day,
                    items: _days
                        .map(
                          (d) => DropdownMenuItem(value: d, child: Text(d.tr())),
                        )
                        .toList(),
                    onChanged: (v) => _day = v ?? 'All',
                  ),
                  _timeRow(context, 'start_time'.tr(), _startTime,
                      isStart: true),
                  _timeRow(context, 'end_time'.tr(), _endTime, isStart: false),
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
                  _field(
                    context,
                    'price'.tr(),
                    _price,
                    keyboard: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ],
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

  Widget _buildPhotoPicker(BuildContext context) {
    return GestureDetector(
      onTap: _pickPhoto,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary700.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            _photoPath == null
                ? const Icon(
                    Icons.add_a_photo_rounded,
                    size: 40,
                    color: AppColors.primary700,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_photoPath!),
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
            const SizedBox(height: 8),
            Text(
              'profile_photo'.tr(),
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, {required List<Widget> children}) {
    return Container(
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
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            children[i],
          ],
        ],
      ),
    );
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
    String? hint,
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
          initialValue: (hint == null && value.toString().isNotEmpty)
              ? value
              : null,
          hint: hint != null
              ? Text(
                  hint,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: context.appColors.textSecondary,
                  ),
                )
              : null,
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

  Widget _timeRow(
    BuildContext context,
    String label,
    TimeOfDay time, {
    required bool isStart,
  }) {
    return InkWell(
      onTap: () => _pickTime(isStart: isStart),
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
            ),
            Text(
              time.format(context),
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
