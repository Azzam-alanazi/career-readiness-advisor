import 'package:career_readiness/core/format.dart';
import 'package:career_readiness/core/l10n/career_names.dart';
import 'package:career_readiness/core/l10n/track_names.dart';
import 'package:career_readiness/core/widgets/async_view.dart';
import 'package:career_readiness/core/widgets/language_toggle.dart';
import 'package:career_readiness/core/widgets/section_header.dart';
import 'package:career_readiness/features/gap/domain/gap_query.dart';
import 'package:career_readiness/features/gap/domain/gap_report.dart';
import 'package:career_readiness/features/gap/domain/skill_entry.dart';
import 'package:career_readiness/features/gap/presentation/gap_providers.dart';
import 'package:career_readiness/features/onboarding/domain/course.dart';
import 'package:career_readiness/features/onboarding/domain/course_groups.dart';
import 'package:career_readiness/features/onboarding/presentation/catalog_providers.dart';
import 'package:career_readiness/features/planning/domain/plan.dart';
import 'package:career_readiness/features/profile/domain/student_profile.dart';
import 'package:career_readiness/features/profile/presentation/saved_profile.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(l.planTitle),
        actions: const [LanguageToggle()],
      ),
      body: AsyncView(
        asyncValue: ref.watch(coursesProvider),
        onRetry: () => ref.invalidate(coursesProvider),
        data: (catalog) => AsyncView(
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
    final text = Theme.of(context).textTheme;
    final planned = profile.plannedCourses.toSet();
    final projected = planned.isEmpty
        ? null
        : ref.watch(gapReportProvider(gapQueryFor(profile, career: focus, withPlanned: true)));
    // Completed courses already count; the plan is chosen from the rest.
    final open = [
      for (final c in catalog)
        if (!profile.completedCourses.contains(c.code)) c,
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l.planIntro, style: text.bodyLarge),
        const SizedBox(height: 12),
        if (profile.careers.length > 1)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final career in profile.careers)
                ChoiceChip(
                  label: Text(careerName(l, career)),
                  selected: career == focus,
                  onSelected: (_) => onFocus(career),
                ),
            ],
          )
        else
          Text(l.recommendationsFor(careerName(l, focus)), style: text.titleMedium),
        const SizedBox(height: 12),
        _ProjectionCard(
          now: now,
          projected: projected,
          plannedCount: planned.length,
          closedByPlan: gapsClosedByPlan([for (final c in open) if (planned.contains(c.code)) c], now).length,
        ),
        SectionHeader(l.planCoursesTitle),
        Text(l.planExplained, style: text.bodySmall),
        Text(l.planCompletedNote, style: text.bodySmall),
        for (final group in groupCourses(open, '')) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 4),
            child: Text(trackName(l, group.track), style: text.titleSmall),
          ),
          for (final course in group.courses)
            _PlanRow(
              course: course,
              closes: gapsClosedBy(course, now),
              planned: planned.contains(course.code),
              onChanged: () => _toggle(context, ref, course.code),
            ),
        ],
      ],
    );
  }

  /// Plans a course or takes it off the plan. A failed write has already put
  /// the plan back; the student is told rather than left guessing.
  Future<void> _toggle(BuildContext context, WidgetRef ref, String code) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);
    try {
      await ref.read(savedProfileProvider.notifier).togglePlanned(code);
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l.submitFailed)));
    }
  }
}

/// Readiness now beside readiness with the plan: the projection next to the
/// figure it projects from.
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
    final text = Theme.of(context).textTheme;
    final projected = this.projected;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: projected == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReadinessFigure(value: now.readiness, caption: l.planNow),
                  const SizedBox(height: 8),
                  Text(l.planNothingYet),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NowAndPlanned(now: now, projected: projected, plannedCount: plannedCount),
                  const SizedBox(height: 8),
                  Text(l.planClosesCount(closedByPlan, now.missing.length), style: text.bodyMedium),
                ],
              ),
      ),
    );
  }
}

/// A readiness figure with what it describes underneath.
class ReadinessFigure extends StatelessWidget {
  const ReadinessFigure({super.key, required this.value, required this.caption, this.large = false});

  final double value;
  final String caption;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(formatPercent(value, lang), style: large ? text.displayMedium : text.displaySmall),
        Text(caption, style: text.bodyMedium),
      ],
    );
  }
}

/// "31% now, 48% if you take your planned courses", side by side, with the
/// gain in points. Shared by the planning and readiness screens.
class NowAndPlanned extends StatelessWidget {
  const NowAndPlanned({
    super.key,
    required this.now,
    required this.projected,
    required this.plannedCount,
  });

  final GapReport now;
  final AsyncValue<GapReport> projected;
  final int plannedCount;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: ReadinessFigure(value: now.readiness, caption: l.planNow)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          // Mirrors itself in right-to-left, pointing from now to the plan.
          child: Icon(Icons.arrow_forward, color: scheme.primary),
        ),
        Expanded(
          child: switch (projected) {
            AsyncData(:final value) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReadinessFigure(value: value.readiness, caption: l.planWith(plannedCount)),
                  if (value.readinessPercent > now.readinessPercent)
                    Text(l.planPoints(value.readinessPercent - now.readinessPercent),
                        style: TextStyle(color: scheme.primary)),
                ],
              ),
            AsyncError() => Text(l.errorServer),
            _ => const LinearProgressIndicator(),
          },
        ),
      ],
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
    final small = Theme.of(context).textTheme.bodySmall;
    final named = closes
        .map((s) => '${s.nameFor(lang)} (${l.demandShare(formatPercent(s.demand, lang))})')
        .join(lang == 'ar' ? '، ' : ', ');
    return CheckboxListTile(
      value: planned,
      onChanged: (_) => onChanged(),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      title: Text(course.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(course.code, style: small),
          Text(closes.isEmpty ? l.planClosesNone : l.planCloses(named), style: small),
        ],
      ),
    );
  }
}
