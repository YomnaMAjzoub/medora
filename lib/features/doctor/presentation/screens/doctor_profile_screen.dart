import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/doctor/business_layer/controller/doctor_controller.dart';

/// Doctor profile: read-only overview by default, or an editor for
/// personal / work information when opened with a `mode` argument.
class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  late final String _mode = Get.arguments is Map
      ? (Get.arguments as Map)['mode'] as String? ?? 'view'
      : 'view';

  bool _homeVisit = false;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  void _prefill() {
    final storage = GetStorage();
    final profile = Get.find<DoctorController>().myProfile.value;
    _firstNameController.text = storage.read<String>('user_name') ?? '';
    _lastNameController.text = profile?.lastName ?? '';
    _phoneController.text = storage.read<String>('user_phone') ?? '';
    _emailController.text = storage.read<String>('user_email') ?? '';
    _specializationController.text = profile?.specialization ?? '';
    final price = profile?.pricePerSession ?? 0;
    _priceController.text = price == price.truncateToDouble()
        ? price.toStringAsFixed(0)
        : price.toStringAsFixed(2);
    _homeVisit = profile?.homeVisit ?? false;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _specializationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _save() {
    final controller = Get.find<DoctorController>();
    final storage = GetStorage();
    if (_mode == 'work') {
      controller.updateMyProfile(
        specialization: _specializationController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0,
        homeVisit: _homeVisit,
      );
    } else {
      final fullName = _firstNameController.text.trim();
      if (fullName.isNotEmpty) storage.write('user_name', fullName);
      storage.write('user_phone', _phoneController.text.trim());
      storage.write('user_email', _emailController.text.trim());
      Get.snackbar('success'.tr(), 'profile_updated'.tr());
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isWork = _mode == 'work';
    final title = switch (_mode) {
      'personal' => 'personal_info'.tr(),
      'work' => 'work_info'.tr(),
      _ => 'doctor_profile'.tr(),
    };

    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          title,
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
        child: GetBuilder<DoctorController>(
          builder: (controller) {
            if (_mode == 'view') {
              final profile = controller.myProfile.value;
              if (controller.isLoadingProfile.value && profile == null) {
                return Center(
                  child: CircularProgressIndicator(
                    color: context.appColors.primary,
                  ),
                );
              }
              return _viewProfile(context, profile);
            }
            return _editForm(context, isWork);
          },
        ),
      ),
    );
  }

  Widget _editForm(BuildContext context, bool isWork) {
    return ListView(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isWork) ...[
                _field(context, 'first_name'.tr(), _firstNameController),
                const SizedBox(height: 12),
                _field(context, 'last_name'.tr(), _lastNameController),
                const SizedBox(height: 12),
                _field(context, 'phone'.tr(), _phoneController,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                _field(context, 'email'.tr(), _emailController,
                    keyboardType: TextInputType.emailAddress),
              ] else ...[
                _field(context, 'specialization'.tr(), _specializationController),
                const SizedBox(height: 12),
                _field(context, 'price_per_session'.tr(), _priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(
                    Icons.home_rounded,
                    color: context.appColors.primary,
                    size: 22,
                  ),
                  title: Text(
                    'home_visit'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                  activeTrackColor: context.appColors.primary,
                  value: _homeVisit,
                  onChanged: (value) => setState(() => _homeVisit = value),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appColors.primaryContainer,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'save'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _field(
    BuildContext context,
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          color: context.appColors.textSecondary,
        ),
        filled: true,
        fillColor: context.appColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _viewProfile(BuildContext context, profile) {
    final storage = GetStorage();
    final name = profile != null
        ? '${profile.firstName} ${profile.lastName}'.trim()
        : (storage.read<String>('user_name') ?? 'doctor_title'.tr());
    final email = storage.read<String>('user_email') ?? '';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
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
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: context.appColors.primaryContainer,
                child: profile?.profilePhoto.isNotEmpty == true
                    ? ClipOval(
                        child: Image.network(
                          profile.profilePhoto,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 40,
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: context.appColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              if (profile != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.appColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    profile.specialization,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (profile != null) ...[
          _infoTile(
            context,
            icon: Icons.payments_outlined,
            label: 'price_per_session'.tr(),
            value: '${profile.pricePerSession.toStringAsFixed(0)} SR',
          ),
          _infoTile(
            context,
            icon: Icons.home_rounded,
            label: 'home_visit'.tr(),
            value: profile.homeVisit
                ? 'available'.tr()
                : 'not_available'.tr(),
          ),
          _infoTile(
            context,
            icon: Icons.check_circle_outline_rounded,
            label: 'status'.tr(),
            value: profile.isAvailable
                ? 'available'.tr()
                : 'not_available'.tr(),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Get.toNamed(
                  AppRouter.doctorProfile,
                  arguments: {'mode': 'personal'},
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary900,
                  side: BorderSide(
                    color: context.appColors.primary.withValues(alpha: 0.4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.person_outline_rounded, size: 18),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'personal_info'.tr(),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Get.toNamed(
                  AppRouter.doctorProfile,
                  arguments: {'mode': 'work'},
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary900,
                  side: BorderSide(
                    color: context.appColors.primary.withValues(alpha: 0.4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.work_outline_rounded, size: 18),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'work_info'.tr(),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: context.appColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.appColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}