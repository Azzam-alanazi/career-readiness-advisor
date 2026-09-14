// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'curriculum_gap.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CurriculumGap _$CurriculumGapFromJson(Map<String, dynamic> json) =>
    _CurriculumGap(
      career: json['career'] as String?,
      postingCount: (json['posting_count'] as num).toInt(),
      minDemand: (json['min_demand'] as num).toDouble(),
      demanded: (json['demanded'] as num).toInt(),
      taught: (json['taught'] as num).toInt(),
      coverage: (json['coverage'] as num).toDouble(),
      coveragePercent: (json['coverage_percent'] as num).toInt(),
      uncovered: (json['uncovered'] as List<dynamic>)
          .map((e) => CurriculumSkill.fromJson(e as Map<String, dynamic>))
          .toList(),
      notAsked: (json['not_asked'] as List<dynamic>)
          .map((e) => TaughtSkill.fromJson(e as Map<String, dynamic>))
          .toList(),
      belowThreshold: (json['below_threshold'] as List<dynamic>)
          .map((e) => BelowThresholdSkill.fromJson(e as Map<String, dynamic>))
          .toList(),
      perCareer: (json['per_career'] as List<dynamic>)
          .map((e) => CareerCoverage.fromJson(e as Map<String, dynamic>))
          .toList(),
      validation: ValidationInfo.fromJson(
        json['validation'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$CurriculumGapToJson(
  _CurriculumGap instance,
) => <String, dynamic>{
  'career': instance.career,
  'posting_count': instance.postingCount,
  'min_demand': instance.minDemand,
  'demanded': instance.demanded,
  'taught': instance.taught,
  'coverage': instance.coverage,
  'coverage_percent': instance.coveragePercent,
  'uncovered': instance.uncovered.map((e) => e.toJson()).toList(),
  'not_asked': instance.notAsked.map((e) => e.toJson()).toList(),
  'below_threshold': instance.belowThreshold.map((e) => e.toJson()).toList(),
  'per_career': instance.perCareer.map((e) => e.toJson()).toList(),
  'validation': instance.validation.toJson(),
};

_CurriculumSkill _$CurriculumSkillFromJson(Map<String, dynamic> json) =>
    _CurriculumSkill(
      id: json['id'] as String,
      en: json['en'] as String,
      ar: json['ar'] as String,
      category: json['category'] as String,
      postings: (json['postings'] as num).toInt(),
      demand: (json['demand'] as num).toDouble(),
      demandPercent: (json['demand_percent'] as num).toInt(),
      careers: (json['careers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CurriculumSkillToJson(_CurriculumSkill instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'ar': instance.ar,
      'category': instance.category,
      'postings': instance.postings,
      'demand': instance.demand,
      'demand_percent': instance.demandPercent,
      'careers': instance.careers,
    };

_TaughtSkill _$TaughtSkillFromJson(Map<String, dynamic> json) => _TaughtSkill(
  id: json['id'] as String,
  en: json['en'] as String,
  ar: json['ar'] as String,
  category: json['category'] as String,
  courses: (json['courses'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$TaughtSkillToJson(_TaughtSkill instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'ar': instance.ar,
      'category': instance.category,
      'courses': instance.courses,
    };

_BelowThresholdSkill _$BelowThresholdSkillFromJson(
  Map<String, dynamic> json,
) => _BelowThresholdSkill(
  id: json['id'] as String,
  en: json['en'] as String,
  ar: json['ar'] as String,
  category: json['category'] as String,
  postings: (json['postings'] as num).toInt(),
  careers: (json['careers'] as List<dynamic>).map((e) => e as String).toList(),
  courses: (json['courses'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$BelowThresholdSkillToJson(
  _BelowThresholdSkill instance,
) => <String, dynamic>{
  'id': instance.id,
  'en': instance.en,
  'ar': instance.ar,
  'category': instance.category,
  'postings': instance.postings,
  'careers': instance.careers,
  'courses': instance.courses,
};

_CareerCoverage _$CareerCoverageFromJson(Map<String, dynamic> json) =>
    _CareerCoverage(
      career: json['career'] as String,
      postingCount: (json['posting_count'] as num).toInt(),
      demanded: (json['demanded'] as num).toInt(),
      taught: (json['taught'] as num).toInt(),
      coverage: (json['coverage'] as num).toDouble(),
      coveragePercent: (json['coverage_percent'] as num).toInt(),
      minPostings: (json['min_postings'] as num).toInt(),
    );

Map<String, dynamic> _$CareerCoverageToJson(_CareerCoverage instance) =>
    <String, dynamic>{
      'career': instance.career,
      'posting_count': instance.postingCount,
      'demanded': instance.demanded,
      'taught': instance.taught,
      'coverage': instance.coverage,
      'coverage_percent': instance.coveragePercent,
      'min_postings': instance.minPostings,
    };
