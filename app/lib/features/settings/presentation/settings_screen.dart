import 'package:career_readiness/core/l10n/career_names.dart';
import 'package:career_readiness/core/locale/locale_controller.dart';
import 'package:career_readiness/core/widgets/section_header.dart';
import 'package:career_readiness/features/onboarding/presentation/onboarding_controller.dart';
import 'package:career_readiness/features/onboarding/presentation/onboarding_screen.dart';
import 'package:career_readiness/features/profile/presentation/saved_profile.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The saved profile, the language, and what is kept where.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final scheme = Theme.of(context).colorScheme;
    final profile = ref.watch(savedProfileProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (profile != null) ...[
            SectionHeader(l.settingsProfile),
            _Line(
              icon: Icons.work_outline,
              text: profile.careers
                  .map((c) => careerName(l, c))
                  .join(lang == 'ar' ? '، ' : ', '),
            ),
            if (profile.major != null) _Line(icon: Icons.school_outlined, text: profile.major!),
            _Line(
              icon: Icons.menu_book_outlined,
              text: l.settingsCourses(profile.completedCourses.length),
            ),
            _Line(
              icon: Icons.person_outline,
              text: l.settingsSkills(profile.selfReportedSkills.length),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.tonalIcon(
                icon: const Icon(Icons.edit_outlined),
                label: Text(l.settingsEditProfile),
                onPressed: () {
                  ref.read(onboardingControllerProvider.notifier).startEditing(profile);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const OnboardingScreen()),
                  );
                },
              ),
            ),
          ],
          SectionHeader(l.settingsLanguage),
          // Each language named in itself, so a reader of either finds theirs.
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'en', label: Text('English')),
              ButtonSegment(value: 'ar', label: Text('العربية')),
            ],
            selected: {ref.watch(localeProvider).languageCode},
            onSelectionChanged: (choice) =>
                ref.read(localeProvider.notifier).set(Locale(choice.first)),
          ),
          SectionHeader(l.settingsStorage),
          Text(l.settingsLocalOnly),
          if (profile != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: Text(l.settingsDelete),
                style: OutlinedButton.styleFrom(foregroundColor: scheme.error),
                onPressed: () => _confirmDelete(context, ref),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l.settingsDeleteTitle),
        content: Text(l.settingsDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (yes != true) return;
    await ref.read(savedProfileProvider.notifier).clear();
    ref.read(onboardingControllerProvider.notifier).reset();
    // With no profile, the student tab's first screen is onboarding again.
    if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      );
}
