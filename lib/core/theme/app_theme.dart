import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/const/app_radius.dart';

/// Semantic colors used across the app. Screens read them via
/// `context.appColors` (see [AppColorsExtension]) so light and dark
/// themes both work without hardcoded palette lookups.
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.inputFill,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.border,
    required this.outline,
    required this.shadow,
    required this.danger,
    required this.success,
    required this.warning,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
  });

  final Color background;
  final Color surface;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color inputFill;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color border;
  final Color outline;
  final Color shadow;
  final Color danger;
  final Color success;
  final Color warning;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  static const light = AppThemeColors(
    background: Color(0xFFF7F7F7),
    surface: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFAFAFA),
    surfaceContainer: Color(0xFFFFFFFF),
    surfaceContainerHigh: Color(0xFFF1F5F9),
    surfaceContainerHighest: Color(0xFFE2E8F0),
    inputFill: Color(0xFFF7F7F7),
    textPrimary: Color(0xFF333333),
    textSecondary: Color(0xFF767676),
    textHint: Color(0xFFA1A1A1),
    border: Color(0xFFD9DDE5),
    outline: Color(0xFFB0B0B0),
    shadow: Color(0xFFD9DDE5),
    danger: Color(0xFFC62828),
    success: Color(0xFF2E7D32),
    warning: Color(0xFFB25E00),
    primary: AppColors.primary700,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF3366FF),
    onPrimaryContainer: Colors.white,
  );

  static const dark = AppThemeColors(
    background: AppColors.surface,
    surface: AppColors.surfaceContainer,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
    inputFill: AppColors.surfaceContainerLow,
    textPrimary: AppColors.onSurface,
    textSecondary: AppColors.onSurfaceVariant,
    textHint: AppColors.outline,
    border: AppColors.outlineVariant,
    outline: AppColors.outline,
    shadow: Color(0xFF000000),
    danger: AppColors.error,
    success: AppColors.success,
    warning: AppColors.warning,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
  );

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceContainerLow,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
    Color? inputFill,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? border,
    Color? outline,
    Color? shadow,
    Color? danger,
    Color? success,
    Color? warning,
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
      inputFill: inputFill ?? this.inputFill,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      border: border ?? this.border,
      outline: outline ?? this.outline,
      shadow: shadow ?? this.shadow,
      danger: danger ?? this.danger,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceContainerLow:
          Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t)!,
      surfaceContainer:
          Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      surfaceContainerHigh:
          Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t)!,
      surfaceContainerHighest: Color.lerp(
          surfaceContainerHighest, other.surfaceContainerHighest, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      border: Color.lerp(border, other.border, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      onPrimaryContainer:
          Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t)!,
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
    final scheme = isDark ? _darkScheme : _lightScheme;
    final baseText = GoogleFonts.interTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );
    final textTheme = baseText
        .copyWith(
          headlineLarge: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            height: 40 / 32,
            letterSpacing: -0.02 * 32,
            color: scheme.onSurface,
          ),
          headlineMedium: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            height: 32 / 24,
            letterSpacing: -0.01 * 24,
            color: scheme.onSurface,
          ),
          titleLarge: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 28 / 20,
            color: scheme.onSurface,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 24 / 16,
            color: scheme.onSurface,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 20 / 14,
            color: scheme.onSurface,
          ),
          bodySmall: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 16 / 12,
            color: scheme.onSurfaceVariant,
          ),
          labelLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 20 / 14,
            color: scheme.onSurface,
          ),
          labelMedium: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 16 / 12,
            letterSpacing: 0.05 * 12,
            color: scheme.onSurfaceVariant,
          ),
          labelSmall: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 16 / 11,
            color: scheme.onSurfaceVariant,
          ),
        )
        .apply(fontFamily: 'Inter', fontFamilyFallback: const ['Roboto']);

    const radius = AppRadius.button;

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      colorScheme: scheme,
      extensions: [colors],
      textTheme: textTheme,
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.modal),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: colors.textSecondary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: colors.surfaceContainerHigh,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.modal)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? colors.surfaceContainerHigh : AppColors.grey700,
        contentTextStyle: GoogleFonts.inter(color: colors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerColor: colors.border.withValues(alpha: 0.05),
      dividerTheme: DividerThemeData(
        color: colors.border.withValues(alpha: 0.05),
        thickness: 1,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionColor: scheme.primary.withValues(alpha: 0.3),
        selectionHandleColor: scheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark
              ? colors.primaryContainer
              : AppColors.primary700,
          foregroundColor: colors.onPrimaryContainer,
          disabledBackgroundColor: colors.surfaceContainerHighest,
          disabledForegroundColor: colors.textHint,
          minimumSize: const Size(48, 48),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primaryContainer,
          side: BorderSide(color: colors.primaryContainer, width: 1),
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.textSecondary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inputFill,
        hintStyle: GoogleFonts.inter(color: colors.textHint),
        labelStyle: GoogleFonts.inter(color: colors.textSecondary),
        prefixIconColor: colors.textHint,
        suffixIconColor: colors.textHint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(
            color: colors.border.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(
            color: colors.border.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: colors.primaryContainer, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: scheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(
            color: Colors.white.withValues(alpha: isDark ? 0.05 : 0),
            width: 1,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceContainer,
        selectedColor: colors.primaryContainer,
        side: BorderSide(color: colors.border.withValues(alpha: 0.15)),
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.textSecondary,
        textColor: colors.textPrimary,
        titleTextStyle: textTheme.bodyLarge,
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(
          color: colors.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.modal),
        ),
        textStyle: textTheme.bodyMedium,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.primaryContainer.withValues(alpha: 0.85),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.badge + 4),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colors.onPrimaryContainer
                : colors.textSecondary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? colors.textPrimary
                : colors.textSecondary,
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: colors.surfaceContainerHighest,
        circularTrackColor: colors.surfaceContainerHighest,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.onPrimaryContainer
              : colors.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primaryContainer
              : colors.surfaceContainerHighest,
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primaryContainer
              : colors.outline,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primaryContainer
              : Colors.transparent,
        ),
        side: BorderSide(color: colors.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.primaryContainer,
        inactiveTrackColor: colors.surfaceContainerHighest,
        thumbColor: colors.primaryContainer,
        overlayColor: colors.primaryContainer.withValues(alpha: 0.12),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: colors.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: colors.primaryContainer,
        headerForegroundColor: colors.onPrimaryContainer,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: colors.surfaceContainerHigh,
        dialBackgroundColor: colors.surfaceContainer,
        dialHandColor: colors.primaryContainer,
        hourMinuteColor: colors.surfaceContainerHigh,
        hourMinuteTextColor: colors.textPrimary,
        entryModeIconColor: colors.textSecondary,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.badge),
        ),
        textStyle: textTheme.bodySmall,
      ),
    );
  }
}

