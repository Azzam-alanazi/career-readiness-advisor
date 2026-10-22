import 'dart:math' as math;

import 'package:career_readiness/core/format.dart';
import 'package:career_readiness/core/l10n/career_names.dart';
import 'package:career_readiness/core/theme/app_theme.dart';
import 'package:career_readiness/core/widgets/app_page.dart';
import 'package:career_readiness/core/widgets/async_view.dart';
import 'package:career_readiness/core/widgets/grouped.dart';
import 'package:career_readiness/core/widgets/language_toggle.dart';
import 'package:career_readiness/core/widgets/quality_banner.dart';
import 'package:career_readiness/core/widgets/section_header.dart';
import 'package:career_readiness/core/widgets/share_bar.dart';
import 'package:career_readiness/features/curriculum/domain/curriculum_gap.dart';
import 'package:career_readiness/features/curriculum/presentation/curriculum_providers.dart';
import 'package:career_readiness/features/gap/presentation/readiness_widgets.dart';
import 'package:career_readiness/features/onboarding/domain/career.dart';
import 'package:career_readiness/features/onboarding/presentation/catalog_providers.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// For the department, not the student: the course catalog against what the
/// job postings ask for, for one career or all of them. Reached from the tab
/// bar, never from onboarding -- a different audience with a different
/// question.
class CurriculumScreen extends ConsumerWidget {
  const CurriculumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return AppPage(
      large: true,
      title: l.curriculumTitle,
      trailing: const LanguageToggle(),
      slivers: [
        AsyncSliver(
          asyncValue: ref.watch(careersProvider),
          onRetry: () => ref.invalidate(careersProvider),
          data: (careers) => _Body(careers: careers),
        ),
      ],
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
    return SliverMainAxisGroup(
      slivers: [
        PageContent(
          children: [
            Text(l.curriculumIntro, style: AppType.of(context).secondary),
            const SizedBox(height: 16),
            // First, above every figure: how little data these gaps rest on.
            // Built from the career list, so it stays put while a scope loads.
            _SampleCaveat(careers: careers),
          ],
        ),
        // The scopes run edge to edge and scroll sideways, as filters do on iOS.
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: kScreenInset),
            child: Row(
              children: [
                _ScopePill(label: l.curriculumAllCareers, career: null, selected: scope == null),
                for (final career in careers)
                  _ScopePill(
                    label: careerName(l, career.name),
                    career: career.name,
                    selected: scope == career.name,
                  ),
              ],
            ),
          ),
        ),
        PageContent(
          children: [
            AsyncView(
              asyncValue: ref.watch(curriculumGapProvider(scope)),
              onRetry: () => ref.invalidate(curriculumGapProvider(scope)),
              data: (gap) => _Report(gap: gap),
            ),
          ],
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
    final counts = [for (final c in careers) c.postingCount]..sort();
    final postings = l.postingsCount(counts.fold<int>(0, (sum, n) => sum + n));
    return NoticeCard(
      icon: CupertinoIcons.chart_bar_square_fill,
      color: AppColors.caution,
      title: l.curriculumSampleTitle(postings),
      lines: [
        l.curriculumSampleBody(
          postings,
          counts.isEmpty ? 0 : counts.first,
          counts.isEmpty ? 0 : counts.last,
        ),
      ],
    );
  }
}

class _ScopePill extends ConsumerWidget {
  const _ScopePill({required this.label, required this.career, required this.selected});

  final String label;
  final String? career;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
        padding: const EdgeInsetsDirectional.only(end: 8),
        child: ChoicePill(
          label: label,
          selected: selected,
          onTap: () => ref.read(curriculumScopeProvider.notifier).select(career),
        ),
      );
}

class _Report extends StatelessWidget {
  const _Report({required this.gap});

  final CurriculumGap gap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        QualityBanner(validation: gap.validation),
        const SizedBox(height: 16),
        _CoverageCard(gap: gap),
        SectionHeader(l.curriculumUncoveredTitle(gap.uncovered.length)),
        _Note(l.curriculumUncoveredNote),
        if (gap.uncovered.isEmpty)
          _Empty(l.curriculumNoneUncovered)
        else
          Section(
            children: [
              for (final skill in gap.uncovered)
                // With one career chosen, which career asks goes without saying.
                _UncoveredRow(skill: skill, showCareers: gap.career == null),
            ],
          ),
        // What the threshold leaves out, next to what it lets in.
        if (gap.belowThreshold.isNotEmpty) ...[
          SectionHeader(l.curriculumBelowTitle(gap.belowThreshold.length)),
          _Note(l.curriculumBelowNote(_threshold(gap, lang))),
          Section(children: [for (final skill in gap.belowThreshold) _BelowRow(skill: skill)]),
        ],
        SectionHeader(l.curriculumByCareerTitle),
        Section(
          children: [
            for (final coverage in gap.perCareer)
              _CareerRow(coverage: coverage, current: coverage.career == gap.career),
          ],
        ),
        SectionHeader(l.curriculumNotAskedTitle(gap.notAsked.length)),
        _Note(l.curriculumNotAskedNote),
        if (gap.notAsked.isEmpty)
          _Empty(l.curriculumNoneNotAsked)
        else
          Section(children: [for (final skill in gap.notAsked) _NotAskedRow(skill: skill)]),
      ],
    );
  }
}

