// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gap_query.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GapQuery _$GapQueryFromJson(Map<String, dynamic> json) => _GapQuery(
  career: json['career'] as String,
  completedCourses:
      (json['completed_courses'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  selfReportedSkills:
      (json['self_reported_skills'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$GapQueryToJson(_GapQuery instance) => <String, dynamic>{
  'career': instance.career,
  'completed_courses': instance.completedCourses,
  'self_reported_skills': instance.selfReportedSkills,
};
