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
        child: Obx(() {
          if (controller.isLoadingRecords.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary700),
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
                      style: GoogleFonts.roboto(
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
                        backgroundColor: AppColors.primary900,
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
              _sectionTitle('history'.tr()),
              const SizedBox(height: 10),
              if (record.records.isEmpty)
                Text(
                  'no_records'.tr(),
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: context.appColors.textSecondary,
                  ),
                )
              else
                ...record.records.map((r) => _recordCard(context, r)),
              const SizedBox(height: 24),
              _sectionTitle('update_record'.tr()),
              const SizedBox(height: 10),
              _editForm(context, record),
            ],
          );
        }),
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
          color: AppColors.primary700.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'final_payment'.tr(),
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'final_payment_hint'.tr(),
            style: GoogleFonts.roboto(
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
                backgroundColor: AppColors.primary900,
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
                style: GoogleFonts.roboto(
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
            color: AppColors.primary900.withValues(alpha: 0.08),
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
                  color: AppColors.primary900.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary800,
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
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${record.gender.capitalizeFirst ?? record.gender}'
                      '${record.birth != null ? ' - ${record.birth}' : ''}',
                      style: GoogleFonts.roboto(
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
          Text(
            '${record.email}'
            '${record.previousIllnesses != null && record.previousIllnesses!.isNotEmpty ? '  |  ${'illnesses'.tr()}: ${record.previousIllnesses}' : ''}',
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: context.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.roboto(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.primary700,
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
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary700,
            ),
          ),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'no_details'.tr(),
                style: GoogleFonts.roboto(
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
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary700,
                        ),
                      ),
                      TextSpan(
                        text: entry.value,
                        style: GoogleFonts.roboto(
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
            color: AppColors.primary900.withValues(alpha: 0.06),
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
                    color: AppColors.primary700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _imagePath == null
                        ? 'attach_image'.tr()
                        : 'image_selected'.tr(),
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
          const SizedBox(height: 20),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isUpdatingRecord.value
                  ? null
                  : () => _submit(record),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary900,
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
                      style: GoogleFonts.roboto(
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
          style: GoogleFonts.roboto(
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