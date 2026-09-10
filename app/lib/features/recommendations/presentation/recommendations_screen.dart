import 'package:career_readiness/core/format.dart';
import 'package:career_readiness/core/widgets/async_view.dart';
import 'package:career_readiness/core/widgets/language_toggle.dart';
import 'package:career_readiness/core/widgets/quality_banner.dart';
import 'package:career_readiness/features/onboarding/presentation/onboarding_controller.dart';
import 'package:career_readiness/features/recommendations/domain/recommendation.dart';
import 'package:career_readiness/features/recommendations/presentation/recommendations_providers.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key, required this.profileId});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.recommendationsTitle),
        actions: const [LanguageToggle()],
      ),
      body: AsyncView(
        asyncValue: ref.watch(recommendationsProvider(profileId)),
        onRetry: () => ref.invalidate(recommendationsProvider(profileId)),
        data: (report) => _Suggestions(report: report),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: () {
              ref.read(onboardingControllerProvider.notifier).reset();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.restart_alt),
            label: Text(l.startOver),
          ),
        ),
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.report});

  final RecommendationsReport report;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // First, above everything: these are suggestions, not verdicts.
        const _SuggestionNotice(),
        const SizedBox(height: 12),
        QualityBanner(validation: report.validation),
        const SizedBox(height: 8),
        if (report.recommendations.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(l.noRecommendations, textAlign: TextAlign.center),
          )
        else
          for (final (i, recommendation) in report.recommendations.indexed)
            _CourseCard(rank: i + 1, recommendation: recommendation),
      ],
    );
  }
}

class _SuggestionNotice extends StatelessWidget {
  const _SuggestionNotice();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_outline, color: scheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.suggestionTitle, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(l.suggestionBody),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.rank, required this.recommendation});

  final int rank;
  final Recommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(radius: 16, child: Text(formatNumber(rank, lang))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recommendation.name, style: text.titleMedium),
                  Text(recommendation.code, style: text.bodySmall),
                  const SizedBox(height: 8),
                  Text(l.couldHelpWith, style: text.labelMedium),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final skill in recommendation.closes)
                        Chip(
                          label: Text(
                            '${skill.nameFor(lang)} · '
                            '${l.demandShare(formatPercent(skill.demandPercent / 100, lang))}',
                          ),
                        ),
                    ],
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
