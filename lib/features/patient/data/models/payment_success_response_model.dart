import 'package:medora_git/features/patient/data/models/add_booking_response_model.dart';

class PaymentSuccessResponseModel {
  const PaymentSuccessResponseModel({
    required this.message,
    this.detailMessage,
    this.appointment,
    this.payment,
  });

  /// Top-level message, e.g. "Payment successful".
  final String message;

  /// Nested `data.message` with the real detail,
  /// e.g. "First deposit (50%) paid successfully. Appointment confirmed."
  final String? detailMessage;
  final BookingAppointmentModel? appointment;
  final PaymentModel? payment;

  /// Tolerant parser: only `message` is guaranteed by the backend; the
  /// appointment and payment objects are optional.
  factory PaymentSuccessResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return PaymentSuccessResponseModel(
      message: json['message']?.toString() ?? data['message']?.toString() ?? '',
      detailMessage: data['message']?.toString(),
      appointment: data['appointment'] is Map<String, dynamic>
          ? BookingAppointmentModel.fromJson(
              data['appointment'] as Map<String, dynamic>,
            )
          : null,
      payment: data['payment'] is Map<String, dynamic>
          ? PaymentModel.fromJson(data['payment'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PaymentModel {
  const PaymentModel({
    required this.id,
    required this.appointmentId,
    required this.totalAmount,
    required this.amountPaid,
    required this.remainingAmount,
    required this.method,
    required this.status,
  });

  final int id;
  final int appointmentId;
  final String totalAmount;
  final String amountPaid;
  final String remainingAmount;
  final String method;
  final String status;

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      appointmentId:
          int.tryParse('${json['appointment_id'] ?? 0}') ?? 0,
      totalAmount: json['total_amount']?.toString() ?? '0',
      amountPaid: json['amount_paid']?.toString() ?? '0',
      remainingAmount: json['remaining_amount']?.toString() ?? '0',
      method: json['method'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}