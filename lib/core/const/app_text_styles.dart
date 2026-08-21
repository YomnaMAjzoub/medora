import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central typography scale (Inter).
///
/// Body text defaults to [bodyMd] (14px) for information-dense screens
/// (lists, tables, appointment cards). Pass a [Color] explicitly when the
/// style needs to sit on a colored surface; otherwise the widget's default
/// text color applies.
class AppTextStyles {
  AppTextStyles._();

  /// 32/600, line height 40, -0.02em — page hero titles.
  static TextStyle headlineLg({Color? color}) => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 40 / 32,
        letterSpacing: -0.02 * 32,
        color: color,
      );

  /// 24/600, line height 32, -0.02em — mobile hero titles.
  static TextStyle headlineLgMobile({Color? color}) => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        letterSpacing: -0.02 * 24,
        color: color,
      );

  /// 24/500, line height 32, -0.01em — section headlines.
  static TextStyle headlineMd({Color? color}) => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 32 / 24,
        letterSpacing: -0.01 * 24,
        color: color,
      );

  /// 16/400, line height 24 — body copy (secondary density).
  static TextStyle bodyLg({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: color,
      );

  /// 14/400, line height 20 — default body text for UI components.
  static TextStyle bodyMd({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: color,
      );

  /// 12/600, line height 16, +0.05em — labels / metadata.
  static TextStyle labelMd({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        letterSpacing: 0.05 * 12,
        color: color,
      );
}