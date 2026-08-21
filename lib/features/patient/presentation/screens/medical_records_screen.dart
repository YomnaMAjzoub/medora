import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/patient/business_layer/controller/patient_account_controller.dart';
import 'package:medora_git/features/patient/data/models/medical_record_model.dart';

/// "Records" tab: the patient's medical records fetched from
/// getMedicaleRecord, with a PDF export action.
class MedicalRecordsScreen extends GetView<PatientAccountController> {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          'records'.tr(),
          style: GoogleFonts.inter(
            color: context.appColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(
            () => IconButton(
              onPressed: controller.isExportingPdf.value
                  ? null
                  : controller.exportMedicalRecordsPdf,
              icon: controller.isExportingPdf.value
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.appColors.primary,
                      ),
                    )
                  : Icon(
                      Icons.ios_share_rounded,
                      color: context.appColors.primary,
                    ),
              tooltip: 'export_records'.tr(),
            ),
          ),
          const SizedBox(width: 4),
        ],
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
                      onPressed: controller.fetchMedicalRecords,
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
          if (controller.medicalRecords.isEmpty) {
            return Center(
              child: Text(
                'no_records'.tr(),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: context.appColors.textSecondary,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
            itemCount: controller.medicalRecords.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _RecordCard(record: controller.medicalRecords[index]);
            },
          );
        }),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final MedicalRecordModel record;

  @override
  Widget build(BuildContext context) {
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
              Expanded(
                child: Text(
                  record.doctorName.isEmpty
                      ? 'doctor'.tr()
                      : record.doctorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                ),
              ),
              Text(
                DateFormat('d MMM yyyy').format(record.appointmentTime),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${record.type.capitalizeFirst ?? record.type} - '
            '${DateFormat('h:mm a').format(record.appointmentTime)}',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: context.appColors.textSecondary,
            ),
          ),
          if (entries.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...entries.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
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
        ],
      ),
    );
  }
}