const ColorScheme _lightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.primary700,
  onPrimary: Colors.white,
  primaryContainer: AppColors.primaryContainer,
  onPrimaryContainer: Colors.white,
  secondary: AppColors.primary500,
  onSecondary: Colors.white,
  secondaryContainer: AppColors.secondary100,
  onSecondaryContainer: AppColors.secondary900,
  tertiary: AppColors.tertiary600,
  onTertiary: AppColors.tertiary900,
  tertiaryContainer: AppColors.tertiary100,
  onTertiaryContainer: AppColors.tertiary800,
  error: Color(0xFFC62828),
  onError: Colors.white,
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF690005),
  surface: Colors.white,
  onSurface: Color(0xFF333333),
  surfaceContainerLowest: Colors.white,
  surfaceContainerLow: Color(0xFFFAFAFA),
  surfaceContainer: Colors.white,
  surfaceContainerHigh: Color(0xFFF1F5F9),
  surfaceContainerHighest: Color(0xFFE2E8F0),
  onSurfaceVariant: Color(0xFF767676),
  outline: Color(0xFFB0B0B0),
  outlineVariant: Color(0xFFD9DDE5),
  inverseSurface: Color(0xFF333333),
  onInverseSurface: Colors.white,
  inversePrimary: AppColors.primary500,
  surfaceTint: AppColors.primary700,
  shadow: Color(0xFFD9DDE5),
);

const ColorScheme _darkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: AppColors.primary,
  onPrimary: AppColors.onPrimary,
  primaryContainer: AppColors.primaryContainer,
  onPrimaryContainer: AppColors.onPrimaryContainer,
  secondary: AppColors.secondary,
  onSecondary: AppColors.onSecondary,
  secondaryContainer: AppColors.secondaryContainer,
  onSecondaryContainer: AppColors.onSecondaryContainer,
  tertiary: AppColors.tertiary,
  onTertiary: AppColors.onTertiary,
  tertiaryContainer: AppColors.tertiaryContainer,
  onTertiaryContainer: AppColors.onTertiaryContainer,
  error: AppColors.error,
  onError: AppColors.onError,
  errorContainer: AppColors.errorContainer,
  onErrorContainer: AppColors.onErrorContainer,
  surface: AppColors.surface,
  onSurface: AppColors.onSurface,
  surfaceContainerLowest: AppColors.surfaceContainerLowest,
  surfaceContainerLow: AppColors.surfaceContainerLow,
  surfaceContainer: AppColors.surfaceContainer,
  surfaceContainerHigh: AppColors.surfaceContainerHigh,
  surfaceContainerHighest: AppColors.surfaceContainerHighest,
  onSurfaceVariant: AppColors.onSurfaceVariant,
  outline: AppColors.outline,
  outlineVariant: AppColors.outlineVariant,
  inverseSurface: AppColors.inverseSurface,
  onInverseSurface: AppColors.inverseOnSurface,
  inversePrimary: AppColors.inversePrimary,
  surfaceTint: AppColors.surfaceTint,
  shadow: Colors.black,
  primaryFixed: AppColors.primaryFixed,
  primaryFixedDim: AppColors.primaryFixedDim,
  onPrimaryFixed: AppColors.onPrimaryFixed,
  onPrimaryFixedVariant: AppColors.onPrimaryFixedVariant,
  secondaryFixed: AppColors.secondaryFixed,
  secondaryFixedDim: AppColors.secondaryFixedDim,
  onSecondaryFixed: AppColors.onSecondaryFixed,
  onSecondaryFixedVariant: AppColors.onSecondaryFixedVariant,
  tertiaryFixed: AppColors.tertiaryFixed,
  tertiaryFixedDim: AppColors.tertiaryFixedDim,
  onTertiaryFixed: AppColors.onTertiaryFixed,
  onTertiaryFixedVariant: AppColors.onTertiaryFixedVariant,
);