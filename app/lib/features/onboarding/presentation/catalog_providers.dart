import 'package:career_readiness/features/gap/domain/gap_query.dart';
import 'package:career_readiness/features/onboarding/data/catalog_repository.dart';
import 'package:career_readiness/features/onboarding/domain/career.dart';
import 'package:career_readiness/features/onboarding/domain/course.dart';
import 'package:career_readiness/features/onboarding/domain/served_ids.dart';
import 'package:career_readiness/features/onboarding/domain/skill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final careersProvider = FutureProvider<List<Career>>(
  (ref) => ref.watch(catalogRepositoryProvider).careers(),
);

final coursesProvider = FutureProvider<List<Course>>(
  (ref) => ref.watch(catalogRepositoryProvider).courses(),
);

final skillsProvider = FutureProvider<List<Skill>>(
  (ref) => ref.watch(catalogRepositoryProvider).skills(),
);

/// Every id the backend serves now, for checking a saved profile against.
final servedIdsProvider = FutureProvider<ServedIds>((ref) async {
  // All three requested before any is awaited, so they travel together.
  final careers = ref.watch(careersProvider.future);
  final courses = ref.watch(coursesProvider.future);
  final skills = ref.watch(skillsProvider.future);
  return ServedIds(
    careers: {for (final c in await careers) c.name},
    courses: {for (final c in await courses) c.code},
    skills: {for (final s in await skills) s.id},
  );
});

/// [query] as the backend can serve it, once the catalog is in: see ServedIds.
Future<GapQuery> servedQuery(Ref ref, GapQuery query) async =>
    (await ref.watch(servedIdsProvider.future)).restrictQuery(query);

/// Fetches the catalog again wherever it failed. Automatic retry is off, so a
/// failed catalog request stays failed until something asks again; every
/// "try again" that depends on the catalog goes through here.
void refreshFailedCatalog(WidgetRef ref) {
  var failed = false;
  for (final provider in [careersProvider, coursesProvider, skillsProvider]) {
    if (ref.read(provider).hasError) {
      ref.invalidate(provider);
      failed = true;
    }
  }
  if (failed || ref.read(servedIdsProvider).hasError) ref.invalidate(servedIdsProvider);
}
