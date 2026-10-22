import 'package:flutter/cupertino.dart';

/// The app's colours, each with a light and a dark value, so dark mode and
/// Increase Contrast follow the iPhone's settings as the system colours do.
///
/// A colour carries one meaning, everywhere:
/// - [tint], teal, is the student: readiness, what they hold, and the actions.
/// - [demand], indigo, is the job market: how often postings ask for a skill.
/// - [caution], orange, is a caveat about the figures.
/// - [credit], green, is degree credit and a gain.
abstract final class AppColors {
  static const tint = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFF0A7C78),
    darkColor: Color(0xFF3FD0C4),
    highContrastColor: Color(0xFF05605C),
    darkHighContrastColor: Color(0xFF74E6DC),
  );
  /// Text and glyphs on a teal fill: white on the deep teal of light mode,
  /// black on the bright teal of dark mode, so both stay legible.
  static const onTint = CupertinoDynamicColor.withBrightness(
    color: CupertinoColors.white,
    darkColor: CupertinoColors.black,
  );

  static const demand = CupertinoColors.systemIndigo;
  static const caution = CupertinoColors.systemOrange;
  static const credit = CupertinoColors.systemGreen;
  static const danger = CupertinoColors.systemRed;

  static const background = CupertinoColors.systemGroupedBackground;
  static const surface = CupertinoColors.secondarySystemGroupedBackground;
  static const separator = CupertinoColors.separator;
  static const label = CupertinoColors.label;
  static const secondaryLabel = CupertinoColors.secondaryLabel;
  static const tertiaryLabel = CupertinoColors.tertiaryLabel;
  static const fill = CupertinoColors.tertiarySystemFill;
}

/// Corner radii by what a shape is: a card, a control inside it, a tag.
abstract final class AppRadius {
  static const card = BorderRadius.all(Radius.circular(12));
  static const button = BorderRadius.all(Radius.circular(14));
  static const tag = BorderRadius.all(Radius.circular(8));
}

/// The inset of grouped content from the screen edge, as in Settings.
const kScreenInset = 16.0;

bool _isArabic(Locale locale) => locale.languageCode == 'ar';

/// Apple's iOS type ramp at the default text size, in the system face: SF Pro,
/// and SF Arabic for Arabic, on an iPhone. Colours are resolved here, so text
/// follows dark mode.
///
/// Arabic is set without tracking: letter-spacing pulls joined letters apart.
class AppType {
  AppType.of(BuildContext context)
      : _base = CupertinoTheme.of(context).textTheme.textStyle,
        _secondary = CupertinoColors.secondaryLabel.resolveFrom(context),
        _arabic = _isArabic(Localizations.localeOf(context));

  final TextStyle _base;
  final Color _secondary;
  final bool _arabic;

  TextStyle _style(double size, FontWeight weight, double tracking, {Color? color}) =>
      _base.copyWith(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: _arabic ? 0 : tracking,
        color: color,
      );

  /// The one figure a screen leads with: a readiness or coverage share.
  TextStyle get hero => _style(54, FontWeight.w700, -1.2).copyWith(height: 1.05);

  /// A figure beside another, or in a narrow column.
  TextStyle get figure => _style(34, FontWeight.w700, 0.37).copyWith(height: 1.1);

  TextStyle get title2 => _style(22, FontWeight.w700, -0.26);
  TextStyle get title3 => _style(20, FontWeight.w600, -0.45);
  TextStyle get headline => _style(17, FontWeight.w600, -0.43);
  TextStyle get body => _style(17, FontWeight.w400, -0.43);
  TextStyle get callout => _style(16, FontWeight.w400, -0.31);
  TextStyle get subheadline => _style(15, FontWeight.w400, -0.23);
  TextStyle get subheadlineEmphasis => _style(15, FontWeight.w600, -0.23);
  TextStyle get footnote => _style(13, FontWeight.w400, -0.08, color: _secondary);
  TextStyle get footnoteEmphasis => _style(13, FontWeight.w600, -0.08);
  TextStyle get caption => _style(12, FontWeight.w400, 0, color: _secondary);
  TextStyle get secondary => _style(15, FontWeight.w400, -0.23, color: _secondary);
}

/// The Cupertino theme for [locale]: the teal tint, grouped backgrounds, and
/// for Arabic the system styles without their Latin tracking.
CupertinoThemeData appTheme(Locale locale) {
  const base = CupertinoTextThemeData(primaryColor: AppColors.tint);
  final arabic = _isArabic(locale);
  TextStyle untracked(TextStyle style) => arabic ? style.copyWith(letterSpacing: 0) : style;
  return CupertinoThemeData(
    primaryColor: AppColors.tint,
    primaryContrastingColor: AppColors.onTint,
    scaffoldBackgroundColor: AppColors.background,
    barBackgroundColor: const CupertinoDynamicColor.withBrightness(
      color: Color(0xF0F9F9F9),
      darkColor: Color(0xF01D1D1D),
    ),
    textTheme: CupertinoTextThemeData(
      primaryColor: AppColors.tint,
      textStyle: untracked(base.textStyle),
      actionTextStyle: untracked(base.actionTextStyle),
      actionSmallTextStyle: untracked(base.actionSmallTextStyle),
      tabLabelTextStyle: untracked(base.tabLabelTextStyle),
      navTitleTextStyle: untracked(base.navTitleTextStyle),
      navLargeTitleTextStyle: untracked(base.navLargeTitleTextStyle),
      navActionTextStyle: untracked(base.navActionTextStyle),
    ),
  );
}
