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

UniversityRecommendation _$UniversityRecommendationFromJson(
  Map<String, dynamic> json,
) => UniversityRecommendation(
  code: json['code'] as String,
  name: json['name'] as String,
  closes: (json['closes'] as List<dynamic>)
      .map((e) => SkillRef.fromJson(e as Map<String, dynamic>))
      .toList(),
  value: (json['value'] as num).toDouble(),
  $type: json['source'] as String?,
);

Map<String, dynamic> _$UniversityRecommendationToJson(
  UniversityRecommendation instance,
) => <String, dynamic>{
  'code': instance.code,
  'name': instance.name,
  'closes': instance.closes.map((e) => e.toJson()).toList(),
  'value': instance.value,
  'source': instance.$type,
};

OnlineRecommendation _$OnlineRecommendationFromJson(
  Map<String, dynamic> json,
) => OnlineRecommendation(
  provider: json['provider'] as String,
  title: json['title'] as String,
  url: json['url'] as String,
  isFree: json['is_free'] as bool,
  closes: (json['closes'] as List<dynamic>)
      .map((e) => SkillRef.fromJson(e as Map<String, dynamic>))
      .toList(),
  value: (json['value'] as num).toDouble(),
  $type: json['source'] as String?,
);

Map<String, dynamic> _$OnlineRecommendationToJson(
  OnlineRecommendation instance,
) => <String, dynamic>{
  'provider': instance.provider,
  'title': instance.title,
  'url': instance.url,
  'is_free': instance.isFree,
  'closes': instance.closes.map((e) => e.toJson()).toList(),
  'value': instance.value,
  'source': instance.$type,
};

_RecommendationsReport _$RecommendationsReportFromJson(
  Map<String, dynamic> json,
) => _RecommendationsReport(
  profileId: json['profile_id'] as String?,
  career: json['career'] as String,
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => Recommendation.fromJson(e as Map<String, dynamic>))
      .toList(),
  uncovered: (json['uncovered'] as List<dynamic>)
      .map((e) => SkillRef.fromJson(e as Map<String, dynamic>))
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
  'uncovered': instance.uncovered.map((e) => e.toJson()).toList(),
  'validation': instance.validation.toJson(),
};
