import 'package:career_readiness/l10n/app_localizations.dart';

/// Display name of a taxonomy category, falling back to its key for a category
/// this app does not know yet.
String categoryName(AppLocalizations l, String category) => switch (category) {
      'business_analysis' => l.categoryBusinessAnalysis,
      'data' => l.categoryData,
      'software_development' => l.categorySoftwareDevelopment,
      'infrastructure' => l.categoryInfrastructure,
      'it_support' => l.categoryItSupport,
      'security' => l.categorySecurity,
      'erp' => l.categoryErp,
      'professional' => l.categoryProfessional,
      _ => category,
    };
