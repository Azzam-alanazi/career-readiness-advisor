import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_draft.freezed.dart';
part 'profile_draft.g.dart';

/// What onboarding sends to POST /profiles.
@freezed
abstract class ProfileDraft with _$ProfileDraft {
  const factory ProfileDraft({
    required String career,

    /// Up to two more target careers, compared with [career] side by side.
    @Default(<String>[]) List<String> otherCareers,
    required List<String> completedCourses,

    /// Skill ids held from outside coursework. Unverified.
    @Default(<String>[]) List<String> selfReportedSkills,
    String? major,
  }) = _ProfileDraft;

  factory ProfileDraft.fromJson(Map<String, dynamic> json) =>
      _$ProfileDraftFromJson(json);
}
