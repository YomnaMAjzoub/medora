
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/theme/app_theme.dart';

class CustomFormField extends StatelessWidget {
  const CustomFormField({
    required this.width,
    required this.height,
    required this.hint,
    required this.inputAction,
     this.keyboard,
    this.label,
    this.prefix,
    this.prefixConstraints,
    this.contentpadding,
    required this.border,
    required this.focused,
    required this.enabled,
    required this.obscuretext,
    this.suffix,
    this.maxLines,
    this.controller,
    this.enable,
    this.readOnly,
    super.key,
  });

  final TextEditingController? controller;
  final bool? enable;
  final double width;
  final double height;
  final TextInputType? keyboard;
  final TextInputAction inputAction;
  final int? maxLines;
  final Widget? prefix;
  final String hint;
  final Widget? label;
  final Widget? suffix;
  final InputBorder border;
  final InputBorder focused;
  final InputBorder enabled;
  final bool obscuretext;
  final BoxConstraints? prefixConstraints;
  final EdgeInsetsGeometry? contentpadding;
  final bool? readOnly;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        textInputAction: inputAction,
        obscureText: obscuretext,
        readOnly: readOnly ?? false,
        hintLocales: [Locale('en', 'US'), Locale('ar', 'EG')],
        maxLines: obscuretext ? 1 : (maxLines ?? 1),

        decoration: InputDecoration(
          border: border,
          focusedBorder: focused,
          enabledBorder: enabled,
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: context.appColors.textHint,
          ),
          contentPadding: contentpadding,
          prefixIconConstraints: prefixConstraints,
          prefixIcon: prefix,
          suffixIcon: suffix,
          label: label,
        ),
      ),
    );
  }
}