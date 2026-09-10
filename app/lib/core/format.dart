import 'package:intl/intl.dart';

/// Numbers are formatted in the UI's own locale, so a percentage in the Arabic
/// UI follows Arabic conventions instead of being an English string dropped
/// into right-to-left text.
String formatPercent(double fraction, String locale) =>
    NumberFormat.percentPattern(locale).format(fraction);

String formatNumber(num? value, String locale) =>
    value == null ? '–' : NumberFormat.decimalPattern(locale).format(value);
