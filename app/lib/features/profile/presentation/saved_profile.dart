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

  Future<void> clear() async {
    await ref.read(profileStoreProvider).clear();
    state = null;
  }
}

final savedProfileProvider =
    NotifierProvider<SavedProfile, StudentProfile?>(SavedProfile.new);
