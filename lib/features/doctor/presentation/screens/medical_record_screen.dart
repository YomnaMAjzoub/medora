import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/doctor/business_layer/controller/doctor_controller.dart';
import 'package:medora_git/features/doctor/data/models/patient_medical_record_model.dart';
import 'package:medora_git/features/patient/data/models/appointment_record_model.dart';
import 'package:medora_git/features/patient/data/models/medical_record_model.dart';

enum QuickAddKind { diagnosis, prescription, note, file }

/// Patient medical records (getMedicalRecord/{id}) with an edit form that
/// updates the record of the tapped appointment (updateMedicalRecord).
class MedicalRecordScreen extends StatefulWidget {
  const MedicalRecordScreen({super.key});

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  DoctorController get controller => Get.find<DoctorController>();

  final _diagnosis = TextEditingController();
  final _prescription = TextEditingController();
  final _tests = TextEditingController();
  final _notes = TextEditingController();
  String? _imagePath;

  late final int _appointmentId =
      (Get.arguments as Map)['appointmentId'] as int;
  late final int _patientId = (Get.arguments as Map)['patientId'] as int;
  late final AppointmentStatus _appointmentStatus =
      AppointmentStatus.values.firstWhere(
    (s) => s.name == (Get.arguments as Map)['status'],
    orElse: () => AppointmentStatus.unknown,
  );

  /// Editing is allowed only on the LAST appointment between this doctor
  /// and the patient, and only while it is 'completed' (see
  /// DoctorController.canEditMedicalRecord). The appointment whose id is
  /// passed to this screen must be that last one.
  bool get _canEdit =>
      _appointmentId > 0 &&
      controller.canEditMedicalRecord(_patientId) &&
      controller.lastAppointmentForPatient(_patientId)?.id == _appointmentId;

