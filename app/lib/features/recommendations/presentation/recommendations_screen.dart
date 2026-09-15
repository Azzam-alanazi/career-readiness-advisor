import 'package:career_readiness/core/format.dart';
import 'package:career_readiness/core/l10n/career_names.dart';
import 'package:career_readiness/core/widgets/async_view.dart';
import 'package:career_readiness/core/widgets/language_toggle.dart';
import 'package:career_readiness/core/widgets/quality_banner.dart';
import 'package:career_readiness/features/gap/domain/gap_query.dart';
import 'package:career_readiness/features/profile/presentation/saved_profile.dart';
import 'package:career_readiness/features/recommendations/domain/recommendation.dart';
import 'package:career_readiness/features/recommendations/presentation/recommendations_providers.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key, required this.career});

  /// The career the suggestions close gaps for: one of the profile's.
  final String career;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final profile = ref.watch(savedProfileProvider);
    if (profile == null) return const SizedBox.shrink();
    final query = gapQueryFor(profile, career);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.recommendationsTitle),
        actions: const [LanguageToggle()],
      ),
      body: AsyncView(
        asyncValue: ref.watch(recommendationsProvider(query)),
        onRetry: () => ref.invalidate(recommendationsProvider(query)),
        data: (report) => _Suggestions(report: report, career: career),
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.report, required this.career});

  final RecommendationsReport report;
  final String career;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final university = report.university;
    final online = report.online;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Which career these are for: with several compared, it is not obvious.
        Text(l.recommendationsFor(careerName(l, career)),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        // Then, above every course: these are suggestions, not verdicts.
        const _SuggestionNotice(),
        const SizedBox(height: 12),
        QualityBanner(validation: report.validation),

        // University courses count toward the degree, so they come first.
        _SourceHeader(
          icon: Icons.school_outlined,
          title: l.universityCoursesTitle(university.length),
          note: l.universityCoursesNote,
        ),
        if (university.isEmpty)
          _EmptyNote(l.noRecommendations)
        else
          for (final (i, course) in university.indexed)
            _UniversityCard(rank: i + 1, course: course),

        _SourceHeader(
          icon: Icons.public,
          title: l.onlineCoursesTitle(online.length),
          note: l.onlineCoursesNote,
        ),
        if (online.isEmpty)
          _EmptyNote(l.noOnlineCourses)
        else
          for (final course in online) _OnlineCard(course: course),

        if (report.uncovered.isNotEmpty) ...[
          const SizedBox(height: 24),
          _UncoveredCard(skills: report.uncovered),
        ],
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

class _SourceHeader extends StatelessWidget {
  const _SourceHeader({required this.icon, required this.title, required this.note});

  final IconData icon;
  final String title;
  final String note;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleMedium),
                Text(note, style: text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  const _EmptyNote(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(message),
      );
}

/// Whether a course counts toward the degree, on every card, so a card read on
/// its own still says so.
class _DegreeBadge extends StatelessWidget {
  const _DegreeBadge({required this.counts});

  final bool counts;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(counts ? Icons.check_circle_outline : Icons.remove_circle_outline,
          size: 18),
      label: Text(counts ? l.countsTowardDegree : l.notTowardDegree),
      backgroundColor: counts ? scheme.primaryContainer : scheme.surfaceContainerHighest,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SkillChips extends StatelessWidget {
  const _SkillChips(this.skills);

  final List<SkillRef> skills;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final skill in skills)
          Chip(
            label: Text(
              '${skill.nameFor(lang)} · '
              '${l.demandShare(formatPercent(skill.demandPercent / 100, lang))}',
            ),
          ),
      ],
    );
  }
}

class _UniversityCard extends StatelessWidget {
  const _UniversityCard({required this.rank, required this.course});

  final int rank;
  final UniversityRecommendation course;

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
                  Text(course.name, style: text.titleMedium),
                  Text(course.code, style: text.bodySmall),
                  const SizedBox(height: 8),
                  const _DegreeBadge(counts: true),
                  const SizedBox(height: 8),
                  Text(l.couldHelpWith, style: text.labelMedium),
                  const SizedBox(height: 4),
                  _SkillChips(course.closes),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnlineCard extends StatelessWidget {
  const _OnlineCard({required this.course});

  final OnlineRecommendation course;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(radius: 16, child: Icon(Icons.public, size: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title, style: theme.textTheme.titleMedium),
                  Text(course.provider, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      const _DegreeBadge(counts: false),
                      Chip(
                        label: Text(course.isFree ? l.free : l.paid),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // A web address reads left to right in either language.
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: SelectableText(
                      course.url,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(l.couldHelpWith, style: theme.textTheme.labelMedium),
                  const SizedBox(height: 4),
                  _SkillChips(course.closes),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UncoveredCard extends StatelessWidget {
  const _UncoveredCard({required this.skills});

  final List<SkillRef> skills;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.uncoveredTitle(skills.length), style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(l.uncoveredBody),
            const SizedBox(height: 8),
            _SkillChips(skills),
          ],
        ),
      ),
    );
  }
}
