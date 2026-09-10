import 'package:career_readiness/l10n/app_localizations.dart';

/// The backend names careers in English. The five the app was built around get
/// a translation; anything else falls back to the backend's own name rather
/// than disappearing.
String careerName(AppLocalizations l, String career) => switch (career) {
      'Business Analyst' => l.careerBusinessAnalyst,
      'Data Analyst' => l.careerDataAnalyst,
      'ERP Consultant' => l.careerErpConsultant,
      'IT Support Specialist' => l.careerItSupportSpecialist,
      'Software Developer' => l.careerSoftwareDeveloper,
      _ => career,
    };
