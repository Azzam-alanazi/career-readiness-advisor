import 'package:career_readiness/core/domain/validation_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'curriculum_gap.freezed.dart';
part 'curriculum_gap.g.dart';

/// The department's view: the course catalog against the job postings, for one
/// career or all of them. It is about the curriculum, not about any student.
@freezed
abstract class CurriculumGap with _$CurriculumGap {
  const factory CurriculumGap({
    /// The career asked for; null for every career.
    String? career,
    required int postingCount,

    /// The share of a career's postings a skill needs to count as demanded:
    /// the same threshold a student's gap uses.
    required double minDemand,
    required int demanded,
    required int taught,

    /// taught / demanded. Each skill counts once, however many postings name it.
    required double coverage,
    required int coveragePercent,

    /// Demanded skills no course teaches, most in demand first -- the
    /// backend's order, rendered as received.
    required List<CurriculumSkill> uncovered,

    /// Skills the catalog teaches that no posting in scope names.
    required List<TaughtSkill> notAsked,

    /// Every career's coverage, whatever the scope.
    required List<CareerCoverage> perCareer,
    required ValidationInfo validation,
  }) = _CurriculumGap;

  factory CurriculumGap.fromJson(Map<String, dynamic> json) =>
      _$CurriculumGapFromJson(json);
}

@freezed
abstract class CurriculumSkill with _$CurriculumSkill {
  const CurriculumSkill._();

  const factory CurriculumSkill({
    required String id,
    required String en,
    required String ar,
    required String category,

    /// Postings in scope that name the skill, and their share of all of them.
    required int postings,
    required double demand,
    required int demandPercent,

    /// Careers in scope that count it as demanded.
    required List<String> careers,
  }) = _CurriculumSkill;

  factory CurriculumSkill.fromJson(Map<String, dynamic> json) =>
      _$CurriculumSkillFromJson(json);

  String nameFor(String languageCode) => languageCode == 'ar' ? ar : en;
}

@freezed
abstract class TaughtSkill with _$TaughtSkill {
  const TaughtSkill._();

  const factory TaughtSkill({
    required String id,
    required String en,
    required String ar,
    required String category,

    /// Codes of the catalog courses that teach it.
    required List<String> courses,
  }) = _TaughtSkill;

  factory TaughtSkill.fromJson(Map<String, dynamic> json) => _$TaughtSkillFromJson(json);

  String nameFor(String languageCode) => languageCode == 'ar' ? ar : en;
}

@freezed
abstract class CareerCoverage with _$CareerCoverage {
  const factory CareerCoverage({
    required String career,
    required int postingCount,

    /// Skills the career's postings ask for, and how many some course teaches.
    required int demanded,
    required int taught,
    required double coverage,
    required int coveragePercent,
  }) = _CareerCoverage;

  factory CareerCoverage.fromJson(Map<String, dynamic> json) =>
      _$CareerCoverageFromJson(json);
}
