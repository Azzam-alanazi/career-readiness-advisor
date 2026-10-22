import 'package:career_readiness/core/format.dart';
import 'package:career_readiness/core/l10n/career_names.dart';
import 'package:career_readiness/core/theme/app_theme.dart';
import 'package:career_readiness/core/widgets/grouped.dart';
import 'package:career_readiness/core/widgets/readiness_ring.dart';
import 'package:career_readiness/core/widgets/share_bar.dart';
import 'package:career_readiness/features/gap/domain/gap_report.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Readiness for one career at a glance: the ring, and beside it the figure,
/// or today's figure and the projection when courses are planned. Home and
/// the readiness view both lead with it.
class ReadinessCard extends StatelessWidget {
  const ReadinessCard({
    super.key,
    required this.report,
    required this.projected,
    required this.plannedCount,
    this.footer = const [],
  });

  final GapReport report;

  /// The same reading with the planned courses counted, when any are planned.
  final AsyncValue<GapReport>? projected;
  final int plannedCount;

  /// Lines under the figures: what they mean, and the record on its own.
  final List<Widget> footer;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final type = AppType.of(context);
    final projected = this.projected;
    return Panel(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.readinessFor(careerName(l, report.career)), style: type.headline),
          const SizedBox(height: 14),
          Row(
            children: [
              ReadinessRing(now: report.readiness, planned: projected?.value?.readiness),
              const SizedBox(width: 18),
              Expanded(
                // With a plan, today's figure and the projection side by side.
                child: projected == null
                    ? Figure(formatPercent(report.readiness, lang), style: type.hero)
                    : NowAndPlanned(now: report, projected: projected, plannedCount: plannedCount),
              ),
            ],
          ),
          for (final line in footer) ...[const SizedBox(height: 10), line],
        ],
      ),
    );
  }
}

/// A figure that shrinks to fit rather than breaking across lines: at large
/// text sizes "48%" stays one number.
class Figure extends StatelessWidget {
  const Figure(this.text, {super.key, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Text(text, style: style, maxLines: 1),
      );
}

/// A readiness figure with what it describes underneath.
class ReadinessFigure extends StatelessWidget {
  const ReadinessFigure({super.key, required this.value, required this.caption, this.large = false});

  final double value;
  final String caption;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final type = AppType.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Figure(formatPercent(value, lang), style: large ? type.hero : type.figure),
        Text(caption, style: type.footnote),
      ],
    );
  }
}

/// "31% now, 48% if you take your planned courses", side by side, with the
/// gain in points. Shared by home, planning and the readiness view.
class NowAndPlanned extends StatelessWidget {
  const NowAndPlanned({
    super.key,
    required this.now,
    required this.projected,
    required this.plannedCount,
  });

  final GapReport now;
  final AsyncValue<GapReport> projected;
  final int plannedCount;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: ReadinessFigure(value: now.readiness, caption: l.planNow)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          // Points from now to the plan, in the reading direction.
          child: Icon(
            rtl ? CupertinoIcons.arrow_left : CupertinoIcons.arrow_right,
            size: 18,
            color: AppColors.tertiaryLabel.resolveFrom(context),
          ),
        ),
        Expanded(
          child: switch (projected) {
            AsyncData(:final value) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReadinessFigure(value: value.readiness, caption: l.planWith(plannedCount)),
                  if (value.readinessPercent > now.readinessPercent) ...[
                    const SizedBox(height: 6),
                    Tag(
                      icon: CupertinoIcons.arrow_up,
                      color: AppColors.credit,
                      label: l.planPoints(value.readinessPercent - now.readinessPercent),
                    ),
                  ],
                ],
              ),
            AsyncError() => Text(l.errorServer, style: AppType.of(context).footnote),
            _ => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CupertinoActivityIndicator(),
              ),
          },
        ),
      ],
    );
  }
}

/// A missing skill with the share of postings that ask for it, as a row of a
/// [Section]. The bar is indigo: it measures the market, not the student.
class DemandRow extends StatelessWidget {
  const DemandRow({super.key, required this.name, required this.demand});

  final String name;
  final double demand;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final type = AppType.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 11, 16, 12),
      // Read as one line: the skill, then how many postings ask for it.
      child: MergeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name and share on one line when they fit; at large text sizes
            // the share moves under the name instead of overflowing.
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Text(name, style: type.body),
                Text(l.demandShare(formatPercent(demand, lang)), style: type.footnote),
              ],
            ),
            const SizedBox(height: 8),
            ShareBar(demand, color: AppColors.demand),
          ],
        ),
      ),
    );
  }
}
