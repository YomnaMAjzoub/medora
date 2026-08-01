import 'package:flutter/material.dart' hide DayPeriod;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/features/patient/business_layer/controller/booking_controller.dart';
import 'package:medora_git/features/patient/data/models/time_slot_model.dart';

/// Step 4 of the booking flow: pick a day from the next two bookable
/// weeks, then a time slot on that day. Unlike steps 1-3, this one needs
/// an explicit "Continue" tap -- date and time are two separate choices
/// on the same screen, so there's no single tap that means "done".
///
/// The bookable dates and time slots below are static placeholder data --
/// swap [_bookableDates]/[_slotsFor] for a real backend call once it's
/// ready. Only the actual date/time picked lives on [BookingController],
/// since later steps (and eventually payment) need it.
class SelectTimeStep extends StatefulWidget {
  const SelectTimeStep({super.key});

  @override
  State<SelectTimeStep> createState() => _SelectTimeStepState();
}

class _SelectTimeStepState extends State<SelectTimeStep> {
  final BookingController controller = Get.find<BookingController>();
  late DateTime _visibleMonth;

  static List<DateTime> get _bookableDates {
    final today = DateTime.now();
    return List.generate(14, (i) {
      final date = today.add(Duration(days: i));
      return DateTime(date.year, date.month, date.day);
    });
  }

  static bool _isDateBookable(DateTime date) =>
      _bookableDates.any((d) => d.isAtSameMomentAs(date));

  static List<TimeSlotModel> _slotsFor(DateTime date) {
    const morning = [
      '09:00 AM',
      '09:30 AM',
      '10:00 AM',
      '10:30 AM',
      '11:00 AM',
      '11:30 AM',
    ];
    const afternoon = [
      '01:00 PM',
      '01:30 PM',
      '02:00 PM',
      '02:30 PM',
      '03:00 PM',
      '03:30 PM',
    ];
    const evening = ['05:00 PM', '05:30 PM', '06:00 PM'];

    var offset = 0;
    bool isAvailable() => (date.day + offset++) % 4 != 0;

    return [
      for (final time in morning)
        TimeSlotModel(
          time: time,
          period: DayPeriod.morning,
          isAvailable: isAvailable(),
        ),
      for (final time in afternoon)
        TimeSlotModel(
          time: time,
          period: DayPeriod.afternoon,
          isAvailable: isAvailable(),
        ),
      for (final time in evening)
        TimeSlotModel(
          time: time,
          period: DayPeriod.evening,
          isAvailable: isAvailable(),
        ),
    ];
  }

  @override
  void initState() {
    super.initState();
    final initialDate = controller.selectedDate.value ?? _bookableDates.first;
    _visibleMonth = DateTime(initialDate.year, initialDate.month);
    if (controller.selectedDate.value == null) {
      controller.selectDate(initialDate);
    }
  }

