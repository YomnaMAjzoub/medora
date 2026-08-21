import 'package:flutter/cupertino.dart';

class AppColors {
  //Primary Colors
  static const Color mainScreen = Color(0xFFF7F7F7);
  static const primary900 = Color(0xff001B48);
  static const primary800 = Color(0xff003060);
  static const primary700 = Color(0xff00457A);
  static const primary600 = Color(0xff005B94);
  static const primary500 = Color(0xff0070AE);
  static const primary400 = Color(0xff018ABE);
  static const primary300 = Color(0xff33A3D1);
  static const primary200 = Color(0xff66BDD9);
  static const primary100 = Color(0xff99D6E2);
  static const primary50 = Color(0xffCCEEF2);

  //Secondary Colors
  static const secondary900 = Color(0xff018ABE);
  static const secondary800 = Color(0xff1FA0C9);
  static const secondary700 = Color(0xff3FB6D4);
  static const secondary600 = Color(0xff5FCDDF);
  static const secondary500 = Color(0xff7FE3EA);
  static const secondary400 = Color(0xff97CADB);
  static const secondary300 = Color(0xffB0D8E4);
  static const secondary200 = Color(0xffC9E6ED);
  static const secondary100 = Color(0xffE2F3F6);
  static const secondary50 = Color(0xffF8FAFC);

  //Tertiary Colors
  static const tertiary900 = Color(0xffA8D3E1);
  static const tertiary800 = Color(0xffB9DCE7);
  static const tertiary700 = Color(0xffCAE5ED);
  static const tertiary600 = Color(0xffDBEEF3);
  static const tertiary500 = Color(0xffEAF5F8);
  static const tertiary400 = Color(0xffF0F9FB);
  static const tertiary300 = Color(0xffF5FBFD);
  static const tertiary200 = Color(0xffF8FCFE);
  static const tertiary100 = Color(0xffFAFEFF);

  //Neutral Colors
  static const neutral50 = Color(0xffF8FAFC);
  static const neutral100 = Color(0xffF1F5F9);
  static const neutral200 = Color(0xffE2E8F0);
  static const neutral300 = Color(0xffCBD5E1);
  static const neutral400 = Color(0xff94A3B8);
  static const neutral500 = Color(0xff64748B);
  static const neutral600 = Color(0xff475569);
  static const neutral700 = Color(0xff334155);
  static const neutral800 = Color(0xff1E293B);
  static const neutral900 = Color(0xff0F172A);

  static const Color white = Color(0xffFFFFFF);
  static const Color yellow = Color(0xffFEFAED);
  static const Color black = Color(0xff000000);
  static const Color grey50 = Color(0xffebebeb);
  static const Color grey100 = Color(0xffc0c0c0);
  static const Color grey200 = Color(0xffa1a1a1);
  static const Color grey300 = Color(0xff767676);
  static const Color grey400 = Color(0xff5c5c5c);
  static const Color grey500 = Color(0xff333333);
  static const Color grey600 = Color(0xff2e2e2e);
  static const Color grey700 = Color(0xff242424);
  static const Color grey800 = Color(0xff1c1c1c);
  static const Color grey900 = Color(0xff151515);
  static const Color dark = Color(0xff717171);
  static const Color main = Color(0xff010A1C);
  static const Color main10 = Color(0xff262626);
  static const Color divider = Color(0xffD9D9D9);
  static const Color red = Color(0xffD85A5A);

  //shadow colors
  static const Color shadowb = Color(0xffD9DDE5);
  static const Color shadowb1 = Color(0xffB0B0B0);

  // =========================================================================
  // Dark theme tokens (Material 3 dark scheme) — source of truth for dark UI.
  // Screens read these via `Theme.of(context).colorScheme` / `context.appColors`;
  // the constants below are for direct use where a scheme token doesn't cover
  // the case. When in doubt, prefer the theme extension over these constants.
  // =========================================================================

  // Surfaces
  static const Color surface = Color(0xFF11131C);
  static const Color surfaceDim = Color(0xFF11131C);
  static const Color surfaceBright = Color(0xFF373942);
  static const Color surfaceContainerLowest = Color(0xFF0C0E16);
  static const Color surfaceContainerLow = Color(0xFF191B24);
  static const Color surfaceContainer = Color(0xFF1D1F28);
  static const Color surfaceContainerHigh = Color(0xFF282933);
  static const Color surfaceContainerHighest = Color(0xFF33343E);

  // On-surface text/icons
  static const Color onSurface = Color(0xFFE2E1EE);
  static const Color onSurfaceVariant = Color(0xFFC3C5D8);

  // Inverse surfaces
  static const Color inverseSurface = Color(0xFFE2E1EE);
  static const Color inverseOnSurface = Color(0xFF2E3039);

  // Outlines / borders
  static const Color outline = Color(0xFF8D90A1);
  static const Color outlineVariant = Color(0xFF434655);

  // Tint
  static const Color surfaceTint = Color(0xFFB7C4FF);

  // Primary
  static const Color primary = Color(0xFFB7C4FF);
  static const Color onPrimary = Color(0xFF002680);
  static const Color primaryContainer = Color(0xFF3366FF);
  static const Color onPrimaryContainer = Color(0xFFFDFBFF);
  static const Color inversePrimary = Color(0xFF054DE9);

  // Secondary
  static const Color secondary = Color(0xFFB1C6FC);
  static const Color onSecondary = Color(0xFF182F5C);
  static const Color secondaryContainer = Color(0xFF334876);
  static const Color onSecondaryContainer = Color(0xFFA3B8ED);

  // Tertiary
  static const Color tertiary = Color(0xFFFFB598);
  static const Color onTertiary = Color(0xFF591D00);
  static const Color tertiaryContainer = Color(0xFFC94B00);
  static const Color onTertiaryContainer = Color(0xFFFFFAFF);

  // Error
  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // Fixed tones
  static const Color primaryFixed = Color(0xFFDCE1FF);
  static const Color primaryFixedDim = Color(0xFFB7C4FF);
  static const Color onPrimaryFixed = Color(0xFF001551);
  static const Color onPrimaryFixedVariant = Color(0xFF0039B4);
  static const Color secondaryFixed = Color(0xFFD9E2FF);
  static const Color secondaryFixedDim = Color(0xFFB1C6FC);
  static const Color onSecondaryFixed = Color(0xFF001944);
  static const Color onSecondaryFixedVariant = Color(0xFF314674);
  static const Color tertiaryFixed = Color(0xFFFFDBCE);
  static const Color tertiaryFixedDim = Color(0xFFFFB598);
  static const Color onTertiaryFixed = Color(0xFF370E00);
  static const Color onTertiaryFixedVariant = Color(0xFF7E2C00);

  // Background
  static const Color background = Color(0xFF11131C);
  static const Color onBackground = Color(0xFFE2E1EE);
  static const Color surfaceVariant = Color(0xFF33343E);

  // Status semantics (used by chips/badges at ~15% opacity + solid text)
  static const Color success = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFFFB800);
  static const Color info = Color(0xFFB7C4FF);
}
