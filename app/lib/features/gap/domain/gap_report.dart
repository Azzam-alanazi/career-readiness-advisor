import 'package:career_readiness/core/domain/validation_info.dart';
import 'package:career_readiness/features/gap/domain/skill_entry.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'gap_report.freezed.dart';
part 'gap_report.g.dart';

@freezed
abstract class GapReport with _$GapReport {
  const factory GapReport({
    required String profileId,
    required String career,

    /// Demand-weighted share of the career's required skills the student has,
    /// from courses and self-reported skills together.
    required double readiness,
    required int readinessPercent,

    /// The same share from completed courses alone: the academic record.
    required double readinessFromCourses,
    required int readinessFromCoursesPercent,

    /// Both sources together, each entry marked with its source.
    required List<SkillEntry> covered,

    /// The covered skills split by source. Together they make up [covered].
    required List<SkillEntry> coveredFromCourses,
    required List<SkillEntry> coveredSelfReported,

    /// Ranked by demand, highest first -- the backend's contract, rendered
    /// in the order received.
    required List<SkillEntry> missing,
    required ValidationInfo validation,
  }) = _GapReport;

  factory GapReport.fromJson(Map<String, dynamic> json) =>
      _$GapReportFromJson(json);
}
