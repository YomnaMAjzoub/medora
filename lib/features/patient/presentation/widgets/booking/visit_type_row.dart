import 'package:flutter/material.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/features/patient/data/models/appointment_model.dart';

/// Shows the three visit-type icons (home / clinic / online), dimming out
/// whichever ones a given doctor does not support.
class VisitTypeRow extends StatelessWidget {
  const VisitTypeRow({
    required this.supportedTypes,
    this.showLabels = false,
    super.key,
  });

  final List<VisitType> supportedTypes;
  final bool showLabels;

  static const _items = [
    (type: VisitType.home, icon: Icons.home_rounded, label: 'Home'),
    (
      type: VisitType.clinic,
      icon: Icons.medical_services_rounded,
      label: 'Clinic',
    ),
    (type: VisitType.online, icon: Icons.videocam_rounded, label: 'Online'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _items.map((item) {
        final isSupported = supportedTypes.contains(item.type);
        final color = isSupported ? AppColors.primary600 : AppColors.grey200;

        return Padding(
          padding: const EdgeInsets.only(right: 14),
          child: showLabels
              ? Row(
                  children: [
                    Icon(item.icon, size: 18, color: color),
                    const SizedBox(width: 4),
                    Text(
                      item.label,
                      style: TextStyle(fontSize: 11, color: color),
                    ),
                  ],
                )
              : Icon(item.icon, size: 20, color: color),
        );
      }).toList(),
    );
  }
}
