import 'package:career_readiness/core/format.dart';
import 'package:career_readiness/core/l10n/career_names.dart';
import 'package:career_readiness/core/links.dart';
import 'package:career_readiness/core/theme/app_theme.dart';
import 'package:career_readiness/core/widgets/app_page.dart';
import 'package:career_readiness/core/widgets/async_view.dart';
import 'package:career_readiness/core/widgets/grouped.dart';
import 'package:career_readiness/core/widgets/quality_banner.dart';
import 'package:career_readiness/core/widgets/toast.dart';
import 'package:career_readiness/features/gap/domain/gap_query.dart';
import 'package:career_readiness/features/profile/presentation/saved_profile.dart';
import 'package:career_readiness/features/recommendations/domain/recommendation.dart';
import 'package:career_readiness/features/recommendations/presentation/recommendations_providers.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
// Selectable text has no Cupertino twin; it takes the platform's own
// selection handles and menu.
import 'package:flutter/material.dart' show SelectableText;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key, required this.career});

  /// The career the suggestions close gaps for: one of the profile's.
  final String career;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final profile = ref.watch(servedProfileProvider);
    if (profile == null) return const SizedBox.shrink();
    final query = gapQueryFor(profile, career: career);
    return AppPage(
      title: l.recommendationsTitle,
      slivers: [
        AsyncSliver(
          asyncValue: ref.watch(recommendationsProvider(query)),
          onRetry: () => retryRecommendations(ref, query),
          data: (report) => _Suggestions(report: report, career: career),
        ),
      ],
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.report, required this.career});

  final RecommendationsReport report;
  final String career;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final university = report.university;
    final online = report.online;
    return PageContent(
      children: [
        // Which career these are for: with several compared, it is not obvious.
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 12),
          child: Text(l.recommendationsFor(careerName(l, career)),
              style: AppType.of(context).title3),
        ),
        // Then, above every course: these are suggestions, not verdicts.
        NoticeCard(
          icon: CupertinoIcons.lightbulb_fill,
          color: AppColors.tint,
          title: l.suggestionTitle,
          lines: [l.suggestionBody],
        ),
        const SizedBox(height: 12),
        QualityBanner(validation: report.validation),

        // University courses count toward the degree, so they come first.
        _SourceHeader(
          icon: CupertinoIcons.book_fill,
          title: l.universityCoursesTitle(university.length),
          note: l.universityCoursesNote,
        ),
        if (university.isEmpty)
          _EmptyNote(l.noRecommendations)
        else
          for (final (i, course) in university.indexed)
            _Spaced(_UniversityCard(rank: i + 1, course: course)),

        _SourceHeader(
          icon: CupertinoIcons.globe,
          title: l.onlineCoursesTitle(online.length),
          note: l.onlineCoursesNote,
        ),
        if (online.isEmpty)
          _EmptyNote(l.noOnlineCourses)
        else
          for (final course in online) _Spaced(_OnlineCard(course: course)),

        if (report.uncovered.isNotEmpty) ...[
          const SizedBox(height: 16),
          _UncoveredCard(skills: report.uncovered),
        ],
      ],
    );
  }
}

class _Spaced extends StatelessWidget {
  const _Spaced(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.only(bottom: 12), child: child);
}

class _SourceHeader extends StatelessWidget {
  const _SourceHeader({required this.icon, required this.title, required this.note});

  final IconData icon;
  final String title;
  final String note;

  @override
  Widget build(BuildContext context) {
    final type = AppType.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4, 28, 4, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 22, color: CupertinoTheme.of(context).primaryColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(header: true, child: Text(title, style: type.title3)),
                const SizedBox(height: 2),
                Text(note, style: type.footnote),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  const _EmptyNote(this.message);

  final String message;

  @override
  Widget build(BuildContext context) =>
      Panel(child: Text(message, style: AppType.of(context).subheadline));
}

/// Whether a course counts toward the degree, on every card, so a card read on
/// its own still says so.
class _DegreeBadge extends StatelessWidget {
  const _DegreeBadge({required this.counts});

  final bool counts;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Tag(
      icon: counts ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.minus_circle,
      color: counts ? AppColors.credit : null,
      label: counts ? l.countsTowardDegree : l.notTowardDegree,
    );
  }
}

class _SkillTags extends StatelessWidget {
  const _SkillTags(this.skills);

  final List<SkillRef> skills;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return TagWrap(
      children: [
        for (final skill in skills)
          Tag(
            label: '${skill.nameFor(lang)} · '
                '${l.demandShare(formatPercent(skill.demandPercent / 100, lang))}',
          ),
      ],
    );
  }
}

/// The round mark at the start of a card: the course's rank, or a globe.
class _Mark extends StatelessWidget {
  const _Mark({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tint = CupertinoTheme.of(context).primaryColor;
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: tint.withValues(alpha: 0.14), shape: BoxShape.circle),
      child: IconTheme(
        data: IconThemeData(color: tint, size: 17),
        child: DefaultTextStyle.merge(
          style: AppType.of(context).subheadlineEmphasis.copyWith(color: tint),
          child: child,
        ),
      ),
    );
  }
}

class _UniversityCard extends StatelessWidget {
  const _UniversityCard({required this.rank, required this.course});

  final int rank;
  final UniversityRecommendation course;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final type = AppType.of(context);
    return Panel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Mark(child: Text(formatNumber(rank, lang))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.name, style: type.headline),
                Text(course.code, style: type.footnote),
                const SizedBox(height: 10),
                const _DegreeBadge(counts: true),
                const SizedBox(height: 12),
                Text(l.couldHelpWith, style: type.footnoteEmphasis),
                const SizedBox(height: 6),
                _SkillTags(course.closes),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnlineCard extends ConsumerWidget {
  const _OnlineCard({required this.course});

  final OnlineRecommendation course;

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final failed = AppLocalizations.of(context).openCourseFailed;
    if (!await ref.read(linkOpenerProvider)(course.url) && context.mounted) {
      showToast(context, failed);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final type = AppType.of(context);
    return Panel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Mark(child: Icon(CupertinoIcons.globe)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title, style: type.headline),
                Text(course.provider, style: type.footnote),
                const SizedBox(height: 10),
                TagWrap(
                  children: [
                    const _DegreeBadge(counts: false),
                    Tag(label: course.isFree ? l.free : l.paid),
                  ],
                ),
                const SizedBox(height: 10),
                // A web address reads left to right in either language.
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: SelectableText(
                    course.url,
                    // Selectable text asks for a baseline the system styles leave unset.
                    style: type.footnote.copyWith(
                      color: CupertinoTheme.of(context).primaryColor,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // One tap to the course, rather than copying the address by hand.
                CupertinoButton.tinted(
                  sizeStyle: CupertinoButtonSize.small,
                  onPressed: () => _open(context, ref),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.arrow_up_right_square, size: 17),
                      const SizedBox(width: 6),
                      Text(l.openCourse),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(l.couldHelpWith, style: type.footnoteEmphasis),
                const SizedBox(height: 6),
                _SkillTags(course.closes),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UncoveredCard extends StatelessWidget {
  const _UncoveredCard({required this.skills});

  final List<SkillRef> skills;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final type = AppType.of(context);
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.question_circle,
                  size: 20, color: AppColors.secondaryLabel.resolveFrom(context)),
              const SizedBox(width: 8),
              Expanded(child: Text(l.uncoveredTitle(skills.length), style: type.headline)),
            ],
          ),
          const SizedBox(height: 6),
          Text(l.uncoveredBody, style: type.subheadline),
          const SizedBox(height: 10),
          _SkillTags(skills),
        ],
      ),
    );
  }
}
