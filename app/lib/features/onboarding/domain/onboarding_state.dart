import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

@freezed
abstract class OnboardingState with _$OnboardingState {
  const OnboardingState._();

  const factory OnboardingState({
    @Default('') String major,
    String? career,
    @Default(<String>{}) Set<String> courses,
    @Default(false) bool submitting,
    Object? error,

    /// Bumped on reset, so the screen can rebuild fields that keep their own
    /// text (the major) instead of showing a value the draft no longer holds.
    @Default(0) int revision,
  }) = _OnboardingState;

  /// A career is the one thing the backend cannot do without. Zero courses is
  /// a valid answer: it means readiness starts at 0%.
  bool get canSubmit => career != null && !submitting;
}
