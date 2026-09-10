import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_draft.freezed.dart';
part 'profile_draft.g.dart';

/// What onboarding sends to POST /profiles.
@freezed
abstract class ProfileDraft with _$ProfileDraft {
  const factory ProfileDraft({
    required String career,
    required List<String> completedCourses,
    String? major,
  }) = _ProfileDraft;

  factory ProfileDraft.fromJson(Map<String, dynamic> json) =>
      _$ProfileDraftFromJson(json);
}
