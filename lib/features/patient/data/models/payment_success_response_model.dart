import 'package:medora_git/features/patient/data/models/add_booking_response_model.dart';

class PaymentSuccessResponseModel {
  const PaymentSuccessResponseModel({
    required this.message,
    required this.data,
  });

  final String message;
  final PaymentSuccessDataModel data;

  factory PaymentSuccessResponseModel.fromJson(Map<String, dynamic> json) {
    return PaymentSuccessResponseModel(
      message: json['message'] as String,
      data: PaymentSuccessDataModel.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
    );
  }
}

class PaymentSuccessDataModel {
  const PaymentSuccessDataModel({
    required this.message,
    required this.appointment,
    required this.payment,
  });

  final String message;
  final BookingAppointmentModel appointment;
  final PaymentModel payment;

  factory PaymentSuccessDataModel.fromJson(Map<String, dynamic> json) {
    return PaymentSuccessDataModel(
      message: json['message'] as String,
      appointment: BookingAppointmentModel.fromJson(
        json['appointment'] as Map<String, dynamic>,
      ),
      payment: PaymentModel.fromJson(json['payment'] as Map<String, dynamic>),
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
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int appointmentId;
  final String totalAmount;
  final String amountPaid;
  final String remainingAmount;
  final String method;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as int,
      appointmentId: json['appointment_id'] as int,
      totalAmount: json['total_amount'].toString(),
      amountPaid: json['amount_paid'].toString(),
      remainingAmount: json['remaining_amount'].toString(),
      method: json['method'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
