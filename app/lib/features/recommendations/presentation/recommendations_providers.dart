import 'package:career_readiness/features/gap/domain/gap_query.dart';
import 'package:career_readiness/features/recommendations/data/recommendations_repository.dart';
import 'package:career_readiness/features/recommendations/domain/recommendation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Suggestions for a profile read against one of its careers.
final recommendationsProvider =
    FutureProvider.autoDispose.family<RecommendationsReport, GapQuery>(
  (ref, query) => ref.watch(recommendationsRepositoryProvider).fetch(query),
);