  @override
  void initState() {
    super.initState();
    controller.fetchPatientRecord(_patientId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          'medical_record'.tr(),
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
              controller.patientRecord.value == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.recordsError.value,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => controller.fetchPatientRecord(
                        _patientId,
                      ),
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
          final record = controller.patientRecord.value;
          if (record == null) {
            return const SizedBox.shrink();
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              if (_appointmentStatus == AppointmentStatus.pendingDeposit ||
                  _appointmentStatus == AppointmentStatus.confirmed) ...[
                _finalPaymentCard(context),
                const SizedBox(height: 16),
              ],
              _patientHeader(context, record),
              const SizedBox(height: 16),
              if (_canEdit) ...[
                _quickAddSection(context),
                const SizedBox(height: 16),
              ] else ...[
                _editLockedCard(context),
                const SizedBox(height: 16),
              ],
              _sectionTitle('history'.tr()),
              const SizedBox(height: 10),
              if (record.records.isEmpty)
                Text(
                  'no_records'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: context.appColors.textSecondary,
                  ),
                )
              else
                ...record.records.map((r) => _recordCard(context, r)),
              if (_canEdit) ...[
                const SizedBox(height: 24),
                _sectionTitle('update_record'.tr()),
                const SizedBox(height: 10),
                _editForm(context, record),
              ],
            ],
          );
        }),
      ),
    );
  }

  /// Shown instead of the edit form when the last appointment between this
  /// doctor and the patient is not completed yet: nothing is editable.
  Widget _editLockedCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.appColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 22,
            color: context.appColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'record_edit_locked'.tr(),
              style: GoogleFonts.inter(
                fontSize: 12,
                color: context.appColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _finalPaymentCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.appColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'final_payment'.tr(),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.appColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'final_payment_hint'.tr(),
            style: GoogleFonts.inter(
              fontSize: 12,
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => ElevatedButton.icon(
              onPressed: controller.isCompletingPayment.value
                  ? null
                  : () => controller.completeFinalPayment(
                        appointmentId: _appointmentId,
                      ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.primaryContainer,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: context.appColors.border,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: controller.isCompletingPayment.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.payment_rounded, size: 18),
              label: Text(
                'complete_final_payment'.tr(),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _patientHeader(BuildContext context, PatientMedicalRecordModel record) {
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
                      record.fullName,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${record.gender.capitalizeFirst ?? record.gender}'
                      '${record.birth != null ? ' - ${record.birth}' : ''}',
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
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.bloodtype_rounded,
                size: 18,
                color: context.appColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '${'blood_type'.tr()}: ${record.bloodType ?? '-'}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
            ],
          ),
          if (record.previousIllnesses != null &&
              record.previousIllnesses!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '${'illnesses'.tr()}: ${record.previousIllnesses}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: context.appColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _quickAddSection(BuildContext context) {
    final actions = <(IconData, String, QuickAddKind)>[
      (Icons.medical_information_rounded, 'add_diagnosis'.tr(), QuickAddKind.diagnosis),
      (Icons.medication_rounded, 'add_prescription'.tr(), QuickAddKind.prescription),
      (Icons.sticky_note_2_rounded, 'add_note'.tr(), QuickAddKind.note),
      (Icons.upload_file_rounded, 'upload_file'.tr(), QuickAddKind.file),
    ];
    return Row(
      children: [
        for (final (icon, label, kind) in actions)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () => _openQuickAdd(context, kind),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: context.appColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.appColors.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(icon, color: context.appColors.primary, size: 20),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _openQuickAdd(BuildContext context, QuickAddKind kind) async {
    if (kind == QuickAddKind.file) {
      _pickAndUploadFile(context);
      return;
    }

    final inputController = TextEditingController();
    final label = switch (kind) {
      QuickAddKind.diagnosis => 'diagnosis'.tr(),
      QuickAddKind.prescription => 'prescription'.tr(),
      _ => 'notes'.tr(),
    };

    await Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.appColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            _field(context, label, inputController, maxLines: 4),
            const SizedBox(height: 16),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isUpdatingRecord.value
                    ? null
                    : () {
                        if (inputController.text.trim().isEmpty) {
                          Get.snackbar('error'.tr(), 'please_fill_all'.tr());
                          return;
                        }
                        Get.back();
                        _submitQuickAdd(kind, inputController.text.trim());
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appColors.primaryContainer,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: controller.isUpdatingRecord.value
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
    );
  }

  Future<void> _pickAndUploadFile(BuildContext context) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    if (!_canEdit) {
      Get.snackbar('error'.tr(), 'record_edit_locked'.tr());
      return;
    }
    controller.updateMedicalRecord(
      appointmentId: _appointmentId,
      patientId: _patientId,
      imagePath: picked.path,
    );
    await controller.fetchPatientRecord(_patientId);
  }

  void _submitQuickAdd(QuickAddKind kind, String text) {
    if (!_canEdit) {
      Get.snackbar('error'.tr(), 'record_edit_locked'.tr());
      return;
    }
    controller.updateMedicalRecord(
      appointmentId: _appointmentId,
      patientId: _patientId,
      diagnosis: kind == QuickAddKind.diagnosis ? text : null,
      prescription: kind == QuickAddKind.prescription ? text : null,
      notes: kind == QuickAddKind.note ? text : null,
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: context.appColors.primary,
      ),
    );
  }

  Widget _recordCard(BuildContext context, MedicalRecordModel record) {
    final entries = <String, String>{
      if (record.diagnosis != null && record.diagnosis!.isNotEmpty)
        'diagnosis'.tr(): record.diagnosis!,
      if (record.prescription != null && record.prescription!.isNotEmpty)
        'prescription'.tr(): record.prescription!,
      if (record.tests != null && record.tests!.isNotEmpty)
        'tests'.tr(): record.tests!,
      if (record.notes != null && record.notes!.isNotEmpty)
        'notes'.tr(): record.notes!,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEE, d MMM yyyy - h:mm a')
                .format(record.appointmentTime),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.appColors.primary,
            ),
          ),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'no_details'.tr(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: context.appColors.textSecondary,
                ),
              ),
            )
          else
            ...entries.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${entry.key}: ',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.primary,
                        ),
                      ),
                      TextSpan(
                        text: entry.value,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _editForm(BuildContext context, PatientMedicalRecordModel record) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field(context, 'diagnosis'.tr(), _diagnosis, maxLines: 3),
          const SizedBox(height: 14),
          _field(context, 'prescription'.tr(), _prescription, maxLines: 3),
          const SizedBox(height: 14),
          _field(context, 'tests'.tr(), _tests, maxLines: 2),
          const SizedBox(height: 14),
          _field(context, 'notes'.tr(), _notes, maxLines: 3),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () async {
              final picked =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              if (picked != null) {
                setState(() => _imagePath = picked.path);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: context.appColors.inputFill,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _imagePath == null
                        ? Icons.attach_file_rounded
                        : Icons.check_circle_rounded,
                    size: 20,
                    color: context.appColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _imagePath == null
                        ? 'attach_image'.tr()
                        : 'image_selected'.tr(),
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
          const SizedBox(height: 20),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isUpdatingRecord.value
                  ? null
                  : () => _submit(record),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.primaryContainer,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: controller.isUpdatingRecord.value
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
    );
  }

  void _submit(PatientMedicalRecordModel record) {
    if (!_canEdit) {
      Get.snackbar('error'.tr(), 'record_edit_locked'.tr());
      return;
    }
    controller.updateMedicalRecord(
      appointmentId: _appointmentId,
      patientId: _patientId,
      diagnosis: _diagnosis.text,
      prescription: _prescription.text,
      tests: _tests.text,
      notes: _notes.text,
      imagePath: _imagePath,
    );
    _diagnosis.clear();
    _prescription.clear();
    _tests.clear();
    _notes.clear();
    setState(() => _imagePath = null);
  }

  Widget _field(
    BuildContext context,
    String label,
    TextEditingController controller, {
    int maxLines = 1,
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
          maxLines: maxLines,
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