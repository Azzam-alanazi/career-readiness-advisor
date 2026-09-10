import 'package:career_readiness/features/onboarding/domain/onboarding_state.dart';
import 'package:career_readiness/features/profile/data/profile_repository.dart';
import 'package:career_readiness/features/profile/domain/profile_draft.dart';
import 'package:career_readiness/features/profile/presentation/current_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void setMajor(String value) => state = state.copyWith(major: value);

  void selectCareer(String career) =>
      state = state.copyWith(career: career, error: null);

  void toggleCourse(String code) {
    final courses = {...state.courses};
    if (!courses.remove(code)) courses.add(code);
    state = state.copyWith(courses: courses);
  }

  /// Saves the profile and makes it current. Returns the new profile id, or
  /// null on failure -- the error stays in state for the screen to show.
  Future<String?> submit() async {
    if (!state.canSubmit) return null;
    state = state.copyWith(submitting: true, error: null);
    final major = state.major.trim();
    try {
      final profile = await ref.read(profileRepositoryProvider).create(
            ProfileDraft(
              career: state.career!,
              completedCourses: state.courses.toList()..sort(),
              // A blank field means "not given", not a major called "".
              major: major.isEmpty ? null : major,
            ),
          );
      if (!ref.mounted) return null;
      ref.read(currentProfileProvider.notifier).set(profile.id);
      state = state.copyWith(submitting: false);
      return profile.id;
    } catch (e) {
      if (ref.mounted) state = state.copyWith(submitting: false, error: e);
      return null;
    }
  }

  /// Start over: forget the draft and the current profile.
  void reset() {
    ref.read(currentProfileProvider.notifier).clear();
    state = OnboardingState(revision: state.revision + 1);
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(OnboardingController.new);
