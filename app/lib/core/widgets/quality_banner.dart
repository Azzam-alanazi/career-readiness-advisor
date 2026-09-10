import 'package:career_readiness/core/domain/validation_info.dart';
import 'package:career_readiness/core/format.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// The backend's quality flag, shown beside every readiness figure.
///
/// The matcher behind these numbers failed its validation gate. That is stated
/// here in the student's language, with the actual scores, rather than hidden
/// in documentation nobody using the app will read.
class QualityBanner extends StatelessWidget {
  const QualityBanner({super.key, required this.validation});

  final ValidationInfo validation;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final scheme = Theme.of(context).colorScheme;
    final failed = !validation.gatePassed;

    final lines = [
      if (failed)
        l.qualityGateFailed(
          formatNumber(validation.bestF1, lang),
          formatNumber(validation.gateMinF1, lang),
        ),
      if (!validation.courseMappingValidated) l.qualityCoursesUnchecked,
      l.qualityEnglishSource,
    ];

    return Card(
      color: failed ? scheme.tertiaryContainer : scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              failed ? Icons.warning_amber_rounded : Icons.info_outline,
              color: failed ? scheme.onTertiaryContainer : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    failed ? l.qualityTitle : l.qualityTitlePassed,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  for (final line in lines)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(line),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
