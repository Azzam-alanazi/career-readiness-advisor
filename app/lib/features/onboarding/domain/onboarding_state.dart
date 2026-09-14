import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

@freezed
abstract class OnboardingState with _$OnboardingState {
  const OnboardingState._();

  /// Enough to compare side by side on a phone, and no more.
  static const maxCareers = 3;

  const factory OnboardingState({
    @Default('') String major,

    /// Target careers in the order chosen, at most [maxCareers]. The first is
    /// the one the readiness screen opens on.
    @Default(<String>[]) List<String> careers,
    @Default(<String>{}) Set<String> courses,

    /// Skill ids the student holds from outside coursework. Unverified, and
    /// empty until they tick one.
    @Default(<String>{}) Set<String> selfReported,
    @Default(false) bool submitting,
    Object? error,

    /// Bumped on reset, so the screen can rebuild fields that keep their own
    /// text (the major) instead of showing a value the draft no longer holds.
    @Default(0) int revision,
  }) = _OnboardingState;

  /// A career is the one thing the backend cannot do without. Zero courses and
  /// zero self-reported skills are valid answers.
  bool get canSubmit => careers.isNotEmpty && !submitting;
}
