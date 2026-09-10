import 'package:career_readiness/features/recommendations/data/recommendations_repository.dart';
import 'package:career_readiness/features/recommendations/domain/recommendation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recommendationsProvider =
    FutureProvider.autoDispose.family<RecommendationsReport, String>(
  (ref, profileId) => ref.watch(recommendationsRepositoryProvider).fetch(profileId),
);
