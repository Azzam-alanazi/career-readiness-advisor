// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['id'] as String,
  career: json['career'] as String,
  major: json['major'] as String?,
  completedCourses: (json['completed_courses'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  selfReportedSkills:
      (json['self_reported_skills'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'career': instance.career,
  'major': instance.major,
  'completed_courses': instance.completedCourses,
  'self_reported_skills': instance.selfReportedSkills,
  'created_at': instance.createdAt,
};
