import 'dart:math' as math;

import 'package:career_readiness/core/format.dart';
import 'package:career_readiness/core/l10n/career_names.dart';
import 'package:career_readiness/core/theme/app_theme.dart';
import 'package:career_readiness/core/widgets/app_page.dart';
import 'package:career_readiness/core/widgets/async_view.dart';
import 'package:career_readiness/core/widgets/buttons.dart';
import 'package:career_readiness/core/widgets/grouped.dart';
import 'package:career_readiness/core/widgets/quality_banner.dart';
import 'package:career_readiness/core/widgets/section_header.dart';
import 'package:career_readiness/core/widgets/share_bar.dart';
import 'package:career_readiness/features/gap/domain/gap_query.dart';
import 'package:career_readiness/features/gap/domain/gap_report.dart';
import 'package:career_readiness/features/gap/domain/skill_entry.dart';
import 'package:career_readiness/features/gap/presentation/gap_providers.dart';
import 'package:career_readiness/features/gap/presentation/readiness_widgets.dart';
import 'package:career_readiness/features/onboarding/presentation/catalog_providers.dart';
import 'package:career_readiness/features/planning/presentation/planning_screen.dart';
import 'package:career_readiness/features/profile/domain/student_profile.dart';
import 'package:career_readiness/features/profile/presentation/saved_profile.dart';
import 'package:career_readiness/features/recommendations/presentation/recommendations_screen.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The saved profile's readiness. With two or three target careers, they are
/// shown side by side above the details of one of them; with courses planned,
/// the projection stands beside today's figure.
class ReadinessScreen extends ConsumerStatefulWidget {
  const ReadinessScreen({super.key});

  @override
  ConsumerState<ReadinessScreen> createState() => _ReadinessScreenState();
}

class _ReadinessScreenState extends ConsumerState<ReadinessScreen> {
  // The career whose details are shown: the main one, until another is tapped.
  String? _focus;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final profile = ref.watch(servedProfileProvider);
    if (profile == null) return const SizedBox.shrink();
    final careers = profile.careers;
    // An edited profile may no longer name the career that was in focus.
    final focus = careers.contains(_focus) ? _focus! : careers.first;
    final query = gapQueryFor(profile, career: focus);
    final projected = profile.plannedCourses.isEmpty
        ? null
        : ref.watch(gapReportProvider(gapQueryFor(profile, career: focus, withPlanned: true)));
    void open(Widget screen) =>
        Navigator.of(context).push(CupertinoPageRoute<void>(builder: (_) => screen));
    return AppPage(
      title: l.readinessTitle,
      bottomBar: BottomBar(
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SecondaryButton(
                  label: l.planTitle,
                  onPressed: () => open(PlanningScreen(career: focus)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryButton(
                  label: l.seeRecommendations,
                  onPressed: () => open(RecommendationsScreen(career: focus)),
                ),
              ),
            ],
          ),
        ),
      ),
      slivers: [
        AsyncSliver(
          asyncValue: ref.watch(gapReportProvider(query)),
          onRetry: () => retryGap(ref, query),
          data: (report) => _Report(
            report: report,
            projected: projected,
            plannedCount: profile.plannedCourses.length,
            comparison: careers.length < 2
                ? null
                : _Comparison(
                    profile: profile,
                    focus: focus,
                    onFocus: (career) => setState(() => _focus = career),
                  ),
          ),
        ),
      ],
    );
  }
}

class _Report extends StatelessWidget {
  const _Report({
    required this.report,
    required this.projected,
    required this.plannedCount,
    this.comparison,
  });

  final GapReport report;

  /// The same reading with the planned courses counted, when any are planned.
  final AsyncValue<GapReport>? projected;
  final int plannedCount;

