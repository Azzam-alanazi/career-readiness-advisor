import 'dart:math' as math;

import 'package:career_readiness/core/format.dart';
import 'package:career_readiness/core/l10n/career_names.dart';
import 'package:career_readiness/core/widgets/async_view.dart';
import 'package:career_readiness/core/widgets/language_toggle.dart';
import 'package:career_readiness/core/widgets/quality_banner.dart';
import 'package:career_readiness/core/widgets/section_header.dart';
import 'package:career_readiness/features/curriculum/domain/curriculum_gap.dart';
import 'package:career_readiness/features/curriculum/presentation/curriculum_providers.dart';
import 'package:career_readiness/features/onboarding/domain/career.dart';
import 'package:career_readiness/features/onboarding/presentation/catalog_providers.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// For the department, not the student: the course catalog against what the
/// job postings ask for, for one career or all of them. Reached from the main
/// navigation, never from onboarding -- a different audience with a different
/// question.
class CurriculumScreen extends ConsumerWidget {
  const CurriculumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.curriculumTitle),
        actions: const [LanguageToggle()],
      ),
      body: AsyncView(
        asyncValue: ref.watch(careersProvider),
        onRetry: () => ref.invalidate(careersProvider),
        data: (careers) => _Body(careers: careers),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.careers});

  final List<Career> careers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scope = ref.watch(curriculumScopeProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l.curriculumIntro, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12),
        // First, above every figure: how little data these gaps rest on. Built
        // from the career list, so it stays put while a scope loads.
        _SampleCaveat(careers: careers),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ScopeChip(label: l.curriculumAllCareers, career: null, selected: scope == null),
            for (final career in careers)
              _ScopeChip(
                label: careerName(l, career.name),
                career: career.name,
                selected: scope == career.name,
              ),
          ],
        ),
        AsyncView(
          asyncValue: ref.watch(curriculumGapProvider(scope)),
          onRetry: () => ref.invalidate(curriculumGapProvider(scope)),
          data: (gap) => _Report(gap: gap),
        ),
      ],
    );
  }
}

/// The sample-size caveat, in the same register as the student-facing quality
/// flag: the real counts, in the reader's language, before any gap.
class _SampleCaveat extends StatelessWidget {
  const _SampleCaveat({required this.careers});

  final List<Career> careers;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final counts = [for (final c in careers) c.postingCount]..sort();
    final postings = l.postingsCount(counts.fold<int>(0, (sum, n) => sum + n));
    return Card(
      color: scheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.poll_outlined, color: scheme.onTertiaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.curriculumSampleTitle(postings),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(l.curriculumSampleBody(
                    postings,
                    counts.isEmpty ? 0 : counts.first,
                    counts.isEmpty ? 0 : counts.last,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScopeChip extends ConsumerWidget {
  const _ScopeChip({required this.label, required this.career, required this.selected});

  final String label;
  final String? career;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => ref.read(curriculumScopeProvider.notifier).select(career),
      );
}

class _Report extends StatelessWidget {
  const _Report({required this.gap});

  final CurriculumGap gap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        QualityBanner(validation: gap.validation),
        const SizedBox(height: 16),
        _CoverageCard(gap: gap),
        SectionHeader(l.curriculumUncoveredTitle(gap.uncovered.length)),
        Text(l.curriculumUncoveredNote, style: text.bodySmall),
        if (gap.uncovered.isEmpty)
          _Empty(l.curriculumNoneUncovered)
        else
          for (final skill in gap.uncovered)
            // With one career chosen, which career asks goes without saying.
            _UncoveredRow(skill: skill, showCareers: gap.career == null),
        // What the threshold leaves out, next to what it lets in.
        if (gap.belowThreshold.isNotEmpty) ...[
          SectionHeader(l.curriculumBelowTitle(gap.belowThreshold.length)),
          Text(l.curriculumBelowNote(_threshold(gap, lang)), style: text.bodySmall),
          for (final skill in gap.belowThreshold) _BelowRow(skill: skill),
        ],
        SectionHeader(l.curriculumByCareerTitle),
        for (final coverage in gap.perCareer)
          _CareerRow(coverage: coverage, current: coverage.career == gap.career),
        SectionHeader(l.curriculumNotAskedTitle(gap.notAsked.length)),
        Text(l.curriculumNotAskedNote, style: text.bodySmall),
        if (gap.notAsked.isEmpty)
          _Empty(l.curriculumNoneNotAsked)
        else
          for (final skill in gap.notAsked) _NotAskedRow(skill: skill),
      ],
    );
  }
}

