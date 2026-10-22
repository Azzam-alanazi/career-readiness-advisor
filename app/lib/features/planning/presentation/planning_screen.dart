import 'package:career_readiness/core/format.dart';
import 'package:career_readiness/core/l10n/career_names.dart';
import 'package:career_readiness/core/l10n/track_names.dart';
import 'package:career_readiness/core/theme/app_theme.dart';
import 'package:career_readiness/core/widgets/app_page.dart';
import 'package:career_readiness/core/widgets/async_view.dart';
import 'package:career_readiness/core/widgets/grouped.dart';
import 'package:career_readiness/core/widgets/readiness_ring.dart';
import 'package:career_readiness/core/widgets/section_header.dart';
import 'package:career_readiness/core/widgets/toast.dart';
import 'package:career_readiness/features/gap/domain/gap_query.dart';
import 'package:career_readiness/features/gap/domain/gap_report.dart';
import 'package:career_readiness/features/gap/domain/skill_entry.dart';
import 'package:career_readiness/features/gap/presentation/gap_providers.dart';
import 'package:career_readiness/features/gap/presentation/readiness_widgets.dart';
import 'package:career_readiness/features/onboarding/domain/course.dart';
import 'package:career_readiness/features/onboarding/domain/course_groups.dart';
import 'package:career_readiness/features/onboarding/presentation/catalog_providers.dart';
import 'package:career_readiness/features/planning/domain/plan.dart';
import 'package:career_readiness/features/profile/domain/student_profile.dart';
import 'package:career_readiness/features/profile/presentation/saved_profile.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What-if planning: mark courses to take, and see readiness now beside
/// readiness with them, with the gaps each course would close.
class PlanningScreen extends ConsumerStatefulWidget {
  const PlanningScreen({super.key, this.career});

  /// The career to open on; the profile's main one when null.
  final String? career;

  @override
  ConsumerState<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends ConsumerState<PlanningScreen> {
  String? _focus;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final profile = ref.watch(servedProfileProvider);
    if (profile == null) return const SizedBox.shrink();
    final wanted = _focus ?? widget.career;
    final focus = profile.careers.contains(wanted) ? wanted! : profile.primaryCareer;
    final nowQuery = gapQueryFor(profile, career: focus);
    return AppPage(
      title: l.planTitle,
      slivers: [
        AsyncSliver(
          asyncValue: ref.watch(coursesProvider),
          onRetry: () => ref.invalidate(coursesProvider),
          data: (catalog) => AsyncSliver(
            asyncValue: ref.watch(gapReportProvider(nowQuery)),
            onRetry: () => retryGap(ref, nowQuery),
            data: (now) => _Plan(
              profile: profile,
              catalog: catalog,
              focus: focus,
              now: now,
              onFocus: (career) => setState(() => _focus = career),
            ),
          ),
        ),
      ],
    );
  }
}

class _Plan extends ConsumerWidget {
  const _Plan({
    required this.profile,
    required this.catalog,
    required this.focus,
    required this.now,
    required this.onFocus,
  });

  final StudentProfile profile;
  final List<Course> catalog;
  final String focus;
  final GapReport now;
  final ValueChanged<String> onFocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final type = AppType.of(context);
    final planned = profile.plannedCourses.toSet();
    final projected = planned.isEmpty
        ? null
        : ref.watch(gapReportProvider(gapQueryFor(profile, career: focus, withPlanned: true)));
    // Completed courses already count; the plan is chosen from the rest.
    final open = [
      for (final c in catalog)
        if (!profile.completedCourses.contains(c.code)) c,
    ];
    return PageContent(
      children: [
        Text(l.planIntro, style: type.secondary),
        const SizedBox(height: 16),
        if (profile.careers.length > 1)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final career in profile.careers)
                ChoicePill(
                  label: careerName(l, career),
                  selected: career == focus,
                  onTap: () => onFocus(career),
                ),
            ],
          )
        else
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4),
            child: Text(l.recommendationsFor(careerName(l, focus)), style: type.title3),
          ),
        const SizedBox(height: 12),
        _ProjectionCard(
          now: now,
          projected: projected,
          plannedCount: planned.length,
          closedByPlan: gapsClosedByPlan(
            [for (final c in open) if (planned.contains(c.code)) c],
            now,
          ).length,
        ),
        SectionHeader(l.planCoursesTitle),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, end: 4),
          child: Text('${l.planExplained} ${l.planCompletedNote}', style: type.footnote),
        ),
        for (final group in groupCourses(open, '')) ...[
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(4, 22, 4, 8),
            child: Text(trackName(l, group.track), style: type.headline),
          ),
          Section(
            dividerIndent: 52,
            children: [
              for (final course in group.courses)
                _PlanRow(
                  course: course,
                  closes: gapsClosedBy(course, now),
                  planned: planned.contains(course.code),
                  onChanged: () => _toggle(context, ref, course.code),
                ),
            ],
          ),
        ],
      ],
    );
  }

  /// Plans a course or takes it off the plan. A failed write has already put
  /// the plan back; the student is told rather than left guessing.
  Future<void> _toggle(BuildContext context, WidgetRef ref, String code) async {
    final failed = AppLocalizations.of(context).submitFailed;
    try {
      await ref.read(savedProfileProvider.notifier).togglePlanned(code);
    } catch (_) {
      if (context.mounted) showToast(context, failed);
    }
  }
}

/// Readiness now beside readiness with the plan: the projection next to the
/// figure it projects from, with the ring showing both.
class _ProjectionCard extends StatelessWidget {
  const _ProjectionCard({
    required this.now,
    required this.projected,
    required this.plannedCount,
    required this.closedByPlan,
  });

  final GapReport now;
  final AsyncValue<GapReport>? projected;
  final int plannedCount;
  final int closedByPlan;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final type = AppType.of(context);
    final projected = this.projected;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ReadinessRing(now: now.readiness, planned: projected?.value?.readiness),
              const SizedBox(width: 18),
              Expanded(
                child: projected == null
                    ? ReadinessFigure(value: now.readiness, caption: l.planNow, large: true)
                    : NowAndPlanned(now: now, projected: projected, plannedCount: plannedCount),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            projected == null
                ? l.planNothingYet
                : l.planClosesCount(closedByPlan, now.missing.length),
            style: type.subheadline,
          ),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.course,
    required this.closes,
    required this.planned,
    required this.onChanged,
  });

  final Course course;
  final List<SkillEntry> closes;
  final bool planned;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final type = AppType.of(context);
    final named = closes
        .map((s) => '${s.nameFor(lang)} (${l.demandShare(formatPercent(s.demand, lang))})')
        .join(lang == 'ar' ? '، ' : ', ');
    return CheckRow(
      value: planned,
      onChanged: onChanged,
      title: course.name,
      subtitle: course.code,
      // What the course would close is the reason to plan it, so it reads in
      // full text colour; "closes none" stays secondary.
      detail: Text(
        closes.isEmpty ? l.planClosesNone : l.planCloses(named),
        style: closes.isEmpty
            ? type.footnote
            : type.footnote.copyWith(color: AppColors.label.resolveFrom(context)),
      ),
    );
  }
}
