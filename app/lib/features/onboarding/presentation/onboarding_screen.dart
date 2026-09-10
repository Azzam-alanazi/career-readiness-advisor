import 'package:career_readiness/core/l10n/career_names.dart';
import 'package:career_readiness/core/widgets/async_view.dart';
import 'package:career_readiness/core/widgets/language_toggle.dart';
import 'package:career_readiness/core/widgets/section_header.dart';
import 'package:career_readiness/features/gap/presentation/readiness_screen.dart';
import 'package:career_readiness/features/onboarding/domain/career.dart';
import 'package:career_readiness/features/onboarding/domain/course.dart';
import 'package:career_readiness/features/onboarding/presentation/catalog_providers.dart';
import 'package:career_readiness/features/onboarding/presentation/onboarding_controller.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      bottomNavigationBar: const _SubmitBar(),
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
                    : Text(l.submit),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final id = await ref.read(onboardingControllerProvider.notifier).submit();
    if (id == null || !context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ReadinessScreen(profileId: id)),
    );
  }
}