/// A section's explanation, between its title and its rows.
class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 10),
        child: Text(text, style: AppType.of(context).footnote),
      );
}

class _CoverageCard extends StatelessWidget {
  const _CoverageCard({required this.gap});

  final CurriculumGap gap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final type = AppType.of(context);
    final scope = gap.career == null ? l.curriculumAllCareers : careerName(l, gap.career!);
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.curriculumCoverageFor(scope), style: type.headline),
          const SizedBox(height: 6),
          Figure(formatPercent(gap.coverage, lang), style: type.hero),
          const SizedBox(height: 10),
          ShareBar(gap.coverage, minHeight: 8),
          const SizedBox(height: 12),
          Text(
            l.curriculumCoverageLine(gap.taught, gap.demanded, l.postingsCount(gap.postingCount)),
            style: type.subheadline,
          ),
          const SizedBox(height: 4),
          Text(l.curriculumCoverageCounting, style: type.footnote),
          const SizedBox(height: 10),
          // The threshold and what it leaves out, said where the figure is.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(CupertinoIcons.line_horizontal_3_decrease,
                  size: 17, color: AppColors.secondaryLabel.resolveFrom(context)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  [
                    l.curriculumThreshold(_threshold(gap, lang)),
                    if (gap.belowThreshold.isNotEmpty)
                      l.curriculumThresholdLeftOut(gap.belowThreshold.length),
                  ].join(' '),
                  style: type.footnote,
                ),
              ),
            ],
          ),
        ],
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

/// A row of the department's lists: the skill (or career) and its figure on
/// one line, notes under it.
class _Row extends StatelessWidget {
  const _Row({required this.title, this.figure, this.titleStyle, this.lines = const [], this.bar});

  final String title;
  final String? figure;
  final TextStyle? titleStyle;
  final List<String> lines;
  final Widget? bar;

  @override
  Widget build(BuildContext context) {
    final type = AppType.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 11, 16, 12),
      child: MergeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(title, style: titleStyle ?? type.body)),
                if (figure != null) ...[
                  const SizedBox(width: 8),
                  Text(figure!, style: type.footnote),
                ],
              ],
            ),
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(line, style: type.footnote),
              ),
            if (bar != null) ...[const SizedBox(height: 8), bar!],
          ],
        ),
      ),
    );
  }
}

class _BelowRow extends StatelessWidget {
  const _BelowRow({required this.skill});

  final BelowThresholdSkill skill;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return _Row(
      title: skill.nameFor(lang),
      figure: l.postingsCount(skill.postings),
      lines: [
        skill.courses.isEmpty
            ? l.curriculumNotTaught
            : l.curriculumTaughtIn(skill.courses.join(' · ')),
      ],
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
    final careers = skill.careers
        .map((c) => careerName(l, c))
        .join(lang == 'ar' ? '، ' : ', ');
    return _Row(
      title: skill.nameFor(lang),
      figure: l.demandShare(formatPercent(skill.demand, lang)),
      lines: [if (showCareers) l.curriculumAskedIn(careers)],
      bar: ShareBar(skill.demand, color: AppColors.demand),
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
    final type = AppType.of(context);
    return _Row(
      title: careerName(l, coverage.career),
      titleStyle: current ? type.headline : null,
      figure: formatPercent(coverage.coverage, lang),
      lines: [
        l.curriculumCareerLine(
          coverage.taught,
          coverage.demanded,
          l.postingsCount(coverage.postingCount),
        ),
      ],
      bar: ShareBar(coverage.coverage),
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
    return _Row(
      title: skill.nameFor(lang),
      lines: [l.curriculumTaughtIn(skill.courses.join(' · '))],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.message);

  final String message;

  @override
  Widget build(BuildContext context) =>
      Panel(child: Text(message, style: AppType.of(context).subheadline));
}
