import 'package:career_readiness/core/format.dart';
import 'package:career_readiness/core/l10n/career_names.dart';
import 'package:career_readiness/core/l10n/track_names.dart';
import 'package:career_readiness/core/theme/app_theme.dart';
import 'package:career_readiness/core/widgets/app_page.dart';
import 'package:career_readiness/core/widgets/async_view.dart';
import 'package:career_readiness/core/widgets/buttons.dart';
import 'package:career_readiness/core/widgets/grouped.dart';
import 'package:career_readiness/core/widgets/language_toggle.dart';
import 'package:career_readiness/core/widgets/section_header.dart';
import 'package:career_readiness/core/widgets/toast.dart';
import 'package:career_readiness/features/onboarding/domain/career.dart';
import 'package:career_readiness/features/onboarding/domain/course.dart';
import 'package:career_readiness/features/onboarding/domain/course_groups.dart';
import 'package:career_readiness/features/onboarding/domain/onboarding_state.dart';
import 'package:career_readiness/features/onboarding/presentation/catalog_providers.dart';
import 'package:career_readiness/features/onboarding/presentation/onboarding_controller.dart';
import 'package:career_readiness/features/onboarding/presentation/skills_screen.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Onboarding, first step: major, target careers and completed courses.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return AppPage(
      large: true,
      title: ref.watch(onboardingControllerProvider.select((s) => s.editing))
          ? l.editProfileTitle
          : l.onboardingTitle,
      trailing: const LanguageToggle(),
      bottomBar: const _NextBar(),
      slivers: [
        AsyncSliver(
          asyncValue: ref.watch(careersProvider),
          onRetry: () => ref.invalidate(careersProvider),
          data: (careers) => AsyncSliver(
            asyncValue: ref.watch(coursesProvider),
            onRetry: () => ref.invalidate(coursesProvider),
            data: (courses) => _Form(careers: careers, courses: courses),
          ),
        ),
      ],
    );
  }
}

class _Form extends ConsumerStatefulWidget {
  const _Form({required this.careers, required this.courses});

  final List<Career> careers;
  final List<Course> courses;

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> {
  final _search = TextEditingController();
  var _query = '';

  // Tracks the student has folded away. A search opens every track with a
  // match, whatever is folded, so a result is never hidden.
  final _collapsed = <String>{};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _setQuery(String value) => setState(() => _query = value);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final type = AppType.of(context);
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    final searching = _query.trim().isNotEmpty;
    final groups = groupCourses(widget.courses, _query);
    final shown = [for (final g in groups) ...g.courses];
    final counts = trackCounts(widget.courses, state.courses);

    return PageContent(
      children: [
        Text(l.onboardingIntro, style: type.secondary),
        const SizedBox(height: 20),
        Section(
          children: [
            CupertinoTextFormFieldRow(
              key: ValueKey(state.revision),
              prefix: Text(l.majorLabel, style: type.body),
              initialValue: state.major,
              placeholder: l.majorHint,
              textAlign: TextAlign.end,
              textInputAction: TextInputAction.done,
              onChanged: controller.setMajor,
            ),
          ],
        ),
        SectionHeader(l.careerLabel),
        Section(
          dividerIndent: 52,
          footer: [l.careersHint, if (state.careers.isEmpty) l.careerRequired].join(' '),
          children: [
            for (final career in widget.careers)
              _CareerRow(
                career: career,
                order: state.careers.indexOf(career.name),
                // Once three are chosen, the others wait until one is let go.
                onTap: state.careers.contains(career.name) ||
                        state.careers.length < OnboardingState.maxCareers
                    ? () => controller.toggleCareer(career.name)
                    : null,
              ),
          ],
        ),
        SectionHeader(l.coursesLabel(state.courses.length)),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 12),
          child: Text(l.coursesCatalogNote, style: type.footnote),
        ),
        _LevelShortcuts(courses: widget.courses),
        const SizedBox(height: 12),
        CupertinoSearchTextField(
          key: const Key('course-search'),
          controller: _search,
          placeholder: l.coursesSearchHint,
          backgroundColor: AppColors.fill,
          onChanged: _setQuery,
        ),
        if (searching)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: ActionPill(
                icon: CupertinoIcons.checkmark_alt,
                label: l.coursesSelectShown(shown.length),
                onPressed: shown.every((c) => state.courses.contains(c.code))
                    ? null
                    : () => controller.selectCourses([for (final c in shown) c.code]),
              ),
            ),
          ),
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(l.coursesNoMatch, textAlign: TextAlign.center, style: type.secondary),
          ),
        for (final group in groups) ...[
          _TrackHeader(
            title: trackName(l, group.track),
            counts: counts[group.track]!,
            expanded: searching || !_collapsed.contains(group.track),
            // Folding is for browsing; a search shows every match.
            onToggle: searching
                ? null
                : () => setState(() {
                      if (!_collapsed.remove(group.track)) _collapsed.add(group.track);
                    }),
          ),
          if (searching || !_collapsed.contains(group.track))
            Section(
              dividerIndent: 52,
              children: [
                for (final course in group.courses)
                  CheckRow(
                    value: state.courses.contains(course.code),
                    onChanged: () => controller.toggleCourse(course.code),
                    title: course.name,
                    subtitle: course.code,
                  ),
              ],
            ),
        ],
      ],
    );
  }
}

