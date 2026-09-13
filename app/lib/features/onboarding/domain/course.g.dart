// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Course _$CourseFromJson(Map<String, dynamic> json) => _Course(
  code: json['code'] as String,
  name: json['name'] as String,
  skillCount: (json['skill_count'] as num).toInt(),
  skills:
      (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$CourseToJson(_Course instance) => <String, dynamic>{
  'code': instance.code,
  'name': instance.name,
  'skill_count': instance.skillCount,
  'skills': instance.skills,
};
