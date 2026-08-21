import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/patient/business_layer/controller/booking_controller.dart';
import 'package:medora_git/features/patient/business_layer/controller/doctor_calendar_controller.dart';
import 'package:medora_git/features/patient/data/models/doctor_calendar_slot_model.dart';

/// Step 4 of the booking flow: pick a day from the month calendar, then a
/// slot. Slots come from the real availability API via
/// [DoctorCalendarController]; the picked date/time is mirrored onto
/// [BookingController] so later steps (and payment) can use it.
class SelectTimeStep extends StatefulWidget {
  const SelectTimeStep({super.key});

  @override
  State<SelectTimeStep> createState() => _SelectTimeStepState();
}

class _SelectTimeStepState extends State<SelectTimeStep> {
  late final BookingController bookingController;
  late final DoctorCalendarController calendarController;
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    bookingController = Get.find<BookingController>();
    calendarController = Get.isRegistered<DoctorCalendarController>()
        ? Get.find<DoctorCalendarController>()
        : Get.put(DoctorCalendarController());

    final doctorId =
        int.tryParse(bookingController.selectedDoctor.value?.id ?? '');
    if (doctorId != null) {
      calendarController.loadForDoctor(doctorId);
    }

    final initialDate =
        bookingController.selectedDate.value ?? DateTime.now();
    _visibleMonth = DateTime(initialDate.year, initialDate.month);
    if (bookingController.selectedDate.value == null) {
      bookingController.selectDate(initialDate);
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

  void _handleDayTap(DateTime date) {
    final current = calendarController.selectedDate.value;
    if (current.year == date.year &&
        current.month == date.month &&
        current.day == date.day) {
      return;
    }
    bookingController.selectDate(date);
    calendarController.selectCalendarDate(date);
  }

  void _handleSlotTap(CalendarSlotModel slot) {
    calendarController.selectSlot(slot);
    if (calendarController.selectedSlot.value == slot) {
      bookingController.selectTimeSlot(slot.time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'select_date_time'.tr(),
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'choose_day_time_hint'.tr(),
            style: GoogleFonts.inter(
              fontSize: 13,
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          _MonthCalendar(
            visibleMonth: _visibleMonth,
            onChangeMonth: _changeMonth,
            onDayTap: _handleDayTap,
            calendarController: calendarController,
          ),
          const SizedBox(height: 24),
          Text(
            'available_time'.tr(),
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Obx(
            () => Text(
              DateFormat('EEEE, MMMM d').format(
                calendarController.selectedDate.value,
              ),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: context.appColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Obx(() {
            if (calendarController.errorMessage.value.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'load_availability_error'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ),
              );
            }
            if (calendarController.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final allSlots = calendarController.slots;
            if (allSlots.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'no_slots'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ),
              );
            }
            final morning = allSlots
                .where((s) => int.parse(s.time.split(':').first) < 12)
                .toList();
            final afternoon = allSlots
                .where((s) {
                  final hour = int.parse(s.time.split(':').first);
                  return hour >= 12 && hour < 17;
                })
                .toList();
            final evening = allSlots
                .where((s) => int.parse(s.time.split(':').first) >= 17)
                .toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (morning.isNotEmpty)
                  _SlotSection(
                    label: 'morning'.tr(),
                    icon: Icons.wb_sunny_outlined,
                    slots: morning,
                    onSlotTap: _handleSlotTap,
                    calendarController: calendarController,
                  ),
                if (afternoon.isNotEmpty)
                  _SlotSection(
                    label: 'afternoon'.tr(),
                    icon: Icons.wb_cloudy_outlined,
                    slots: afternoon,
                    onSlotTap: _handleSlotTap,
                    calendarController: calendarController,
                  ),
                if (evening.isNotEmpty)
                  _SlotSection(
                    label: 'evening'.tr(),
                    icon: Icons.nights_stay_outlined,
                    slots: evening,
                    onSlotTap: _handleSlotTap,
                    calendarController: calendarController,
                  ),
              ],
            );
          }),
          const SizedBox(height: 8),
          Obx(
            () => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    calendarController.selectedSlot.value != null &&
                        !calendarController.isLoading.value
                    ? bookingController.confirmDateTime
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appColors.primaryContainer,
                  disabledBackgroundColor: context.appColors.border,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'continue_payment'.tr(),
                  style: GoogleFonts.inter(
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

class _SlotSection extends StatelessWidget {
  const _SlotSection({
    required this.label,
    required this.icon,
    required this.slots,
    required this.onSlotTap,
    required this.calendarController,
  });

  final String label;
  final IconData icon;
  final List<CalendarSlotModel> slots;
  final ValueChanged<CalendarSlotModel> onSlotTap;
  final DoctorCalendarController calendarController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Icon(icon, size: 14, color: context.appColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: slots.map((slot) => _SlotChip(
            slot: slot,
            calendarController: calendarController,
            onTap: () => onSlotTap(slot),
          )).toList(),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.calendarController,
    required this.onTap,
  });

  final CalendarSlotModel slot;
  final DoctorCalendarController calendarController;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (calendarController.isSlotBookable(slot)) onTap();
      },
      borderRadius: BorderRadius.circular(10),
      child: Obx(
        () {
          final isBookable = calendarController.isSlotBookable(slot);
          final isSelected =
              calendarController.selectedSlot.value?.fullDate == slot.fullDate;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.appColors.primary
                  : context.appColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? context.appColors.primary
                    : context.appColors.border,
              ),
            ),
            child: Text(
              slot.time,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: !isBookable
                    ? context.appColors.border
                    : (isSelected ? AppColors.white : context.appColors.textPrimary),
                decoration: !isBookable ? TextDecoration.lineThrough : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.visibleMonth,
    required this.onChangeMonth,
    required this.onDayTap,
    required this.calendarController,
  });

  final DateTime visibleMonth;
  final ValueChanged<int> onChangeMonth;
  final ValueChanged<DateTime> onDayTap;
  final DoctorCalendarController calendarController;

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
    final nextMonthStart = DateTime(
      today.year,
      today.month + 2,
    );
    final canGoPrev = visibleMonth.isAfter(currentMonthStart);
    final canGoNext = DateTime(
      visibleMonth.year,
      visibleMonth.month,
    ).isBefore(nextMonthStart);

    final cells = <Widget>[
      for (var i = 0; i < leadingBlanks; i++) const SizedBox(),
      for (var day = 1; day <= daysInMonth; day++)
        _DayCell(
          date: DateTime(visibleMonth.year, visibleMonth.month, day),
          onTap: onDayTap,
          calendarController: calendarController,
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: .5),
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
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
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
                      color: canGoPrev
                          ? context.appColors.textPrimary
                          : context.appColors.border,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: canGoNext ? () => onChangeMonth(1) : null,
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      color: canGoNext
                          ? context.appColors.textPrimary
                          : context.appColors.border,
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
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.textSecondary,
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
  const _DayCell({
    required this.date,
    required this.onTap,
    required this.calendarController,
  });

  final DateTime date;
  final ValueChanged<DateTime> onTap;
  final DoctorCalendarController calendarController;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final isToday = _isSameDay(DateTime.now(), date);
    final todayMidnight = DateTime.now();
    final isPast = date.isBefore(
      DateTime(todayMidnight.year, todayMidnight.month, todayMidnight.day),
    );

    return Obx(() {
      final isSelected = _isSameDay(
        calendarController.selectedDate.value,
        date,
      );

      return InkWell(
        onTap: isPast ? null : () => onTap(date),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? context.appColors.primary
                : (isToday ? AppColors.secondary100 : null),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${date.day}',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isSelected || isToday
                  ? FontWeight.w700
                  : FontWeight.w400,
              color: isSelected
                  ? AppColors.white
                  : (isPast
                      ? context.appColors.border
                      : context.appColors.textPrimary),
            ),
          ),
        ),
      );
    });
  }
}
