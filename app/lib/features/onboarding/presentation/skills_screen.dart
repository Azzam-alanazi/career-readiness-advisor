import 'package:career_readiness/core/l10n/category_names.dart';
import 'package:career_readiness/core/widgets/async_view.dart';
import 'package:career_readiness/core/widgets/language_toggle.dart';
import 'package:career_readiness/core/widgets/section_header.dart';
import 'package:career_readiness/features/onboarding/domain/course.dart';
import 'package:career_readiness/features/onboarding/domain/skill.dart';
import 'package:career_readiness/features/onboarding/domain/skill_groups.dart';
import 'package:career_readiness/features/onboarding/presentation/catalog_providers.dart';
import 'package:career_readiness/features/onboarding/presentation/onboarding_controller.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(l.skillsTitle),
        actions: const [LanguageToggle()],
      ),
      body: AsyncView(
        asyncValue: ref.watch(skillsProvider),
        onRetry: () => ref.invalidate(skillsProvider),
        data: (skills) => _SkillList(
          skills: skills,
          query: _query,
          onQueryChanged: (value) => setState(() => _query = value),
        ),
      ),
      bottomNavigationBar: const _SubmitBar(),
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
    final text = Theme.of(context).textTheme;
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final catalog = ref.watch(coursesProvider).value ?? const <Course>[];

    // What the chosen courses already teach is shown as covered, not offered.
    final fromCourses = skillsFromCourses(catalog, state.courses);
    final groups = groupSkills(skills, query);
    final ticked = state.selfReported.difference(fromCourses).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l.skillsIntro, style: text.bodyLarge),
        const SizedBox(height: 8),
        // The one place the app says these are unverified.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(l.skillsUnverified, style: text.bodySmall)),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('skill-search'),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: l.skillsSearchHint,
            border: const OutlineInputBorder(),
          ),
          onChanged: onQueryChanged,
        ),
        const SizedBox(height: 8),
        Text(l.skillsSelected(ticked), style: text.labelLarge),
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(l.skillsNoMatch),
          ),
        for (final group in groups) ...[
          SectionHeader(categoryName(l, group.category)),
          for (final skill in group.skills)
            if (fromCourses.contains(skill.id))
              ListTile(
                enabled: false,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.school_outlined),
                title: Text(skill.nameFor(lang)),
                subtitle: Text(l.skillFromCourses),
              )
            else
              CheckboxListTile(
                value: state.selfReported.contains(skill.id),
                onChanged: (_) => controller.toggleSkill(skill.id),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: Text(skill.nameFor(lang)),
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  l.submitFailed,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: state.canSubmit ? () => _submit(context, ref) : null,
                child: state.submitting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(state.editing ? l.saveChanges : l.submit),
              ),
            ),
          ],
        ),
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
