/// 8px base rhythm spacing scale. Use [xs]/[base] for spacing between
/// closely related internal elements (icon + label), and [md]/[lg] for
/// spacing between distinct sections.
class AppSpacing {
  AppSpacing._();

  /// 4px — smallest gap (icon/label pairs, chip padding).
  static const double xs = 4;

  /// 8px — base rhythm unit.
  static const double base = 8;

  /// 12px — small padding between related controls.
  static const double sm = 12;

  /// 16px — standard section gap / gutter.
  static const double md = 16;

  /// 24px — large gap between distinct sections.
  static const double lg = 24;

  /// 32px — extra large gap (page-level sections).
  static const double xl = 32;

  /// 16px — page gutter (horizontal padding).
  static const double gutter = 16;

  /// 16px — mobile screen margin.
  static const double margin = 16;
}