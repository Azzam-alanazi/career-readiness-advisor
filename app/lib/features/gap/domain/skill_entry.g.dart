// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SkillEntry _$SkillEntryFromJson(Map<String, dynamic> json) => _SkillEntry(
  id: json['id'] as String,
  en: json['en'] as String,
  ar: json['ar'] as String,
  category: json['category'] as String,
  demand: (json['demand'] as num).toDouble(),
  demandPercent: (json['demand_percent'] as num).toInt(),
);

Map<String, dynamic> _$SkillEntryToJson(_SkillEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'ar': instance.ar,
      'category': instance.category,
      'demand': instance.demand,
      'demand_percent': instance.demandPercent,
    };
