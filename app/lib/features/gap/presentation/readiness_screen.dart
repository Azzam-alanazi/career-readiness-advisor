import 'dart:math' as math;

import 'package:career_readiness/core/format.dart';
import 'package:career_readiness/core/l10n/career_names.dart';
import 'package:career_readiness/core/widgets/async_view.dart';
import 'package:career_readiness/core/widgets/language_toggle.dart';
import 'package:career_readiness/core/widgets/quality_banner.dart';
import 'package:career_readiness/core/widgets/section_header.dart';
import 'package:career_readiness/features/gap/domain/gap_report.dart';
import 'package:career_readiness/features/gap/domain/skill_entry.dart';
import 'package:career_readiness/features/gap/presentation/gap_providers.dart';
import 'package:career_readiness/features/onboarding/presentation/catalog_providers.dart';
import 'package:career_readiness/features/recommendations/presentation/recommendations_screen.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadinessScreen extends ConsumerStatefulWidget {
  const ReadinessScreen({super.key, required this.profileId, required this.careers});

  final String profileId;

  /// The profile's target careers, in the order chosen. With two or three,
  /// they are shown side by side above the details of one of them.
  final List<String> careers;

  @override
  ConsumerState<ReadinessScreen> createState() => _ReadinessScreenState();
}

class _ReadinessScreenState extends ConsumerState<ReadinessScreen> {
  // The career whose details are shown: the first chosen, until another is tapped.
  late String _focus = widget.careers.first;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final key = (profileId: widget.profileId, career: _focus);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.readinessTitle),
        actions: const [LanguageToggle()],
      ),
      body: AsyncView(
        asyncValue: ref.watch(gapReportProvider(key)),
        onRetry: () => ref.invalidate(gapReportProvider(key)),
        data: (report) => _Report(
          report: report,
          comparison: widget.careers.length < 2
              ? null
              : _Comparison(
                  profileId: widget.profileId,
                  careers: widget.careers,
                  focus: _focus,
                  onFocus: (career) => setState(() => _focus = career),
                ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    RecommendationsScreen(profileId: widget.profileId, career: _focus),
              ),
            ),
            icon: const Icon(Icons.school_outlined),
            label: Text(l.seeRecommendations),
          ),
        ),
      ),
    );
  }
}

class _Report extends StatelessWidget {
  const _Report({required this.report, this.comparison});

  final GapReport report;

  /// The careers side by side, when the profile names more than one.
  final Widget? comparison;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        QualityBanner(validation: report.validation),
        ?comparison,
        const SizedBox(height: 16),
        Text(
          l.readinessFor(careerName(l, report.career)),
          style: text.titleLarge,
        ),
        const SizedBox(height: 8),
        _ScoreCard(report: report),
        SectionHeader(l.coveredTitle(report.covered.length)),
        if (report.covered.isEmpty)
          Text(l.noneCovered)
        else ...[
          // Where each skill came from, so the academic-record claim stays
          // separate from the student's own.
          if (report.coveredFromCourses.isNotEmpty) ...[
            Text(l.coveredFromCoursesTitle(report.coveredFromCourses.length),
                style: text.labelLarge),
            const SizedBox(height: 4),
            _SkillChips(
              skills: report.coveredFromCourses,
              icon: Icons.school_outlined,
              lang: lang,
            ),
            const SizedBox(height: 12),
          ],
          if (report.coveredSelfReported.isNotEmpty) ...[
            Text(l.coveredSelfReportedTitle(report.coveredSelfReported.length),
                style: text.labelLarge),
            const SizedBox(height: 4),
            _SkillChips(
              skills: report.coveredSelfReported,
              icon: Icons.person_outline,
              lang: lang,
            ),
          ],
        ],
        SectionHeader(l.missingTitle(report.missing.length)),
        for (final skill in report.missing)
          _DemandRow(name: skill.nameFor(lang), demand: skill.demand),
      ],
    );
  }
}

/// Two or three careers side by side, so the student can see which path they
/// are closest to. Tapping one shows its details below.
class _Comparison extends ConsumerWidget {
  const _Comparison({
    required this.profileId,
    required this.careers,
    required this.focus,
    required this.onFocus,
  });

