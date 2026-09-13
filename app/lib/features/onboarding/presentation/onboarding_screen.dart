import 'package:career_readiness/core/l10n/career_names.dart';
import 'package:career_readiness/core/widgets/async_view.dart';
import 'package:career_readiness/core/widgets/language_toggle.dart';
import 'package:career_readiness/core/widgets/section_header.dart';
import 'package:career_readiness/features/onboarding/domain/career.dart';
import 'package:career_readiness/features/onboarding/domain/course.dart';
import 'package:career_readiness/features/onboarding/presentation/catalog_providers.dart';
import 'package:career_readiness/features/onboarding/presentation/onboarding_controller.dart';
import 'package:career_readiness/features/onboarding/presentation/skills_screen.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Onboarding, first step: major, target career and completed courses.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.onboardingTitle),
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

class _Form extends ConsumerWidget {
  const _Form({required this.careers, required this.courses});

  final List<Career> careers;
  final List<Course> courses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final career in careers)
              ChoiceChip(
                label: Text(careerName(l, career.name)),
                selected: state.career == career.name,
                onSelected: (_) => controller.selectCareer(career.name),
              ),
          ],
        ),
        if (state.career == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(l.careerRequired, style: text.bodySmall),
          ),
        SectionHeader(l.coursesLabel(state.courses.length)),
        Text(l.coursesCatalogNote, style: text.bodySmall),
        for (final course in courses)
          CheckboxListTile(
            value: state.courses.contains(course.code),
            onChanged: (_) => controller.toggleCourse(course.code),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(course.name),
            subtitle: Text(course.code),
          ),
      ],
    );
  }
}

class _NextBar extends ConsumerWidget {
  const _NextBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final hasCareer =
        ref.watch(onboardingControllerProvider.select((s) => s.career != null));
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: hasCareer
                ? () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const SkillsScreen()),
                    )
                : null,
            child: Text(l.nextToSkills),
          ),
        ),
      ),
    );
  }
}
