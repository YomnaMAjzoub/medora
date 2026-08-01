import 'package:flutter/material.dart';


class SpecialtyModel {
  const SpecialtyModel({required this.id, required this.name, required this.icon});

  final String id;
  final String name;
  final IconData icon;

  
  factory SpecialtyModel.fromJson(Map<String, dynamic> json) {
    return SpecialtyModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      icon: _iconFromKey(json['icon'] as String?),
    );
  }

  static IconData _iconFromKey(String? key) {
    switch (key) {
      case 'cardiology':
        return Icons.favorite_rounded;
      case 'dentistry':
        return Icons.medical_services_rounded;
      case 'dermatology':
        return Icons.face_retouching_natural_rounded;
      case 'pediatrics':
        return Icons.child_care_rounded;
      case 'orthopedics':
        return Icons.accessibility_new_rounded;
      case 'ophthalmology':
        return Icons.visibility_rounded;
      default:
        return Icons.local_hospital_rounded;
    }
  }
}
