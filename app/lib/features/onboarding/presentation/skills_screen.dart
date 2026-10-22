import 'package:career_readiness/core/l10n/category_names.dart';
import 'package:career_readiness/core/theme/app_theme.dart';
import 'package:career_readiness/core/widgets/app_page.dart';
import 'package:career_readiness/core/widgets/async_view.dart';
import 'package:career_readiness/core/widgets/buttons.dart';
import 'package:career_readiness/core/widgets/grouped.dart';
import 'package:career_readiness/core/widgets/language_toggle.dart';
import 'package:career_readiness/core/widgets/section_header.dart';
import 'package:career_readiness/features/onboarding/domain/course.dart';
import 'package:career_readiness/features/onboarding/domain/skill.dart';
import 'package:career_readiness/features/onboarding/domain/skill_groups.dart';
import 'package:career_readiness/features/onboarding/presentation/catalog_providers.dart';
import 'package:career_readiness/features/onboarding/presentation/onboarding_controller.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Onboarding, second step: skills held from outside coursework. Optional --
/// nothing starts ticked, and going on with none ticked is a normal answer.
class SkillsScreen extends ConsumerStatefulWidget {
  const SkillsScreen({super.key});

  @override
  ConsumerState<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends ConsumerState<SkillsScreen> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppPage(
      large: true,
      title: l.skillsTitle,
      trailing: const LanguageToggle(),
      bottomBar: const _SubmitBar(),
      slivers: [
        AsyncSliver(
          asyncValue: ref.watch(skillsProvider),
          onRetry: () => ref.invalidate(skillsProvider),
          data: (skills) => _SkillList(
            skills: skills,
            query: _query,
            onQueryChanged: (value) => setState(() => _query = value),
          ),
        ),
      ],
    );
  }
}

class _SkillList extends ConsumerWidget {
  const _SkillList({
    required this.skills,
    required this.query,
    required this.onQueryChanged,
  });

  final List<Skill> skills;
  final String query;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final type = AppType.of(context);
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final catalog = ref.watch(coursesProvider).value ?? const <Course>[];

    // What the chosen courses already teach is shown as covered, not offered.
    final fromCourses = skillsFromCourses(catalog, state.courses);
    final groups = groupSkills(skills, query);
    final ticked = state.selfReported.difference(fromCourses).length;

    return PageContent(
      children: [
        Text(l.skillsIntro, style: type.secondary),
        const SizedBox(height: 12),
        // The one place the app says these are unverified.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(CupertinoIcons.info_circle,
                size: 17, color: AppColors.secondaryLabel.resolveFrom(context)),
            const SizedBox(width: 6),
            Expanded(child: Text(l.skillsUnverified, style: type.footnote)),
          ],
        ),
        const SizedBox(height: 16),
        CupertinoSearchTextField(
          key: const Key('skill-search'),
          placeholder: l.skillsSearchHint,
          onChanged: onQueryChanged,
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, top: 10),
          child: Text(l.skillsSelected(ticked), style: type.footnoteEmphasis),
        ),
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(l.skillsNoMatch, textAlign: TextAlign.center, style: type.secondary),
          ),
        for (final group in groups) ...[
          SectionHeader(categoryName(l, group.category)),
          Section(
            dividerIndent: 52,
            children: [
              for (final skill in group.skills)
                if (fromCourses.contains(skill.id))
                  ListRow(
                    title: skill.nameFor(lang),
                    subtitle: l.skillFromCourses,
                    titleStyle: type.body.copyWith(
                      color: AppColors.secondaryLabel.resolveFrom(context),
                    ),
                    leading: Icon(
                      CupertinoIcons.book_fill,
                      size: 22,
                      color: CupertinoTheme.of(context).primaryColor,
                    ),
                  )
                else
                  CheckRow(
                    value: state.selfReported.contains(skill.id),
                    onChanged: () => controller.toggleSkill(skill.id),
                    title: skill.nameFor(lang),
                  ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SubmitBar extends ConsumerWidget {
  const _SubmitBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(onboardingControllerProvider);
    return BottomBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(CupertinoIcons.exclamationmark_circle_fill,
                      size: 18, color: AppColors.danger.resolveFrom(context)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(l.submitFailed, style: AppType.of(context).footnote),
                  ),
                ],
              ),
            ),
          PrimaryButton(
            label: state.editing ? l.saveChanges : l.submit,
            busy: state.submitting,
            onPressed: state.canSubmit ? () => _submit(context, ref) : null,
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final saved = await ref.read(onboardingControllerProvider.notifier).finish();
    if (!saved || !context.mounted) return;
    // Saved on the device: the student tab's first screen is now the profile's
    // home, so go back to it rather than deeper in.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
