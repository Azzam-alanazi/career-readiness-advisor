import 'package:career_readiness/core/l10n/career_names.dart';
import 'package:career_readiness/core/l10n/track_names.dart';
import 'package:career_readiness/core/widgets/async_view.dart';
import 'package:career_readiness/core/widgets/language_toggle.dart';
import 'package:career_readiness/core/widgets/section_header.dart';
import 'package:career_readiness/features/onboarding/domain/career.dart';
import 'package:career_readiness/features/onboarding/domain/course.dart';
import 'package:career_readiness/features/onboarding/domain/course_groups.dart';
import 'package:career_readiness/features/onboarding/domain/onboarding_state.dart';
import 'package:career_readiness/features/onboarding/presentation/catalog_providers.dart';
import 'package:career_readiness/features/onboarding/presentation/onboarding_controller.dart';
import 'package:career_readiness/features/onboarding/presentation/skills_screen.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Onboarding, first step: major, target careers and completed courses.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(ref.watch(onboardingControllerProvider.select((s) => s.editing))
            ? l.editProfileTitle
            : l.onboardingTitle),
        actions: const [LanguageToggle()],
      ),
      body: AsyncView(
        asyncValue: ref.watch(careersProvider),
        onRetry: () => ref.invalidate(careersProvider),
        data: (careers) => AsyncView(
          asyncValue: ref.watch(coursesProvider),
          onRetry: () => ref.invalidate(coursesProvider),
          data: (courses) => _Form(careers: careers, courses: courses),
        ),
      ),
      bottomNavigationBar: const _NextBar(),
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
    final text = Theme.of(context).textTheme;
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    final searching = _query.trim().isNotEmpty;
    final groups = groupCourses(widget.courses, _query);
    final shown = [for (final g in groups) ...g.courses];
    final counts = trackCounts(widget.courses, state.courses);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l.onboardingIntro, style: text.bodyLarge),
        const SizedBox(height: 16),
        TextFormField(
          key: ValueKey(state.revision),
          initialValue: state.major,
          decoration: InputDecoration(
            labelText: l.majorLabel,
            hintText: l.majorHint,
            border: const OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.done,
          onChanged: controller.setMajor,
        ),
        SectionHeader(l.careerLabel),
        Text(l.careersHint, style: text.bodySmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final career in widget.careers)
              FilterChip(
                label: Text(careerName(l, career.name)),
                selected: state.careers.contains(career.name),
                // Once three are chosen, the others wait until one is let go.
                onSelected: state.careers.contains(career.name) ||
                        state.careers.length < OnboardingState.maxCareers
                    ? (_) => controller.toggleCareer(career.name)
                    : null,
              ),
          ],
        ),
        if (state.careers.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(l.careerRequired, style: text.bodySmall),
          ),
        SectionHeader(l.coursesLabel(state.courses.length)),
        Text(l.coursesCatalogNote, style: text.bodySmall),
        const SizedBox(height: 12),
        _LevelShortcuts(courses: widget.courses),
        const SizedBox(height: 12),
        TextField(
          key: const Key('course-search'),
          controller: _search,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: l.coursesSearchHint,
            border: const OutlineInputBorder(),
            suffixIcon: searching
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: l.coursesClearSearch,
                    onPressed: () {
                      _search.clear();
                      _setQuery('');
                    },
                  )
                : null,
          ),
          onChanged: _setQuery,
        ),
        if (searching)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              icon: const Icon(Icons.done_all),
              label: Text(l.coursesSelectShown(shown.length)),
              onPressed: shown.every((c) => state.courses.contains(c.code))
                  ? null
                  : () => controller.selectCourses([for (final c in shown) c.code]),
            ),
          ),
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(l.coursesNoMatch),
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
            for (final course in group.courses)
              CheckboxListTile(
                value: state.courses.contains(course.code),
                onChanged: (_) => controller.toggleCourse(course.code),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: Text(course.name),
                subtitle: Text(course.code),
              ),
        ],
      ],
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
        Text(l.coursesQuickSelect, style: Theme.of(context).textTheme.labelLarge),
        for (final level in levels)
          ActionChip(
            avatar: const Icon(Icons.playlist_add_check, size: 18),
            label: Text(l.coursesUpToLevel(level)),
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
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: onToggle != null,
      expanded: onToggle == null ? null : expanded,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.titleSmall),
                    Text(l.trackSelected(counts.selected, counts.total),
                        style: text.bodySmall),
                  ],
                ),
              ),
              if (onToggle != null)
                Icon(expanded ? Icons.expand_less : Icons.expand_more),
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
    final state = ref.watch(onboardingControllerProvider);
    final count = state.courses.length;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.checklist, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(l.selectedCourses(count))),
                TextButton(
                  onPressed: count == 0
                      ? null
                      : () => showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            builder: (_) => const _ReviewSheet(),
                          ),
                  child: Text(l.coursesReview),
                ),
                TextButton(
                  onPressed: count == 0
                      ? null
                      : () => _clearWithUndo(
                            ScaffoldMessenger.of(context),
                            l,
                            ref.read(onboardingControllerProvider.notifier),
                            state.courses,
                          ),
                  child: Text(l.coursesClear),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: state.careers.isNotEmpty
                    ? () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const SkillsScreen()),
                        )
                    : null,
                child: Text(l.nextToSkills),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// What is chosen, by track, with each course removable in one tap.
class _ReviewSheet extends ConsumerWidget {
  const _ReviewSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final chosen = ref.watch(onboardingControllerProvider).courses;
    final controller = ref.read(onboardingControllerProvider.notifier);
    final catalog = ref.watch(coursesProvider).value ?? const <Course>[];
    final groups =
        groupCourses([for (final c in catalog) if (chosen.contains(c.code)) c], '');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(l.coursesReviewTitle, style: text.titleLarge)),
              TextButton(
                onPressed: chosen.isEmpty
                    ? null
                    : () {
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.of(context).pop();
                        _clearWithUndo(messenger, l, controller, chosen);
                      },
                child: Text(l.coursesClearAll),
              ),
            ],
          ),
          Text(l.selectedCourses(chosen.length), style: text.bodySmall),
          const SizedBox(height: 8),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final group in groups) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(trackName(l, group.track), style: text.labelLarge),
                  ),
                  for (final course in group.courses)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(course.name),
                      subtitle: Text(course.code),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: l.coursesRemove,
                        onPressed: () => controller.toggleCourse(course.code),
                      ),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.coursesDone),
          ),
        ],
      ),
    );
  }
}

/// Empties the selection, with an undo: clearing twenty ticks by mistake should
/// cost one tap to take back.
void _clearWithUndo(ScaffoldMessengerState messenger, AppLocalizations l,
    OnboardingController controller, Set<String> before) {
  controller.setCourses(const {});
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(l.coursesCleared),
      action: SnackBarAction(label: l.undo, onPressed: () => controller.setCourses(before)),
    ));
}
