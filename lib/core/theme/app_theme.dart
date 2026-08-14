import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';

/// Semantic colors used across the app. Screens read them via
/// `context.appColors` (see [AppColorsExtension]) so light and dark
/// themes both work without hardcoded palette lookups.
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.inputFill,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.border,
    required this.shadow,
    required this.danger,
  });

  final Color background;
  final Color surface;
  final Color inputFill;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color border;
  final Color shadow;
  final Color danger;

  static const light = AppThemeColors(
    background: Color(0xFFF7F7F7),
    surface: Color(0xFFFFFFFF),
    inputFill: Color(0xFFF7F7F7),
    textPrimary: Color(0xFF333333),
    textSecondary: Color(0xFF767676),
    textHint: Color(0xFFA1A1A1),
    border: Color(0xFFD9DDE5),
    shadow: Color(0xFFD9DDE5),
    danger: Color(0xFFC62828),
  );

  static const dark = AppThemeColors(
    background: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    inputFill: Color(0xFF0B1220),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    textHint: Color(0xFF64748B),
    border: Color(0xFF334155),
    shadow: Color(0xFF000000),
    danger: Color(0xFFEF5350),
  );

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? inputFill,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? border,
    Color? shadow,
    Color? danger,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      inputFill: inputFill ?? this.inputFill,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

extension AppColorsExtension on BuildContext {
  AppThemeColors get appColors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.light;
}

class AppTheme {
  static ThemeData get light => _base(Brightness.light);

  static ThemeData get dark => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colors = isDark ? AppThemeColors.dark : AppThemeColors.light;
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primary700,
        onPrimary: Colors.white,
        secondary: AppColors.primary500,
        onSecondary: Colors.white,
        error: colors.danger,
        onError: Colors.white,
        surface: colors.surface,
        onSurface: colors.textPrimary,
      ),
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
        contentTextStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: colors.textSecondary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? colors.surface : AppColors.grey700,
        contentTextStyle: GoogleFonts.roboto(color: colors.textPrimary),
      ),
      dividerColor: colors.border,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary700,
        selectionColor: AppColors.primary500.withValues(alpha: 0.3),
        selectionHandleColor: AppColors.primary700,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inputFill,
      ),
    );
  }
}