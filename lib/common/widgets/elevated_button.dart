
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';


class CustomElevated extends StatelessWidget {
  const CustomElevated({
    required this.text,
    required this.height,
    required this.width,
    required this.onPressed,
     this.color,
    required this.background,
    required this.textColor,
    super.key,
  });
  final double width;
  final double height;
  final void Function()? onPressed;
  final Color? color;
  final Color textColor;
  final Color background;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1,color: AppColors.primary900),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
