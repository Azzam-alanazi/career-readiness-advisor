import 'package:career_readiness/core/domain/validation_info.dart';
import 'package:career_readiness/core/format.dart';
import 'package:career_readiness/core/theme/app_theme.dart';
import 'package:career_readiness/core/widgets/grouped.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';

/// The backend's quality flag, shown beside every readiness figure.
///
/// The matcher behind these numbers failed its validation gate. That is stated
/// here in the student's language, with the actual scores, rather than hidden
/// in documentation nobody using the app will read.
class QualityBanner extends StatelessWidget {
  const QualityBanner({super.key, required this.validation, this.compact = false});

  final ValidationInfo validation;

  /// Only the headline and the failed gate: for the home screen, where the
  /// full flag is one tap away on the readiness view.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final failed = !validation.gatePassed;
    return NoticeCard(
      icon: failed
          ? CupertinoIcons.exclamationmark_triangle_fill
          : CupertinoIcons.info_circle_fill,
      color: failed ? AppColors.caution : CupertinoColors.systemGrey,
      title: failed ? l.qualityTitle : l.qualityTitlePassed,
      lines: [
        if (failed)
          l.qualityGateFailed(
            formatNumber(validation.bestF1, lang),
            formatNumber(validation.gateMinF1, lang),
          ),
        if (!compact) ...[
          if (!validation.courseMappingValidated) l.qualityCoursesUnchecked,
          l.qualityEnglishSource,
        ],
      ],
    );
  }
}
