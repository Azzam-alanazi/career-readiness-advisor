// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StudentProfile _$StudentProfileFromJson(Map<String, dynamic> json) =>
    _StudentProfile(
      careers: (json['careers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
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
      major: json['major'] as String?,
    );

Map<String, dynamic> _$StudentProfileToJson(_StudentProfile instance) =>
    <String, dynamic>{
      'careers': instance.careers,
      'completed_courses': instance.completedCourses,
      'self_reported_skills': instance.selfReportedSkills,
      'major': instance.major,
    };
