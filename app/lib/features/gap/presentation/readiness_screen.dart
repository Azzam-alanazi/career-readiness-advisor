import 'package:career_readiness/core/format.dart';
import 'package:career_readiness/core/l10n/career_names.dart';
import 'package:career_readiness/core/widgets/async_view.dart';
import 'package:career_readiness/core/widgets/language_toggle.dart';
import 'package:career_readiness/core/widgets/quality_banner.dart';
import 'package:career_readiness/core/widgets/section_header.dart';
import 'package:career_readiness/features/gap/domain/gap_report.dart';
import 'package:career_readiness/features/gap/presentation/gap_providers.dart';
import 'package:career_readiness/features/recommendations/presentation/recommendations_screen.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadinessScreen extends ConsumerWidget {
  const ReadinessScreen({super.key, required this.profileId});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.readinessTitle),
        actions: const [LanguageToggle()],
      ),
      body: AsyncView(
        asyncValue: ref.watch(gapReportProvider(profileId)),
        onRetry: () => ref.invalidate(gapReportProvider(profileId)),
        data: (report) => _Report(report: report),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => RecommendationsScreen(profileId: profileId),
              ),
            ),
            icon: const Icon(Icons.school_outlined),
            label: Text(l.seeRecommendations),
          ),
        ),
      ),
    );
  }
}

class _Report extends StatelessWidget {
  const _Report({required this.report});

  final GapReport report;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        QualityBanner(validation: report.validation),
        const SizedBox(height: 16),
        Text(
          l.readinessFor(careerName(l, report.career)),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        _ScoreCard(readiness: report.readiness),
        SectionHeader(l.coveredTitle(report.covered.length)),
        if (report.covered.isEmpty)
          Text(l.noneCovered)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final skill in report.covered)
                Chip(
                  avatar: const Icon(Icons.check, size: 18),
                  label: Text(skill.nameFor(lang)),
                ),
            ],
          ),
        SectionHeader(l.missingTitle(report.missing.length)),
        for (final skill in report.missing)
          _DemandRow(name: skill.nameFor(lang), demand: skill.demand),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.readiness});

  final double readiness;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formatPercent(readiness, lang), style: text.displayMedium),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: readiness.clamp(0.0, 1.0).toDouble(),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(l.readinessExplained, style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _DemandRow extends StatelessWidget {
  const _DemandRow({required this.name, required this.demand});

  final String name;
  final double demand;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(name)),
              const SizedBox(width: 8),
              Text(
                l.demandShare(formatPercent(demand, lang)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: demand.clamp(0.0, 1.0).toDouble()),
        ],
      ),
    );
  }
}
