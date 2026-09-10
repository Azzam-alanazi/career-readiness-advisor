// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'career.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Career _$CareerFromJson(Map<String, dynamic> json) => _Career(
  name: json['name'] as String,
  postingCount: (json['posting_count'] as num).toInt(),
);

Map<String, dynamic> _$CareerToJson(_Career instance) => <String, dynamic>{
  'name': instance.name,
  'posting_count': instance.postingCount,
};
