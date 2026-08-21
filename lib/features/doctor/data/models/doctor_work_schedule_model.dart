/// The doctor's availability plan: working days/hours (the same rows the
/// patient calendar uses), explicit days off and busy/peak-hour windows.
class DoctorWorkScheduleModel {
  const DoctorWorkScheduleModel({
    required this.workingDays,
    required this.daysOff,
    required this.peakHours,
  });

  final List<DoctorWorkDayModel> workingDays;
  final List<String> daysOff;
  final List<String> peakHours;

  factory DoctorWorkScheduleModel.fromJson(Map<String, dynamic> json) {
    return DoctorWorkScheduleModel(
      workingDays: (json['working_days'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(DoctorWorkDayModel.fromJson)
          .toList(),
      daysOff: (json['days_off'] as List? ?? const [])
          .map((d) => d.toString())
          .toList(),
      peakHours: (json['peak_hours'] as List? ?? const [])
          .map((d) => d.toString())
          .toList(),
    );
  }
}

/// One working-day row: which day of the week the doctor works, the shift
/// window and the session price for that day.
class DoctorWorkDayModel {
  DoctorWorkDayModel({
    required this.day,
    required this.startTime,
    required this.endTime,
    this.price = 0,
  });

  String day;
  String startTime;
  String endTime;
  double price;

  factory DoctorWorkDayModel.fromJson(Map<String, dynamic> json) {
    return DoctorWorkDayModel(
      day: json['day'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      price: double.tryParse('${json['price'] ?? 0}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'price': price,
    };
  }
}