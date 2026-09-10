// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SkillRef _$SkillRefFromJson(Map<String, dynamic> json) => _SkillRef(
  id: json['id'] as String,
  en: json['en'] as String,
  ar: json['ar'] as String,
  demandPercent: (json['demand_percent'] as num).toInt(),
);

Map<String, dynamic> _$SkillRefToJson(_SkillRef instance) => <String, dynamic>{
  'id': instance.id,
  'en': instance.en,
  'ar': instance.ar,
  'demand_percent': instance.demandPercent,
};

_Recommendation _$RecommendationFromJson(Map<String, dynamic> json) =>
    _Recommendation(
      code: json['code'] as String,
      name: json['name'] as String,
      closes: (json['closes'] as List<dynamic>)
          .map((e) => SkillRef.fromJson(e as Map<String, dynamic>))
          .toList(),
      value: (json['value'] as num).toDouble(),
    );

Map<String, dynamic> _$RecommendationToJson(_Recommendation instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'closes': instance.closes.map((e) => e.toJson()).toList(),
      'value': instance.value,
    };

_RecommendationsReport _$RecommendationsReportFromJson(
  Map<String, dynamic> json,
) => _RecommendationsReport(
  profileId: json['profile_id'] as String,
  career: json['career'] as String,
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => Recommendation.fromJson(e as Map<String, dynamic>))
      .toList(),
  validation: ValidationInfo.fromJson(
    json['validation'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$RecommendationsReportToJson(
  _RecommendationsReport instance,
) => <String, dynamic>{
  'profile_id': instance.profileId,
  'career': instance.career,
  'recommendations': instance.recommendations.map((e) => e.toJson()).toList(),
  'validation': instance.validation.toJson(),
};