  /// The careers side by side, when the profile names more than one.
  final Widget? comparison;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final type = AppType.of(context);
    return PageContent(
      children: [
        QualityBanner(validation: report.validation),
        ?comparison,
        const SizedBox(height: 24),
        ReadinessCard(
          report: report,
          projected: projected,
          plannedCount: plannedCount,
          footer: [
            // The academic record on its own, whenever self-reported skills
            // make the two differ.
            if (report.coveredSelfReported.isNotEmpty)
              Text(
                l.readinessFromCoursesOnly(formatPercent(report.readinessFromCourses, lang)),
                style: type.subheadline,
              ),
            Text(l.readinessExplained, style: type.footnote),
          ],
        ),
        SectionHeader(l.coveredTitle(report.covered.length)),
        Panel(
          child: report.covered.isEmpty
              ? Text(l.noneCovered, style: type.subheadline)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Where each skill came from, so the academic-record claim
                    // stays separate from the student's own.
                    if (report.coveredFromCourses.isNotEmpty)
                      _SkillGroup(
                        title: l.coveredFromCoursesTitle(report.coveredFromCourses.length),
                        skills: report.coveredFromCourses,
                        icon: CupertinoIcons.book_fill,
                        color: AppColors.tint,
                      ),
                    if (report.coveredFromCourses.isNotEmpty &&
                        report.coveredSelfReported.isNotEmpty)
                      const SizedBox(height: 16),
                    if (report.coveredSelfReported.isNotEmpty)
                      _SkillGroup(
                        title: l.coveredSelfReportedTitle(report.coveredSelfReported.length),
                        skills: report.coveredSelfReported,
                        icon: CupertinoIcons.person_fill,
                        color: CupertinoColors.systemGrey,
                      ),
                  ],
                ),
        ),
        SectionHeader(l.missingTitle(report.missing.length)),
        if (report.missing.isNotEmpty)
          Section(
            children: [
              for (final skill in report.missing)
                DemandRow(name: skill.nameFor(lang), demand: skill.demand),
            ],
          ),
      ],
    );
  }
}

class _SkillGroup extends StatelessWidget {
  const _SkillGroup({
    required this.title,
    required this.skills,
    required this.icon,
    required this.color,
  });

  final String title;
  final List<SkillEntry> skills;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppType.of(context).footnoteEmphasis),
        const SizedBox(height: 8),
        TagWrap(
          children: [
            for (final skill in skills) Tag(icon: icon, color: color, label: skill.nameFor(lang)),
          ],
        ),
      ],
    );
  }
}

/// Two or three careers side by side, so the student can see which path they
/// are closest to. Tapping one shows its details below.
class _Comparison extends ConsumerWidget {
  const _Comparison({required this.profile, required this.focus, required this.onFocus});

  final StudentProfile profile;
  final String focus;
  final ValueChanged<String> onFocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final careers = profile.careers;
    final reports = [
      for (final career in careers)
        ref.watch(gapReportProvider(gapQueryFor(profile, career: career))),
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
                  child: KeyedSubtree(
                    key: ValueKey('compare:$career'),
                    child: _CareerTile(
                      career: career,
                      report: reports[i],
                      postings: postings[career],
                      focused: career == focus,
                      closest: best != null && scores[i] == best,
                      onTap: () => onFocus(career),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(4, 8, 4, 0),
          child: Text(l.compareNote, style: AppType.of(context).footnote),
        ),
      ],
    );
  }
}

class _CareerTile extends StatelessWidget {
  const _CareerTile({
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
    final type = AppType.of(context);
    final tint = CupertinoTheme.of(context).primaryColor;
    final surface = AppColors.surface.resolveFrom(context);
    return Semantics(
      selected: focused,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: ShapeDecoration(
            color: focused ? Color.alphaBlend(tint.withValues(alpha: 0.10), surface) : surface,
            shape: RoundedSuperellipseBorder(
              borderRadius: AppRadius.card,
              side: BorderSide(color: focused ? tint : const Color(0x00000000), width: 2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(careerName(l, career), style: type.subheadlineEmphasis),
              if (postings != null) Text(l.postingsCount(postings!), style: type.caption),
              const SizedBox(height: 10),
              switch (report) {
                AsyncData(:final value) => _Figures(report: value, closest: closest),
                AsyncError() => Icon(
                  CupertinoIcons.exclamationmark_circle,
                  color: AppColors.danger.resolveFrom(context),
                ),
                _ => const CupertinoActivityIndicator(),
              },
            ],
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
    final type = AppType.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Figure(formatPercent(report.readiness, lang), style: type.title2),
        const SizedBox(height: 6),
        ShareBar(report.readiness),
        const SizedBox(height: 8),
        Text(l.compareCovered(report.covered.length), style: type.footnote),
        Text(l.compareMissing(report.missing.length), style: type.footnote),
        // The academic record on its own, whenever self-reported skills make
        // the two differ -- the same rule as the score card below.
        if (report.coveredSelfReported.isNotEmpty)
          Text(
            l.compareFromCourses(formatPercent(report.readinessFromCourses, lang)),
            style: type.caption,
          ),
        if (closest) ...[
          const SizedBox(height: 8),
          Tag(icon: CupertinoIcons.star_fill, color: AppColors.tint, label: l.compareClosest),
        ],
      ],
    );
  }
}
