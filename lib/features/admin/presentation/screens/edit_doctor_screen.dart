import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/admin/business_layer/controller/admin_controller.dart';
import 'package:medora_git/features/admin/presentation/specializations.dart';
import 'package:medora_git/features/patient/data/models/appointment_model.dart';
import 'package:medora_git/features/patient/data/models/doctor_model.dart';
import 'package:medora_git/features/patient/data/models/doctor_profile_model.dart';

/// "Edit Doctor" form (updateDoctor endpoint, partial update). The backend
/// accepts price, home visit, specialization, photo, password and the
/// working day / hours, all optional.
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

  DoctorProfileModel? get _profile {
    for (final profile in controller.doctorProfiles) {
      if (profile.id.toString() == _doctor.id) return profile;
    }
    return null;
  }

  DoctorScheduleModel? get _schedule {
    final profile = _profile;
    if (profile == null || profile.schedules.isEmpty) return null;
    return profile.schedules.first;
  }

  late String _day = 'All';
  late TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  late TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  bool _dayTouched = false;
  bool _timesTouched = false;

  /// The doctor's real schedule may arrive asynchronously
  /// (`controller.doctorProfiles`), so until the user edits the working
  /// hours, fall back to the loaded profile instead of the defaults.
  String get _effectiveDay => _dayTouched ? _day : (_schedule?.day ?? _day);
  TimeOfDay get _effectiveStart => _timesTouched
      ? _startTime
      : (_timeOfDay(_schedule?.startTime) ?? _startTime);
  TimeOfDay get _effectiveEnd => _timesTouched
      ? _endTime
      : (_timeOfDay(_schedule?.endTime) ?? _endTime);

  TimeOfDay? _timeOfDay(String? raw) {
    if (raw == null) return null;
    final parts = raw.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: context.appColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _timesTouched = true;
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          'edit_doctor'.tr(),
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
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _doctor.specialty,
                          style: GoogleFonts.inter(
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
                      color: context.appColors.primary.withValues(alpha: 0.3),
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
                        color: context.appColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _photoPath == null
                            ? 'change_photo'.tr()
                            : 'photo_selected'.tr(),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.primary,
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
                      color: context.appColors.primary.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _dropdown<String>(
                      context,
                      label: 'specialization'.tr(),
                      value: _specialization,
                      items: [
                        if (_specialization.isNotEmpty &&
                            !kDoctorSpecializations.contains(_specialization))
                          DropdownMenuItem(
                            value: _specialization,
                            child: Text(_specialization),
                          ),
                        ...kDoctorSpecializations.map(
                          (s) => DropdownMenuItem(value: s, child: Text(s)),
                        ),
                      ],
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
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      activeTrackColor: context.appColors.primary,
                      value: _homeVisit,
                      onChanged: (v) => setState(() => _homeVisit = v),
                    ),
                    const SizedBox(height: 14),
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _dropdown<String>(
                            context,
                            label: 'working_days'.tr(),
                            value: _effectiveDay,
                            items: _days
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d.tr()),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() {
                              _day = v ?? 'All';
                              _dayTouched = true;
                            }),
                          ),
                          const SizedBox(height: 14),
                          _timeRow(
                            context,
                            'start_time'.tr(),
                            _effectiveStart,
                            isStart: true,
                          ),
                          const SizedBox(height: 14),
                          _timeRow(
                            context,
                            'end_time'.tr(),
                            _effectiveEnd,
                            isStart: false,
                          ),
                        ],
                      ),
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
                    backgroundColor: context.appColors.primaryContainer,
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
                          style: GoogleFonts.inter(
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

  Future<void> _submit() async {
    if (_password.text.isNotEmpty || _confirmPassword.text.isNotEmpty) {
      if (_password.text != _confirmPassword.text) {
        Get.snackbar('error'.tr(), 'passwords_not_match'.tr());
        return;
      }
    }
    final schedule = _schedule;
    final start = _timesTouched
        ? _startTime
        : _timeOfDay(schedule?.startTime);
    final end = _timesTouched ? _endTime : _timeOfDay(schedule?.endTime);
    final updated = await controller.updateDoctor(
      doctor: _doctor,
      price: _price.text.isNotEmpty
          ? (double.tryParse(_normalizeNumber(_price.text)) ?? 0)
          : null,
      homeVisit: _homeVisit,
      specialization: _specialization,
      photoPath: _photoPath,
      password: _password.text.isEmpty ? null : _password.text,
      day: _dayTouched ? _day : schedule?.day,
      startTime: start == null ? null : _formatTime(start),
      endTime: end == null ? null : _formatTime(end),
    );
    if (updated) Get.back();
  }

  String _normalizeNumber(String raw) => raw.trim().replaceAll(',', '.');

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
          style: GoogleFonts.inter(
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
          style: GoogleFonts.inter(
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
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
            ),
            Text(
              time.format(context),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.appColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}