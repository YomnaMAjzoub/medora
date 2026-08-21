class AddBookingResponseModel {
  const AddBookingResponseModel({
    required this.appointment,
    this.paymentUrl = '',
    this.amountToPayNow = 0,
  });

  final BookingAppointmentModel appointment;
  final String paymentUrl;
  final int amountToPayNow;

  /// Tolerant parser: the backend returns the created appointment under
  /// `appointment`, `data` or `message`, and the payment fields are not
  /// guaranteed to be present (the payment step is simulated in-app).
  factory AddBookingResponseModel.fromJson(Map<String, dynamic> json) {
    final appointmentJson = json['appointment'] is Map<String, dynamic>
        ? json['appointment'] as Map<String, dynamic>
        : (json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : (json['message'] is Map<String, dynamic>
                ? json['message'] as Map<String, dynamic>
                : json));
    return AddBookingResponseModel(
      appointment: BookingAppointmentModel.fromJson(appointmentJson),
      paymentUrl: json['payment_url']?.toString() ?? '',
      amountToPayNow:
          int.tryParse('${json['amount_to_pay_now'] ?? 0}') ?? 0,
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
    this.locationId,
  });

  final int id;
  final int patientId;
  final String doctorId;
  final String type;
  final String appointmentTime;
  final String status;
  final int? locationId;

  factory BookingAppointmentModel.fromJson(Map<String, dynamic> json) {
    return BookingAppointmentModel(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      patientId: int.tryParse('${json['patient_id'] ?? 0}') ?? 0,
      doctorId: '${json['doctor_id'] ?? 0}',
      type: json['type'] as String? ?? '',
      appointmentTime: json['appointment_time'] as String? ?? '',
      status: json['status'] as String? ?? '',
      locationId: json['location_id'] != null
          ? int.tryParse('${json['location_id']}')
          : null,
    );
  }
}