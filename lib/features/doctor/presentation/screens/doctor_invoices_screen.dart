import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/doctor/business_layer/controller/doctor_controller.dart';
import 'package:medora_git/features/doctor/data/models/doctor_invoice_model.dart';

/// The doctor's invoices: session price, the 50% deposit already paid by
/// the patient and the remaining balance, with a status chip per invoice.
class DoctorInvoicesScreen extends GetView<DoctorController> {
  const DoctorInvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          'invoices'.tr(),
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
          if (controller.isLoadingInvoices.value && controller.invoices.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: context.appColors.primary),
            );
          }
          if (controller.invoicesError.value.isNotEmpty &&
              controller.invoices.isEmpty) {
            return Center(child: Text(controller.invoicesError.value));
          }
          if (controller.invoices.isEmpty) {
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
                      Icons.receipt_long_rounded,
                      size: 32,
                      color: context.appColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'no_invoices'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            itemCount: controller.invoices.length,
            itemBuilder: (context, index) {
              final invoice = controller.invoices[index];
              return _invoiceCard(context, invoice);
            },
          );
        }),
      ),
    );
  }

  Widget _invoiceCard(BuildContext context, DoctorInvoiceModel invoice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                  invoice.patientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                ),
              ),
              _statusChip(context, invoice.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('d MMM yyyy, HH:mm').format(invoice.appointmentTime),
            style: GoogleFonts.inter(
              fontSize: 12,
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _amount(
                  context,
                  label: 'session_price'.tr(),
                  value: invoice.total.toStringAsFixed(0),
                ),
              ),
              Expanded(
                child: _amount(
                  context,
                  label: 'deposit'.tr(),
                  value: invoice.deposit.toStringAsFixed(0),
                ),
              ),
              Expanded(
                child: _amount(
                  context,
                  label: 'remaining'.tr(),
                  value: invoice.remaining.toStringAsFixed(0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _amount(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$value SR',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: context.appColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _statusChip(BuildContext context, InvoiceStatus status) {
    final (color, label) = switch (status) {
      InvoiceStatus.paid => (context.appColors.primary, 'paid'.tr()),
      InvoiceStatus.partial => (AppColors.yellow, 'pending'.tr()),
      InvoiceStatus.unpaid => (context.appColors.danger, 'cancelled'.tr()),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color == AppColors.yellow ? AppColors.grey500 : color,
        ),
      ),
    );
  }
}