class AddBookingResponseModel {
  const AddBookingResponseModel({
    required this.appointment,
    required this.paymentUrl,
    required this.amountToPayNow,
  });

  final BookingAppointmentModel appointment;
  final String paymentUrl;
  final int amountToPayNow;

  factory AddBookingResponseModel.fromJson(Map<String, dynamic> json) {
    return AddBookingResponseModel(
      appointment: BookingAppointmentModel.fromJson(
        json['appointment'] as Map<String, dynamic>,
      ),
      paymentUrl: json['payment_url'] as String,
      amountToPayNow: json['amount_to_pay_now'] as int,
    );
  }
}

class BookingAppointmentModel {
  const BookingAppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.type,
    required this.appointmentTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.locationId,
  });

  final int id;
  final int patientId;
  final String doctorId;
  final String type;
  final String appointmentTime;
  final String status;
  final int? locationId;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory BookingAppointmentModel.fromJson(Map<String, dynamic> json) {
    return BookingAppointmentModel(
      id: json['id'] as int,
      patientId: json['patient_id'] as int,
      doctorId: json['doctor_id'].toString(),
      type: json['type'] as String,
      appointmentTime: json['appointment_time'] as String,
      status: json['status'] as String,
      locationId: json['location_id'] != null
          ? int.tryParse(json['location_id'].toString())
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
