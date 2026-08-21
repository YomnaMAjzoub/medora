import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/storage/appconfig.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/patient/business_layer/controller/patient_account_controller.dart';
import 'package:medora_git/features/patient/data/models/medical_record_model.dart';

/// The patient's medical file: personal overview, the full medical history
/// (diagnoses, lab results, prescriptions, notes per visit) and every file
/// uploaded by doctors. Data comes from getMedicaleRecord via
/// [PatientAccountController].
class MedicalFileScreen extends GetView<PatientAccountController> {
  const MedicalFileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          'medical_file'.tr(),
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
        child: Obx(() {
          if (controller.isLoadingRecords.value) {
            return Center(
              child: CircularProgressIndicator(color: context.appColors.primary),
            );
          }
          if (controller.recordsError.value.isNotEmpty &&
              controller.medicalRecords.isEmpty) {
            return _ErrorRetry(
              message: controller.recordsError.value,
              onRetry: controller.fetchMedicalRecords,
            );
          }
          if (controller.medicalRecords.isEmpty) {
            return _EmptyState();
          }
          final records = controller.medicalRecords;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _overviewCard(context, records),
              const SizedBox(height: 24),
              _sectionTitle(context, 'medical_history'.tr()),
              const SizedBox(height: 10),
              ...records.map((r) => _RecordCard(record: r)),
              const SizedBox(height: 24),
              _sectionTitle(context, 'uploaded_files'.tr()),
              const SizedBox(height: 10),
              _filesSection(context, records),
            ],
          );
        }),
      ),
    );
  }

  Widget _overviewCard(BuildContext context, List<MedicalRecordModel> records) {
    final storage = GetStorage();
    final profile = controller.profile.value;
    final name = (profile?.fullName.isNotEmpty == true)
        ? profile!.fullName
        : (storage.read<String>('user_name') ?? '');
    final email = (profile?.email.isNotEmpty == true)
        ? profile!.email
        : (storage.read<String>('user_email') ?? '');
    final diagnoses = records
        .where((r) => r.diagnosis != null && r.diagnosis!.isNotEmpty)
        .length;
    final prescriptions = records
        .where((r) => r.prescription != null && r.prescription!.isNotEmpty)
        .length;
    final tests = records
        .where((r) => r.tests != null && r.tests!.isNotEmpty)
        .length;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.appColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: context.appColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'patient_account'.tr() : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email.isEmpty ? 'medical_file'.tr() : email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statChip(context, '${records.length}', 'visits'.tr()),
              const SizedBox(width: 8),
              _statChip(context, '$diagnoses', 'diagnosis'.tr()),
              const SizedBox(width: 8),
              _statChip(context, '$prescriptions', 'prescription'.tr()),
              const SizedBox(width: 8),
              _statChip(context, '$tests', 'tests'.tr()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(BuildContext context, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary50.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: context.appColors.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: context.appColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: context.appColors.primary,
      ),
    );
  }

  Widget _filesSection(BuildContext context, List<MedicalRecordModel> records) {
    final urls = <String>[];
    for (final record in records) {
      if (record.images == null || record.images!.isEmpty) continue;
      urls.addAll(
        record.images!
            .split(',')
            .map((u) => u.trim())
            .where((u) => u.isNotEmpty),
      );
    }
    if (urls.isEmpty) {
      return Text(
        'no_files'.tr(),
        style: GoogleFonts.inter(
          fontSize: 14,
          color: context.appColors.textSecondary,
        ),
      );
    }
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final url in urls)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _resolveUrl(url),
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: context.appColors.inputFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.grey300,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Backend storage paths may be relative; normalize them against the
  /// configured host so uploaded files always load.
  String _resolveUrl(String raw) {
    final uri = Uri.tryParse(raw);
    if (uri != null && uri.hasScheme) return raw;
    return '${AppConfig.storageBaseUrl}/storage/$raw';
  }
}

class _RecordCard extends StatefulWidget {
  const _RecordCard({required this.record});

  final MedicalRecordModel record;

  @override
  State<_RecordCard> createState() => _RecordCardState();
}

class _RecordCardState extends State<_RecordCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(14),
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
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.doctorName.isEmpty
                            ? 'doctor'.tr()
                            : record.doctorName,
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
                        '${record.type.capitalizeFirst ?? record.type} - '
                        '${DateFormat('d MMM yyyy - h:mm a').format(record.appointmentTime)}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: context.appColors.primary,
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 24),
            _detailRow(
              context,
              'diagnosis'.tr(),
              record.diagnosis,
              icon: Icons.medical_information_rounded,
            ),
            _detailRow(
              context,
              'lab_results'.tr(),
              record.tests,
              icon: Icons.science_rounded,
            ),
            _detailRow(
              context,
              'prescription'.tr(),
              record.prescription,
              icon: Icons.medication_rounded,
            ),
            _detailRow(
              context,
              'notes'.tr(),
              record.notes,
              icon: Icons.sticky_note_2_rounded,
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    String label,
    String? value, {
    required IconData icon,
  }) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: context.appColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.primary,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: context.appColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.primaryContainer,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.appColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open_rounded,
              size: 36,
              color: context.appColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'no_records'.tr(),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: context.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}