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
  Future<void> togglePlanned(String code) async {
    final profile = state;
    if (profile == null) return;
    final planned = {...profile.plannedCourses};
    if (!planned.remove(code)) planned.add(code);
    await save(profile.copyWith(plannedCourses: planned.toList()..sort()));
  }

  Future<void> clear() async {
    await ref.read(profileStoreProvider).clear();
    state = null;
  }
}

final savedProfileProvider =
    NotifierProvider<SavedProfile, StudentProfile?>(SavedProfile.new);
