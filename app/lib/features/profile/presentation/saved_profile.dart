import 'package:career_readiness/features/onboarding/presentation/catalog_providers.dart';
import 'package:career_readiness/features/profile/data/profile_store.dart';
import 'package:career_readiness/features/profile/domain/student_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The profile saved on this device, or null before the first onboarding.
/// Read once at launch; every change goes through here, so the screens that
/// watch it follow.
class SavedProfile extends Notifier<StudentProfile?> {
  @override
  StudentProfile? build() => ref.watch(profileStoreProvider).load();

  Future<void> save(StudentProfile profile) async {
    await ref.read(profileStoreProvider).save(profile);
    state = profile;
  }

  /// Plans [code], or takes it off the plan. Saved at once.
  ///
  /// The new plan is shown before the write finishes, so a second tap builds
  /// on the first instead of on the plan as it stood before either: waiting
  /// for the write lost the first of two quick taps. A failed write puts the
  /// plan back and rethrows.
  Future<void> togglePlanned(String code) async {
    final before = state;
    if (before == null) return;
    final planned = {...before.plannedCourses};
    if (!planned.remove(code)) planned.add(code);
    final after = before.copyWith(plannedCourses: planned.toList()..sort());
    state = after;
    try {
      await ref.read(profileStoreProvider).save(after);
    } catch (_) {
      // Only if nothing has changed since: a later tap's plan stands.
      if (ref.mounted && identical(state, after)) state = before;
      rethrow;
    }
  }

  Future<void> clear() async {
    await ref.read(profileStoreProvider).clear();
    state = null;
  }
}

final savedProfileProvider =
    NotifierProvider<SavedProfile, StudentProfile?>(SavedProfile.new);

/// The saved profile as the backend can read it now, which is what the screens
/// show: less any course, skill or career it has since dropped (see
/// ServedIds). A dropped main career gives way to the next one, as it does for
/// a stored profile on the backend, and a dropped planned course stops being
/// counted in the plan.
///
/// It is the saved profile itself until the catalog is in, and whenever no
/// career at all would be left: then there is nothing to read it against, and
/// the screens say so. Changes still go through [savedProfileProvider].
final servedProfileProvider = Provider<StudentProfile?>((ref) {
  final profile = ref.watch(savedProfileProvider);
  final served = ref.watch(servedIdsProvider).value;
  if (profile == null || served == null) return profile;
  final stillServed = served.restrictProfile(profile);
  return stillServed.careers.isEmpty ? profile : stillServed;
});