/// A career to choose. A chosen one shows its place in the order: the first
/// is the main career, the one the app opens on.
class _CareerRow extends StatelessWidget {
  const _CareerRow({required this.career, required this.order, required this.onTap});

  final Career career;

  /// Its place among the chosen, from 0; -1 when not chosen.
  final int order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final chosen = order >= 0;
    final tint = CupertinoTheme.of(context).primaryColor;
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: ListRow(
        title: careerName(l, career.name),
        subtitle: l.postingsCount(career.postingCount),
        checked: chosen,
        onTap: onTap,
        leading: ExcludeSemantics(
          child: SizedBox.square(
            dimension: 24,
            child: chosen
                ? DecoratedBox(
                    decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        formatNumber(order + 1, lang),
                        style: AppType.of(context).footnoteEmphasis.copyWith(
                              color: CupertinoTheme.of(context).primaryContrastingColor,
                              height: 1,
                            ),
                      ),
                    ),
                  )
                : const CheckCircle(value: false),
          ),
        ),
      ),
    );
  }
}

/// "This level and below" shortcuts: most students have completed everything
/// below the level they are on.
class _LevelShortcuts extends ConsumerWidget {
  const _LevelShortcuts({required this.courses});

  final List<Course> courses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final levels = shortcutLevels(courses);
    if (levels.isEmpty) return const SizedBox.shrink();
    final controller = ref.read(onboardingControllerProvider.notifier);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4),
          child: Text(l.coursesQuickSelect, style: AppType.of(context).footnote),
        ),
        for (final level in levels)
          ActionPill(
            icon: CupertinoIcons.text_badge_checkmark,
            label: l.coursesUpToLevel(level),
            // Adds: what is already chosen stays chosen.
            onPressed: () => controller.selectCourses(codesUpToLevel(courses, level)),
          ),
      ],
    );
  }
}

class _TrackHeader extends StatelessWidget {
  const _TrackHeader({
    required this.title,
    required this.counts,
    required this.expanded,
    required this.onToggle,
  });

