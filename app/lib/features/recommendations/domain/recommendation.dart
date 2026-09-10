import 'package:career_readiness/core/domain/validation_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'recommendation.freezed.dart';
part 'recommendation.g.dart';

@freezed
abstract class SkillRef with _$SkillRef {
  const SkillRef._();

  const factory SkillRef({
    required String id,
    required String en,
    required String ar,
    required int demandPercent,
  }) = _SkillRef;

  factory SkillRef.fromJson(Map<String, dynamic> json) => _$SkillRefFromJson(json);

  String nameFor(String languageCode) => languageCode == 'ar' ? ar : en;
}

@freezed
abstract class Recommendation with _$Recommendation {
  const factory Recommendation({
    required String code,
    required String name,
    required List<SkillRef> closes,

    /// Total demand of the gaps this course closes; the backend ranks by it.
    required double value,
  }) = _Recommendation;

  factory Recommendation.fromJson(Map<String, dynamic> json) =>
      _$RecommendationFromJson(json);
}

@freezed
abstract class RecommendationsReport with _$RecommendationsReport {
  const factory RecommendationsReport({
    required String profileId,
    required String career,
    required List<Recommendation> recommendations,
    required ValidationInfo validation,
  }) = _RecommendationsReport;

  factory RecommendationsReport.fromJson(Map<String, dynamic> json) =>
      _$RecommendationsReportFromJson(json);
}
