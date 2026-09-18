import 'package:career_readiness/features/gap/data/gap_repository.dart';
import 'package:career_readiness/features/gap/domain/gap_query.dart';
import 'package:career_readiness/features/gap/domain/gap_report.dart';
import 'package:career_readiness/features/onboarding/presentation/catalog_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A gap per query. Queries compare by value, so the same profile content
/// read against the same career is fetched once. What the backend no longer
/// serves is left out of the request (see ServedIds).
final gapReportProvider = FutureProvider.autoDispose.family<GapReport, GapQuery>(
  (ref, query) async {
    final repository = ref.watch(gapRepositoryProvider);
    return repository.fetch(await servedQuery(ref, query));
  },
);

/// "Try again" for a gap: the catalog it is checked against too, if that is
/// what failed.
void retryGap(WidgetRef ref, GapQuery query) {
  refreshFailedCatalog(ref);
  ref.invalidate(gapReportProvider(query));
}
