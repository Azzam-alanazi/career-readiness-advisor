import 'package:career_readiness/features/onboarding/domain/onboarding_state.dart';
import 'package:career_readiness/features/profile/domain/student_profile.dart';
import 'package:career_readiness/features/profile/presentation/saved_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The profile being written, first in onboarding and later when it is edited
/// from settings. Nothing leaves the device: finishing saves it locally.
class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  /// Starts editing [profile]: the form opens holding everything it says.
  void startEditing(StudentProfile profile) => state = OnboardingState(
        major: profile.major ?? '',
        careers: [...profile.careers],
        courses: {...profile.completedCourses},
        selfReported: {...profile.selfReportedSkills},
        editing: true,
        // A new revision rebuilds the fields that keep their own text.
        revision: state.revision + 1,
      );

  void setMajor(String value) => state = state.copyWith(major: value);

  /// Adds a career, or lets it go if already chosen. A fourth is ignored: the
  /// screen disables the rest once three are chosen.
  void toggleCareer(String career) {
    final careers = [...state.careers];
    if (!careers.remove(career)) {
      if (careers.length >= OnboardingState.maxCareers) return;
      careers.add(career);
    }
    state = state.copyWith(careers: careers, error: null);
  }

  void toggleCourse(String code) {
    final courses = {...state.courses};
    if (!courses.remove(code)) courses.add(code);
    state = state.copyWith(courses: courses);
  }

  /// Adds every one of [codes]; what is already chosen stays chosen.
  void selectCourses(Iterable<String> codes) =>
      state = state.copyWith(courses: {...state.courses, ...codes});

  /// Replaces the whole selection: for clearing it, and for undoing that.
  void setCourses(Set<String> codes) => state = state.copyWith(courses: {...codes});

  void toggleSkill(String id) {
    final skills = {...state.selfReported};
    if (!skills.remove(id)) skills.add(id);
    state = state.copyWith(selfReported: skills);
  }

  /// Saves the profile on this device. Returns whether it was saved; on a
  /// failure the error stays in state for the screen to show.
  ///
  /// Self-reported skills go as ticked. If one is also taught by a chosen
  /// course, the backend credits it to the course: the academic record wins.
  Future<bool> finish() async {
    if (!state.canSubmit) return false;
    state = state.copyWith(submitting: true, error: null);
    final major = state.major.trim();
    try {
      await ref.read(savedProfileProvider.notifier).save(StudentProfile(
            careers: [...state.careers],
            completedCourses: state.courses.toList()..sort(),
            selfReportedSkills: state.selfReported.toList()..sort(),
            // A blank field means "not given", not a major called "".
            major: major.isEmpty ? null : major,
          ));
      if (!ref.mounted) return false;
      // Saved: the draft has done its job. Editing again starts from the profile.
      reset();
      return true;
    } catch (e) {
      if (ref.mounted) state = state.copyWith(submitting: false, error: e);
      return false;
    }
  }

  /// Forgets the draft.
  void reset() => state = OnboardingState(revision: state.revision + 1);
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(OnboardingController.new);
