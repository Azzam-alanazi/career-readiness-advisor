import 'package:career_readiness/core/theme/app_theme.dart';
import 'package:career_readiness/core/widgets/app_page.dart';
import 'package:career_readiness/core/widgets/async_view.dart';
import 'package:career_readiness/core/widgets/buttons.dart';
import 'package:career_readiness/core/widgets/grouped.dart';
import 'package:career_readiness/core/widgets/quality_banner.dart';
import 'package:career_readiness/core/widgets/section_header.dart';
import 'package:career_readiness/features/gap/domain/gap_query.dart';
import 'package:career_readiness/features/gap/presentation/gap_providers.dart';
import 'package:career_readiness/features/gap/presentation/readiness_screen.dart';
import 'package:career_readiness/features/gap/presentation/readiness_widgets.dart';
import 'package:career_readiness/features/planning/presentation/planning_screen.dart';
import 'package:career_readiness/features/profile/presentation/saved_profile.dart';
import 'package:career_readiness/features/settings/presentation/settings_screen.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The student's home once a profile is saved: readiness for the main career,
/// the three most-demanded gaps, and the ways on to planning, the full
/// readiness view and settings.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final type = AppType.of(context);
    final profile = ref.watch(servedProfileProvider);
    if (profile == null) return const SizedBox.shrink();
    final query = gapQueryFor(profile);
    final projected = profile.plannedCourses.isEmpty
        ? null
        : ref.watch(gapReportProvider(gapQueryFor(profile, withPlanned: true)));
    void open(Widget screen) =>
        Navigator.of(context).push(CupertinoPageRoute<void>(builder: (_) => screen));
    return AppPage(
      large: true,
      title: l.homeTitle,
      trailing: NavIconButton(
        key: const Key('open-settings'),
        icon: CupertinoIcons.gear,
        label: l.settingsTitle,
        onPressed: () => open(const SettingsScreen()),
      ),
      slivers: [
        AsyncSliver(
          asyncValue: ref.watch(gapReportProvider(query)),
          onRetry: () => retryGap(ref, query),
          data: (report) => PageContent(
            children: [
              // The figures below are estimates too: the headline of the flag
              // here, all of it on the full readiness view.
              QualityBanner(validation: report.validation, compact: true),
              const SizedBox(height: 16),
              ReadinessCard(
                report: report,
                projected: projected,
                plannedCount: profile.plannedCourses.length,
              ),
              SectionHeader(l.homeTopGaps),
              if (report.missing.isEmpty)
                Panel(child: Text(l.homeNoGaps, style: type.subheadline))
              else
                Section(
                  children: [
                    for (final skill in report.missing.take(3))
                      DemandRow(name: skill.nameFor(lang), demand: skill.demand),
                  ],
                ),
              const SizedBox(height: 28),
              Section(
                dividerIndent: 57,
                children: [
                  ListRow(
                    leading: const IconBadge(CupertinoIcons.calendar_badge_plus, color: AppColors.tint),
                    title: l.planTitle,
                    subtitle: l.planPlannedCount(profile.plannedCourses.length),
                    chevron: true,
                    onTap: () => open(const PlanningScreen()),
                  ),
                  ListRow(
                    leading: const IconBadge(CupertinoIcons.chart_bar_alt_fill, color: AppColors.demand),
                    title: l.homeFullReadiness,
                    subtitle: l.homeFullReadinessHint,
                    chevron: true,
                    onTap: () => open(const ReadinessScreen()),
                  ),
                  ListRow(
                    leading: const IconBadge(CupertinoIcons.gear_alt_fill, color: CupertinoColors.systemGrey),
                    title: l.settingsTitle,
                    subtitle: l.homeSettingsHint,
                    chevron: true,
                    onTap: () => open(const SettingsScreen()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
