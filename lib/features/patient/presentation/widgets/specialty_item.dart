import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/patient/data/models/specialty_model.dart';

class SpecialtyItem extends StatelessWidget {
  const SpecialtyItem({
    required this.specialty,
    required this.onTap,
    super.key,
  });

  final SpecialtyModel specialty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
child: Container(
        width: double.infinity,
        height: 30,
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.appColors.shadow.withValues(alpha: 0.5),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            SizedBox(
              width: 20,
              child: Icon(
                specialty.icon,
                size: 20,
                color: context.appColors.primary,
              ),
            ),

Flexible(
              child: Text(
                specialty.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.appColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
