import 'package:career_readiness/core/format.dart';
import 'package:career_readiness/core/l10n/career_names.dart';
import 'package:career_readiness/core/widgets/async_view.dart';
import 'package:career_readiness/core/widgets/language_toggle.dart';
import 'package:career_readiness/core/widgets/quality_banner.dart';
import 'package:career_readiness/core/widgets/section_header.dart';
import 'package:career_readiness/features/gap/domain/gap_query.dart';
import 'package:career_readiness/features/gap/domain/gap_report.dart';
import 'package:career_readiness/features/gap/presentation/gap_providers.dart';
import 'package:career_readiness/features/gap/presentation/readiness_screen.dart';
import 'package:career_readiness/features/planning/presentation/planning_screen.dart';
import 'package:career_readiness/features/profile/presentation/saved_profile.dart';
import 'package:career_readiness/features/settings/presentation/settings_screen.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
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
    final profile = ref.watch(savedProfileProvider);
    if (profile == null) return const SizedBox.shrink();
    final query = gapQueryFor(profile);
    final projected = profile.plannedCourses.isEmpty
        ? null
        : ref.watch(gapReportProvider(gapQueryFor(profile, withPlanned: true)));
    void open(Widget screen) =>
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
    return Scaffold(
      appBar: AppBar(
        title: Text(l.homeTitle),
        actions: [
          const LanguageToggle(),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l.settingsTitle,
            onPressed: () => open(const SettingsScreen()),
          ),
        ],
      ),
      body: AsyncView(
        asyncValue: ref.watch(gapReportProvider(query)),
        onRetry: () => ref.invalidate(gapReportProvider(query)),
        data: (report) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // The figures below are estimates too: the headline of the flag
            // here, all of it on the full readiness view.
            QualityBanner(validation: report.validation, compact: true),
            const SizedBox(height: 16),
            _ReadinessCard(
              report: report,
              projected: projected,
              plannedCount: profile.plannedCourses.length,
            ),
            SectionHeader(l.homeTopGaps),
            if (report.missing.isEmpty)
              Text(l.homeNoGaps)
            else
              for (final skill in report.missing.take(3))
                DemandRow(name: skill.nameFor(lang), demand: skill.demand),
            const SizedBox(height: 16),
            _Entry(
              icon: Icons.event_note_outlined,
              title: l.planTitle,
              subtitle: l.planPlannedCount(profile.plannedCourses.length),
              onTap: () => open(const PlanningScreen()),
            ),
            _Entry(
              icon: Icons.insights_outlined,
              title: l.homeFullReadiness,
              subtitle: l.homeFullReadinessHint,
              onTap: () => open(const ReadinessScreen()),
            ),
            _Entry(
              icon: Icons.settings_outlined,
              title: l.settingsTitle,
              subtitle: l.homeSettingsHint,
              onTap: () => open(const SettingsScreen()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({
    required this.report,
    required this.projected,
    required this.plannedCount,
  });

  final GapReport report;
  final AsyncValue<GapReport>? projected;
  final int plannedCount;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final projected = this.projected;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.readinessFor(careerName(l, report.career)), style: text.titleMedium),
            const SizedBox(height: 8),
            if (projected == null)
              Text(formatPercent(report.readiness, lang), style: text.displayMedium)
            else
              NowAndPlanned(now: report, projected: projected, plannedCount: plannedCount),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: report.readiness.clamp(0.0, 1.0).toDouble(),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
          // Points onward in either direction: it mirrors in right-to-left.
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );
}