  void _changeMonth(int delta) {
    setState(
      () => _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + delta,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Date & Time',
            style: GoogleFonts.roboto(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose your preferred day and time for the consultation',
            style: GoogleFonts.roboto(fontSize: 13, color: AppColors.grey300),
          ),
          const SizedBox(height: 20),
          _MonthCalendar(
            visibleMonth: _visibleMonth,
            onChangeMonth: _changeMonth,
            controller: controller,
          ),
          const SizedBox(height: 24),
          Obx(() {
            final date = controller.selectedDate.value;
            if (date == null) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Time',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('EEEE, MMMM d').format(date),
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: AppColors.grey300,
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 14),
          Obx(() {
            final date = controller.selectedDate.value;
            if (date == null) return const SizedBox.shrink();
            final slots = _slotsFor(date);

            return Column(
              children: DayPeriod.values
                  .map(
                    (period) => _TimeSlotSection(
                      period: period,
                      slots: slots
                          .where((slot) => slot.period == period)
                          .toList(),
                      controller: controller,
                    ),
                  )
                  .toList(),
            );
          }),
          const SizedBox(height: 8),
          Obx(
            () => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    controller.selectedDate.value != null &&
                        controller.selectedTimeSlot.value != null
                    ? controller.confirmDateTime
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary900,
                  disabledBackgroundColor: AppColors.neutral300,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Continue to Payment',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.visibleMonth,
    required this.onChangeMonth,
    required this.controller,
  });

  final DateTime visibleMonth;
  final ValueChanged<int> onChangeMonth;
  final BookingController controller;

  static const _weekdayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(
      visibleMonth.year,
      visibleMonth.month + 1,
      0,
    ).day;
    final leadingBlanks =
        DateTime(visibleMonth.year, visibleMonth.month, 1).weekday -
        1; // Monday = 1 -> 0 blanks

    final today = DateTime.now();
    final currentMonthStart = DateTime(today.year, today.month);
    final lastBookableMonth = _SelectTimeStepState._bookableDates.last;
    final canGoPrev = visibleMonth.isAfter(currentMonthStart);
    final canGoNext = DateTime(
      visibleMonth.year,
      visibleMonth.month,
    ).isBefore(DateTime(lastBookableMonth.year, lastBookableMonth.month + 1));

    final cells = <Widget>[
      for (var i = 0; i < leadingBlanks; i++) const SizedBox(),
      for (var day = 1; day <= daysInMonth; day++)
        _DayCell(
          date: DateTime(visibleMonth.year, visibleMonth.month, day),
          controller: controller,
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowb.withValues(alpha: .5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(visibleMonth),
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey500,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: canGoPrev ? () => onChangeMonth(-1) : null,
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      color: canGoPrev ? AppColors.grey500 : AppColors.grey100,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: canGoNext ? () => onChangeMonth(1) : null,
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      color: canGoNext ? AppColors.grey500 : AppColors.grey100,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: _weekdayLabels
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey300,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: cells,
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.date, required this.controller});

  final DateTime date;
  final BookingController controller;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isBookable = _SelectTimeStepState._isDateBookable(date);
      final isSelected =
          controller.selectedDate.value != null &&
          _isSameDay(controller.selectedDate.value!, date);
      final isToday = _isSameDay(DateTime.now(), date);

      return InkWell(
        onTap: isBookable ? () => controller.selectDate(date) : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary700
                : (isToday ? AppColors.secondary100 : null),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${date.day}',
            style: GoogleFonts.roboto(
              fontSize: 13,
              fontWeight: isSelected || isToday
                  ? FontWeight.w700
                  : FontWeight.w400,
              color: !isBookable
                  ? AppColors.grey100
                  : (isSelected ? AppColors.white : AppColors.grey500),
            ),
          ),
        ),
      );
    });
  }
}

class _TimeSlotSection extends StatelessWidget {
  const _TimeSlotSection({
    required this.period,
    required this.slots,
    required this.controller,
  });

  final DayPeriod period;
  final List<TimeSlotModel> slots;
  final BookingController controller;

  static ({IconData icon, String label}) _headerFor(DayPeriod period) {
    switch (period) {
      case DayPeriod.morning:
        return (icon: Icons.wb_sunny_outlined, label: 'MORNING');
      case DayPeriod.afternoon:
        return (icon: Icons.wb_cloudy_outlined, label: 'AFTERNOON');
      case DayPeriod.evening:
        return (icon: Icons.nightlight_round, label: 'EVENING');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) return const SizedBox.shrink();

    final header = _headerFor(period);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(header.icon, size: 16, color: AppColors.primary700),
              const SizedBox(width: 6),
              Text(
                header.label,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary700,
                  letterSpacing: .5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.6,
            children: slots.map((slot) {
              return Obx(() {
                final isSelected =
                    controller.selectedTimeSlot.value == slot.time;
                return _TimeSlotChip(
                  slot: slot,
                  isSelected: isSelected,
                  onTap: () => controller.selectTimeSlot(slot.time),
                );
              });
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TimeSlotChip extends StatelessWidget {
  const _TimeSlotChip({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  final TimeSlotModel slot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: slot.isAvailable ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary700 : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary700 : AppColors.neutral200,
          ),
        ),
        child: Text(
          slot.time,
          style: GoogleFonts.roboto(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: !slot.isAvailable
                ? AppColors.grey100
                : (isSelected ? AppColors.white : AppColors.grey500),
            decoration: !slot.isAvailable ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}
