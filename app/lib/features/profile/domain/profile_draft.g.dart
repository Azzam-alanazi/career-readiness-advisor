// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfileDraft _$ProfileDraftFromJson(Map<String, dynamic> json) =>
    _ProfileDraft(
      career: json['career'] as String,
      completedCourses: (json['completed_courses'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      selfReportedSkills:
          (json['self_reported_skills'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      major: json['major'] as String?,
    );

Map<String, dynamic> _$ProfileDraftToJson(_ProfileDraft instance) =>
    <String, dynamic>{
      'career': instance.career,
      'completed_courses': instance.completedCourses,
      'self_reported_skills': instance.selfReportedSkills,
      'major': instance.major,
    };