  final String profileId;
  final List<String> careers;
  final String focus;
  final ValueChanged<String> onFocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final reports = [
      for (final career in careers)
        ref.watch(gapReportProvider((profileId: profileId, career: career))),
    ];
    // "Closest" only once every score is in, and only when they differ: the
    // figures as shown, so two careers that both read 31% are not split.
    final scores = [for (final r in reports) r.value?.readinessPercent];
    final best = scores.every((s) => s != null) && scores.toSet().length > 1
        ? scores.map((s) => s!).reduce(math.max)
        : null;
    final postings = {
      for (final c in ref.watch(careersProvider).value ?? const []) c.name: c.postingCount,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(l.compareTitle),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, career) in careers.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _CareerColumn(
                    career: career,
                    report: reports[i],
                    postings: postings[career],
                    focused: career == focus,
                    closest: best != null && scores[i] == best,
                    onTap: () => onFocus(career),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(l.compareNote, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _CareerColumn extends StatelessWidget {
  const _CareerColumn({
    required this.career,
    required this.report,
    required this.postings,
    required this.focused,
    required this.closest,
    required this.onTap,
  });

  final String career;
  final AsyncValue<GapReport> report;
  final int? postings;
  final bool focused;
  final bool closest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      selected: focused,
      child: Card(
        margin: EdgeInsets.zero,
        color: focused ? scheme.primaryContainer : null,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: focused ? scheme.primary : scheme.outlineVariant,
            width: focused ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(careerName(l, career), style: theme.textTheme.titleSmall),
                if (postings != null)
                  Text(l.postingsCount(postings!), style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                switch (report) {
                  AsyncData(:final value) => _Figures(report: value, closest: closest),
                  AsyncError() => Icon(Icons.error_outline, color: scheme.error),
                  _ => const LinearProgressIndicator(),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Figures extends StatelessWidget {
  const _Figures({required this.report, required this.closest});

  final GapReport report;
  final bool closest;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(formatPercent(report.readiness, lang), style: theme.textTheme.headlineMedium),
        const SizedBox(height: 4),
        LinearProgressIndicator(value: report.readiness.clamp(0.0, 1.0).toDouble()),
        const SizedBox(height: 8),
        Text(l.compareCovered(report.covered.length)),
        Text(l.compareMissing(report.missing.length)),
        // The academic record on its own, whenever self-reported skills make
        // the two differ -- the same rule as the score card below.
        if (report.coveredSelfReported.isNotEmpty)
          Text(
            l.compareFromCourses(formatPercent(report.readinessFromCourses, lang)),
            style: theme.textTheme.bodySmall,
          ),
        if (closest) ...[
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              // Text, not a chip: it wraps in a narrow column instead of overflowing.
              child: Text.rich(TextSpan(children: [
                const WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(Icons.star_outline, size: 16),
                ),
                TextSpan(text: ' ${l.compareClosest}'),
              ])),
            ),
          ),
        ],
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.report});

  final GapReport report;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formatPercent(report.readiness, lang), style: text.displayMedium),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: report.readiness.clamp(0.0, 1.0).toDouble(),
              minHeight: 8,
            ),
            // The academic record on its own, whenever self-reported skills
            // make the two differ.
            if (report.coveredSelfReported.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l.readinessFromCoursesOnly(
                    formatPercent(report.readinessFromCourses, lang)),
                style: text.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            Text(l.readinessExplained, style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _SkillChips extends StatelessWidget {
  const _SkillChips({required this.skills, required this.icon, required this.lang});

  final List<SkillEntry> skills;
  final IconData icon;
  final String lang;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final skill in skills)
            Chip(
              avatar: Icon(icon, size: 18),
              label: Text(skill.nameFor(lang)),
            ),
        ],
      );
}

class _DemandRow extends StatelessWidget {
  const _DemandRow({required this.name, required this.demand});

  final String name;
  final double demand;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(name)),
              const SizedBox(width: 8),
              Text(
                l.demandShare(formatPercent(demand, lang)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: demand.clamp(0.0, 1.0).toDouble()),
        ],
      ),
    );
  }
}
