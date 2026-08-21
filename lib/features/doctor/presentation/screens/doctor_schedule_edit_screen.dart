import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/doctor/business_layer/controller/doctor_controller.dart';
import 'package:medora_git/features/doctor/data/models/doctor_work_schedule_model.dart';

/// Edits one part of the doctor's schedule (working days / days off /
/// peak hours) depending on the `mode` argument.
class DoctorScheduleEditScreen extends StatefulWidget {
  const DoctorScheduleEditScreen({super.key});

  @override
  State<DoctorScheduleEditScreen> createState() =>
      _DoctorScheduleEditScreenState();
}

class _DoctorScheduleEditScreenState extends State<DoctorScheduleEditScreen> {
  static const _weekDays = [
    'saturday',
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
  ];

  late final String _mode = (Get.arguments as Map)['mode'] as String;
  late final List<DoctorWorkDayModel> _workingDays;
  late final Set<String> _daysOff;
  late final List<String> _peakHours;

  DoctorController get controller => Get.find<DoctorController>();

  @override
  void initState() {
    super.initState();
    final schedule = controller.schedule.value ?? const DoctorWorkScheduleModel(
      workingDays: [],
      daysOff: [],
      peakHours: [],
    );
    _workingDays = _initWorkingDays(schedule.workingDays);
    _daysOff = {...schedule.daysOff};
    _peakHours = [...schedule.peakHours];
  }

  List<DoctorWorkDayModel> _initWorkingDays(
    List<DoctorWorkDayModel> existing,
  ) {
    return [
      for (final key in _weekDays)
        _workDayFor(key, existing),
    ];
  }

  DoctorWorkDayModel _workDayFor(String key, List<DoctorWorkDayModel> existing) {
    final match = existing
        .where((d) => d.day.toLowerCase() == key.toLowerCase())
        .firstOrNullSafe();
    if (match != null) return match;
    return DoctorWorkDayModel(
      day: _displayName(key),
      startTime: '08:00',
      endTime: '17:00',
    );
  }

  String _displayName(String key) => key.tr();

  TimeOfDay _parse(String value) {
    final parts = value.split(':');
    return TimeOfDay(
      hour: parts.isNotEmpty ? int.tryParse(parts[0]) ?? 8 : 8,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
  }

  String _format(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(
    DoctorWorkDayModel day,
    bool isStart,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? _parse(day.startTime)
          : _parse(day.endTime),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: context.appColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        day.startTime = _format(picked);
      } else {
        day.endTime = _format(picked);
      }
    });
  }

  Future<void> _addPeakHour() async {
    final start = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: context.appColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (start == null) return;
    if (!mounted) return;
    final end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: start.hour + 1, minute: start.minute),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: context.appColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (end == null) return;
    setState(() {
      _peakHours.add('${_format(start)} - ${_format(end)}');
    });
  }

  void _save() {
    controller.updateSchedule(
      DoctorWorkScheduleModel(
        workingDays: _workingDays,
        daysOff: _daysOff.toList(),
        peakHours: _peakHours,
      ),
    );
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_mode) {
      'daysOff' => 'days_off'.tr(),
      'peakHours' => 'peak_hours'.tr(),
      _ => 'working_days'.tr(),
    };
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: context.appColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            if (_mode == 'workingDays') _workingDaysEditor(context)
            else if (_mode == 'daysOff') _daysOffEditor(context)
            else _peakHoursEditor(context),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.primaryContainer,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                'save'.tr(),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _workingDaysEditor(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.appColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < _workingDays.length; i++) ...[
            if (i > 0) const Divider(height: 20),
            _workDayRow(context, _workingDays[i]),
          ],
        ],
      ),
    );
  }

  Widget _workDayRow(BuildContext context, DoctorWorkDayModel day) {
    final active = day.startTime != 'off' && day.endTime != 'off';
    return Row(
      children: [
        Expanded(
          child: Text(
            day.day,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.appColors.textPrimary,
            ),
          ),
        ),
        if (active)
          GestureDetector(
            onTap: () => _pickTime(day, true),
            child: Text(
              day.startTime,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.appColors.primary,
              ),
            ),
          ),
        if (active)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '-',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: context.appColors.textSecondary,
              ),
            ),
          ),
        if (active)
          GestureDetector(
            onTap: () => _pickTime(day, false),
            child: Text(
              day.endTime,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.appColors.primary,
              ),
            ),
          ),
        Switch(
          activeTrackColor: context.appColors.primary,
          value: active,
          onChanged: (value) => setState(() {
            if (value) {
              day.startTime = '08:00';
              day.endTime = '17:00';
            } else {
              day.startTime = 'off';
              day.endTime = 'off';
            }
          }),
        ),
      ],
    );
  }

  Widget _daysOffEditor(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.appColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (final key in _weekDays)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _displayName(key),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                  ),
                  Switch(
                    activeTrackColor: context.appColors.danger,
                    value: _daysOff.contains(_displayName(key)),
                    onChanged: (value) => setState(() {
                      if (value) {
                        _daysOff.add(_displayName(key));
                      } else {
                        _daysOff.remove(_displayName(key));
                      }
                    }),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _peakHoursEditor(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.appColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_peakHours.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'no_peak_hours'.tr(),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: context.appColors.textSecondary,
                ),
              ),
            )
          else
            for (final range in _peakHours)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 18,
                      color: context.appColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        range,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'delete'.tr(),
                      onPressed: () => setState(
                        () => _peakHours.remove(range),
                      ),
                      icon: Icon(
                        Icons.close_rounded,
                        color: context.appColors.danger,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: _addPeakHour,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary900,
              side: BorderSide(color: context.appColors.primary.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(
              'add_peak_hour'.tr(),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNullSafe<T> on Iterable<T> {
  T? firstOrNullSafe() {
    for (final element in this) {
      return element;
    }
    return null;
  }
}