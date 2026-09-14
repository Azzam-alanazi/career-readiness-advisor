import 'package:career_readiness/l10n/app_localizations.dart';

/// The catalog names its tracks with keys. The four it uses get a title in
/// each language; anything else is grouped as "other courses".
String trackName(AppLocalizations l, String track) => switch (track) {
      'college' => l.trackCollege,
      'core' => l.trackCore,
      'elective_analytics' => l.trackElectiveAnalytics,
      'elective_ecommerce' => l.trackElectiveEcommerce,
      _ => l.trackOther,
    };
