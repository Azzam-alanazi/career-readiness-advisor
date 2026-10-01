// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gap_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GapReport _$GapReportFromJson(Map<String, dynamic> json) => _GapReport(
  career: json['career'] as String,
  readiness: (json['readiness'] as num).toDouble(),
  readinessPercent: (json['readiness_percent'] as num).toInt(),
  readinessFromCourses: (json['readiness_from_courses'] as num).toDouble(),
  readinessFromCoursesPercent: (json['readiness_from_courses_percent'] as num)
      .toInt(),
  covered: (json['covered'] as List<dynamic>)
      .map((e) => SkillEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  coveredFromCourses: (json['covered_from_courses'] as List<dynamic>)
      .map((e) => SkillEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  coveredSelfReported: (json['covered_self_reported'] as List<dynamic>)
      .map((e) => SkillEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  missing: (json['missing'] as List<dynamic>)
      .map((e) => SkillEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  validation: ValidationInfo.fromJson(
    json['validation'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$GapReportToJson(_GapReport instance) =>
    <String, dynamic>{
      'career': instance.career,
      'readiness': instance.readiness,
      'readiness_percent': instance.readinessPercent,
      'readiness_from_courses': instance.readinessFromCourses,
      'readiness_from_courses_percent': instance.readinessFromCoursesPercent,
      'covered': instance.covered.map((e) => e.toJson()).toList(),
      'covered_from_courses': instance.coveredFromCourses
          .map((e) => e.toJson())
          .toList(),
      'covered_self_reported': instance.coveredSelfReported
          .map((e) => e.toJson())
          .toList(),
      'missing': instance.missing.map((e) => e.toJson()).toList(),
      'validation': instance.validation.toJson(),
    };
