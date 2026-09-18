import 'package:career_readiness/features/gap/domain/gap_query.dart';
import 'package:career_readiness/features/onboarding/presentation/catalog_providers.dart';
import 'package:career_readiness/features/recommendations/data/recommendations_repository.dart';
import 'package:career_readiness/features/recommendations/domain/recommendation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Suggestions for a profile read against one of its careers. What the
/// backend no longer serves is left out of the request (see ServedIds).
final recommendationsProvider =
    FutureProvider.autoDispose.family<RecommendationsReport, GapQuery>(
  (ref, query) async {
    final repository = ref.watch(recommendationsRepositoryProvider);
    return repository.fetch(await servedQuery(ref, query));
  },
);

/// "Try again" for suggestions: the catalog too, if that is what failed.
void retryRecommendations(WidgetRef ref, GapQuery query) {
  refreshFailedCatalog(ref);
  ref.invalidate(recommendationsProvider(query));
}
