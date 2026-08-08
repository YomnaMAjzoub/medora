import 'package:medora_git/features/patient/data/models/add_booking_response_model.dart';
import 'package:medora_git/features/patient/data/models/payment_success_response_model.dart';

class CompleteFinalPaymentResponseModel {
  const CompleteFinalPaymentResponseModel({
    required this.message,
    required this.data,
  });

  final String message;
  final CompleteFinalPaymentDataModel data;

  factory CompleteFinalPaymentResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompleteFinalPaymentResponseModel(
      message: json['message'] as String,
      data: CompleteFinalPaymentDataModel.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
    );
  }
}

class CompleteFinalPaymentDataModel {
  const CompleteFinalPaymentDataModel({
    required this.message,
    required this.fire,
    required this.appointment,
    required this.payment,
  });

  final String message;
  final String fire;
  final BookingAppointmentModel appointment;
  final PaymentModel payment;

  factory CompleteFinalPaymentDataModel.fromJson(Map<String, dynamic> json) {
    return CompleteFinalPaymentDataModel(
      message: json['message'] as String,
      fire: json['fire'] as String,
      appointment: BookingAppointmentModel.fromJson(
        json['appointment'] as Map<String, dynamic>,
      ),
      payment: PaymentModel.fromJson(json['payment'] as Map<String, dynamic>),
    );
  }
}
