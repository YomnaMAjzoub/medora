/// Payment state of a doctor invoice.
enum InvoiceStatus { paid, partial, unpaid }

/// A view-only invoice row: how much the patient paid (deposit), how much
/// remains and the final invoice amount. No payment action on the doctor
/// side.
class DoctorInvoiceModel {
  const DoctorInvoiceModel({
    required this.id,
    required this.patientName,
    required this.appointmentTime,
    required this.type,
    required this.status,
    required this.total,
    required this.deposit,
    required this.remaining,
    this.paidAt,
  });

  final String id;
  final String patientName;
  final DateTime appointmentTime;
  final String type;
  final InvoiceStatus status;
  final double total;
  final double deposit;
  final double remaining;
  final DateTime? paidAt;

  factory DoctorInvoiceModel.fromJson(Map<String, dynamic> json) {
    final total = double.tryParse('${json['total'] ?? 0}') ?? 0;
    final deposit = double.tryParse('${json['deposit'] ?? 0}') ?? 0;
    final remaining = double.tryParse('${json['remaining'] ?? 0}') ?? 0;
    return DoctorInvoiceModel(
      id: json['id'].toString(),
      patientName: json['patient_name'] as String? ?? '',
      appointmentTime:
          DateTime.tryParse(json['appointment_time'] as String? ?? '') ??
              DateTime.now(),
      type: json['type'] as String? ?? '',
      status: _statusFrom(json['status'] as String? ?? ''),
      total: total,
      deposit: deposit,
      remaining: remaining,
      paidAt: DateTime.tryParse(json['paid_at'] as String? ?? ''),
    );
  }

  static InvoiceStatus _statusFrom(String raw) {
    switch (raw) {
      case 'paid':
      case 'completed':
        return InvoiceStatus.paid;
      case 'partial':
      case 'pending_deposit':
        return InvoiceStatus.partial;
      default:
        return InvoiceStatus.unpaid;
    }
  }
}