  final String title;
  final ({int selected, int total}) counts;
  final bool expanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final type = AppType.of(context);
    return Semantics(
      button: onToggle != null,
      expanded: onToggle == null ? null : expanded,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(4, 24, 4, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: type.headline),
                    Text(l.trackSelected(counts.selected, counts.total), style: type.footnote),
                  ],
                ),
              ),
              if (onToggle != null)
                Icon(
                  expanded ? CupertinoIcons.chevron_down : CupertinoIcons.chevron_forward,
                  size: 18,
                  color: CupertinoTheme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Always in view: how many courses are chosen, a way to review or clear them,
/// and the way on.
class _NextBar extends ConsumerWidget {
  const _NextBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final type = AppType.of(context);
    final state = ref.watch(onboardingControllerProvider);
    final count = state.courses.length;
    return BottomBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // One line when it fits; at large text sizes the buttons move to a
          // line of their own rather than squeezing the count to nothing.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(l.selectedCourses(count), style: type.subheadline),
              Wrap(
                children: [
                  CupertinoButton(
                    sizeStyle: CupertinoButtonSize.small,
                    onPressed: count == 0
                        ? null
                        : () => showCupertinoSheet<void>(
                              context: context,
                              scrollableBuilder: (_, scroll) => _ReviewSheet(scroll: scroll),
                            ),
                    child: Text(l.coursesReview),
                  ),
                  CupertinoButton(
                    sizeStyle: CupertinoButtonSize.small,
                    onPressed: count == 0
                        ? null
                        : () => _clearWithUndo(
                              context,
                              l,
                              ref.read(onboardingControllerProvider.notifier),
                              state.courses,
                            ),
                    child: Text(l.coursesClear),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          PrimaryButton(
            label: l.nextToSkills,
            onPressed: state.careers.isNotEmpty
                ? () => Navigator.of(context).push(
                      CupertinoPageRoute<void>(builder: (_) => const SkillsScreen()),
                    )
                : null,
          ),
        ],
      ),
    );
  }
}

/// What is chosen, by track, in a sheet over the list; each course comes off
/// with the red minus of iOS editing.
class _ReviewSheet extends ConsumerWidget {
  const _ReviewSheet({required this.scroll});

  final ScrollController scroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final type = AppType.of(context);
    final chosen = ref.watch(onboardingControllerProvider).courses;
    final controller = ref.read(onboardingControllerProvider.notifier);
    final catalog = ref.watch(coursesProvider).value ?? const <Course>[];
    final groups =
        groupCourses([for (final c in catalog) if (chosen.contains(c.code)) c], '');
    return CupertinoPageScaffold(
      key: const Key('review-sheet'),
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          sizeStyle: CupertinoButtonSize.small,
          onPressed: chosen.isEmpty
              ? null
              : () {
                  Navigator.of(context).pop();
                  _clearWithUndo(context, l, controller, chosen);
                },
          child: Text(
            l.coursesClearAll,
            style: TextStyle(
              color: chosen.isEmpty ? null : AppColors.danger.resolveFrom(context),
            ),
          ),
        ),
        middle: Text(l.coursesReviewTitle),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          sizeStyle: CupertinoButtonSize.small,
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.coursesDone, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
      child: CustomScrollView(
        controller: scroll,
        slivers: [
          SliverSafeArea(
            sliver: PageContent(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 4, top: 8),
                  child: Text(l.selectedCourses(chosen.length), style: type.footnote),
                ),
                for (final group in groups) ...[
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8),
                    child: Text(trackName(l, group.track), style: type.headline),
                  ),
                  Section(
                    dividerIndent: 52,
                    children: [
                      for (final course in group.courses)
                        ListRow(
                          key: ValueKey(course.code),
                          title: course.name,
                          subtitle: course.code,
                          leading: Semantics(
                            label: l.coursesRemove,
                            button: true,
                            excludeSemantics: true,
                            child: GestureDetector(
                              onTap: () => controller.toggleCourse(course.code),
                              child: Icon(
                                CupertinoIcons.minus_circle_fill,
                                size: 24,
                                color: AppColors.danger.resolveFrom(context),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Empties the selection, with an undo: clearing twenty ticks by mistake should
/// cost one tap to take back.
void _clearWithUndo(BuildContext context, AppLocalizations l,
    OnboardingController controller, Set<String> before) {
  controller.setCourses(const {});
  showToast(
    context,
    l.coursesCleared,
    actionLabel: l.undo,
    onAction: () => controller.setCourses(before),
  );
}
