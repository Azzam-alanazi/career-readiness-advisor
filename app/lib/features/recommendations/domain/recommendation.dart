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

/// Where to learn a missing skill. The backend offers a university course for
/// every skill the catalog teaches, and an online course only for a skill it
/// does not.
@Freezed(unionKey: 'source')
sealed class Recommendation with _$Recommendation {
  const Recommendation._();

  /// A course from the university catalog. It counts toward the degree.
  @FreezedUnionValue('university')
  const factory Recommendation.university({
    required String code,
    required String name,
    required List<SkillRef> closes,

    /// Total demand of the gaps this course closes; the backend ranks by it.
    required double value,
  }) = UniversityRecommendation;

  /// An online course. It does not count toward the degree.
  @FreezedUnionValue('online')
  const factory Recommendation.online({
    required String provider,
    required String title,
    required String url,
    required bool isFree,
    required List<SkillRef> closes,
    required double value,
  }) = OnlineRecommendation;

  factory Recommendation.fromJson(Map<String, dynamic> json) =>
      _$RecommendationFromJson(json);

  bool get countsTowardDegree => this is UniversityRecommendation;
}

@freezed
abstract class RecommendationsReport with _$RecommendationsReport {
  const RecommendationsReport._();

  const factory RecommendationsReport({
    required String career,

    /// University courses first, then online ones, each ranked by value.
    required List<Recommendation> recommendations,

    /// Missing skills no university course teaches and no online course is
    /// listed for yet.
    required List<SkillRef> uncovered,
    required ValidationInfo validation,
  }) = _RecommendationsReport;

  factory RecommendationsReport.fromJson(Map<String, dynamic> json) =>
      _$RecommendationsReportFromJson(json);

  List<UniversityRecommendation> get university =>
      recommendations.whereType<UniversityRecommendation>().toList();

  List<OnlineRecommendation> get online =>
      recommendations.whereType<OnlineRecommendation>().toList();
}