class _CoverageCard extends StatelessWidget {
  const _CoverageCard({required this.gap});

  final CurriculumGap gap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final scope = gap.career == null ? l.curriculumAllCareers : careerName(l, gap.career!);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.curriculumCoverageFor(scope), style: text.titleMedium),
            const SizedBox(height: 8),
            Text(formatPercent(gap.coverage, lang), style: text.displayMedium),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: gap.coverage.clamp(0.0, 1.0).toDouble(),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(l.curriculumCoverageLine(
              gap.taught,
              gap.demanded,
              l.postingsCount(gap.postingCount),
            )),
            const SizedBox(height: 4),
            Text(l.curriculumCoverageCounting, style: text.bodySmall),
            const SizedBox(height: 8),
            // The threshold and what it leaves out, said where the figure is.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.filter_alt_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    [
                      l.curriculumThreshold(_threshold(gap, lang)),
                      if (gap.belowThreshold.isNotEmpty)
                        l.curriculumThresholdLeftOut(gap.belowThreshold.length),
                    ].join(' '),
                    style: text.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The postings a skill needs to count: one number for one career, a range
/// when the careers in scope differ.
String _threshold(CurriculumGap gap, String lang) {
  final ks = [
    for (final c in gap.perCareer)
      if (gap.career == null || c.career == gap.career) c.minPostings,
  ];
  if (ks.isEmpty) return '';
  final low = ks.reduce(math.min), high = ks.reduce(math.max);
  return low == high
      ? formatNumber(low, lang)
      : '${formatNumber(low, lang)}–${formatNumber(high, lang)}';
}

class _BelowRow extends StatelessWidget {
  const _BelowRow({required this.skill});

  final BelowThresholdSkill skill;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final small = Theme.of(context).textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(skill.nameFor(lang))),
              const SizedBox(width: 8),
              Text(l.postingsCount(skill.postings), style: small),
            ],
          ),
          Text(
            skill.courses.isEmpty
                ? l.curriculumNotTaught
                : l.curriculumTaughtIn(skill.courses.join(' · ')),
            style: small,
          ),
        ],
      ),
    );
  }
}

class _UncoveredRow extends StatelessWidget {
  const _UncoveredRow({required this.skill, required this.showCareers});

  final CurriculumSkill skill;
  final bool showCareers;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final small = Theme.of(context).textTheme.bodySmall;
    final careers = skill.careers
        .map((c) => careerName(l, c))
        .join(lang == 'ar' ? '، ' : ', ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(skill.nameFor(lang))),
              const SizedBox(width: 8),
              Text(l.demandShare(formatPercent(skill.demand, lang)), style: small),
            ],
          ),
          if (showCareers) Text(l.curriculumAskedIn(careers), style: small),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: skill.demand.clamp(0.0, 1.0).toDouble()),
        ],
      ),
    );
  }
}

class _CareerRow extends StatelessWidget {
  const _CareerRow({required this.coverage, required this.current});

  final CareerCoverage coverage;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  careerName(l, coverage.career),
                  style: current ? text.titleSmall : null,
                ),
              ),
              const SizedBox(width: 8),
              Text(formatPercent(coverage.coverage, lang)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: coverage.coverage.clamp(0.0, 1.0).toDouble()),
          const SizedBox(height: 2),
          Text(
            l.curriculumCareerLine(
              coverage.taught,
              coverage.demanded,
              l.postingsCount(coverage.postingCount),
            ),
            style: text.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _NotAskedRow extends StatelessWidget {
  const _NotAskedRow({required this.skill});

  final TaughtSkill skill;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(skill.nameFor(lang)),
          Text(
            l.curriculumTaughtIn(skill.courses.join(' · ')),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(message),
      );
}
