import 'package:career_readiness/core/l10n/career_names.dart';
import 'package:career_readiness/core/locale/locale_controller.dart';
import 'package:career_readiness/core/theme/app_theme.dart';
import 'package:career_readiness/core/widgets/app_page.dart';
import 'package:career_readiness/core/widgets/grouped.dart';
import 'package:career_readiness/core/widgets/section_header.dart';
import 'package:career_readiness/features/onboarding/presentation/onboarding_controller.dart';
import 'package:career_readiness/features/onboarding/presentation/onboarding_screen.dart';
import 'package:career_readiness/features/profile/presentation/saved_profile.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The saved profile, the language, and what is kept where -- laid out as the
/// iPhone's own Settings.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final type = AppType.of(context);
    final tint = CupertinoTheme.of(context).primaryColor;
    final profile = ref.watch(servedProfileProvider);
    final current = ref.watch(localeProvider).languageCode;
    Widget check(bool on) => on
        ? Icon(CupertinoIcons.checkmark_alt, size: 22, color: tint)
        : const SizedBox.shrink();
    return AppPage(
      title: l.settingsTitle,
      slivers: [
        PageContent(
          children: [
            if (profile != null) ...[
              SectionHeader(l.settingsProfile),
              Section(
                dividerIndent: 57,
                children: [
                  ListRow(
                    leading: const IconBadge(CupertinoIcons.briefcase_fill, color: AppColors.tint),
                    title: profile.careers
                        .map((c) => careerName(l, c))
                        .join(lang == 'ar' ? '، ' : ', '),
                  ),
                  if (profile.major != null)
                    ListRow(
                      leading: const IconBadge(CupertinoIcons.book_fill, color: AppColors.tint),
                      title: profile.major!,
                    ),
                  ListRow(
                    leading: const IconBadge(CupertinoIcons.checkmark_rectangle, color: AppColors.tint),
                    title: l.settingsCourses(profile.completedCourses.length),
                  ),
                  ListRow(
                    leading: const IconBadge(CupertinoIcons.person_fill, color: AppColors.tint),
                    title: l.settingsSkills(profile.selfReportedSkills.length),
                  ),
                  ListRow(
                    leading: const IconBadge(CupertinoIcons.calendar_badge_plus, color: AppColors.tint),
                    title: l.planPlannedCount(profile.plannedCourses.length),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Section(
                children: [
                  ListRow(
                    title: l.settingsEditProfile,
                    titleStyle: type.body.copyWith(color: tint),
                    onTap: () {
                      ref.read(onboardingControllerProvider.notifier).startEditing(profile);
                      Navigator.of(context).push(
                        CupertinoPageRoute<void>(builder: (_) => const OnboardingScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],
            SectionHeader(l.settingsLanguage),
            // Each language named in itself, so a reader of either finds theirs.
            Section(
              children: [
                for (final (code, name) in const [('en', 'English'), ('ar', 'العربية')])
                  ListRow(
                    title: name,
                    checked: current == code,
                    trailing: check(current == code),
                    onTap: () => ref.read(localeProvider.notifier).set(Locale(code)),
                  ),
              ],
            ),
            SectionHeader(l.settingsStorage),
            if (profile == null)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 4),
                child: Text(l.settingsLocalOnly, style: type.footnote),
              )
            else
              Section(
                footer: l.settingsLocalOnly,
                children: [
                  ListRow(
                    title: l.settingsDelete,
                    titleStyle: type.body.copyWith(color: AppColors.danger.resolveFrom(context)),
                    onTap: () => _confirmDelete(context, ref),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final yes = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (sheet) => CupertinoActionSheet(
        title: Text(l.settingsDeleteTitle),
        message: Text(l.settingsDeleteBody),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(sheet).pop(true),
            child: Text(l.delete),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(sheet).pop(false),
          child: Text(l.cancel),
        ),
      ),
    );
    // The screen may have gone while the sheet was open, and its ref with it.
    if (yes != true || !context.mounted) return;
    await ref.read(savedProfileProvider.notifier).clear();
    ref.read(onboardingControllerProvider.notifier).reset();
    // With no profile, the student tab's first screen is onboarding again.
    if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
