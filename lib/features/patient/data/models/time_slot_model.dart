
enum DayPeriod { morning, afternoon, evening }


class TimeSlotModel {
  const TimeSlotModel({required this.time, required this.period, required this.isAvailable});
  final String time;
  final DayPeriod period;
  final bool isAvailable;
}
