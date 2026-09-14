import 'package:career_readiness/features/recommendations/data/recommendations_repository.dart';
import 'package:career_readiness/features/recommendations/domain/recommendation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Suggestions for a profile, for one of its careers.
typedef RecommendationsKey = ({String profileId, String career});

final recommendationsProvider =
    FutureProvider.autoDispose.family<RecommendationsReport, RecommendationsKey>(
  (ref, key) =>
      ref.watch(recommendationsRepositoryProvider).fetch(key.profileId, career: key.career),
);
