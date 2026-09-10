// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'validation_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ValidationInfo _$ValidationInfoFromJson(Map<String, dynamic> json) =>
    _ValidationInfo(
      gatePassed: json['gate_passed'] as bool,
      bestF1: (json['best_f1'] as num?)?.toDouble(),
      gateMinF1: (json['gate_min_f1'] as num?)?.toDouble(),
      courseMappingValidated: json['course_mapping_validated'] as bool,
      note: json['note'] as String,
    );

Map<String, dynamic> _$ValidationInfoToJson(_ValidationInfo instance) =>
    <String, dynamic>{
      'gate_passed': instance.gatePassed,
      'best_f1': instance.bestF1,
      'gate_min_f1': instance.gateMinF1,
      'course_mapping_validated': instance.courseMappingValidated,
      'note': instance.note,
    };
