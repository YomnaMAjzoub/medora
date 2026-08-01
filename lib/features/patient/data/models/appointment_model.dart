import 'package:medora_git/features/patient/data/models/doctor_summary_model.dart';

enum VisitType { clinic, home, online }

class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.doctor,
    required this.date,
    required this.time,
    required this.visitType,
  });

  final String id;
  final DoctorSummaryModel doctor;
  final DateTime date;
  final String time;
  final VisitType visitType;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'].toString(),
      doctor: DoctorSummaryModel.fromJson(
        json['doctor'] as Map<String, dynamic>,
      ),
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      visitType: VisitType.values.firstWhere(
        (type) => type.name == json['visit_type'],
        orElse: () => VisitType.clinic,
      ),
    );
  }
}
