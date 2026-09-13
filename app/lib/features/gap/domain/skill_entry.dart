import 'package:freezed_annotation/freezed_annotation.dart';

part 'skill_entry.freezed.dart';
part 'skill_entry.g.dart';

@freezed
abstract class SkillEntry with _$SkillEntry {
  const SkillEntry._();

  const factory SkillEntry({
    required String id,
    required String en,
    required String ar,
    required String category,

    /// Share of this career's postings that ask for the skill, 0 to 1.
    required double demand,
    required int demandPercent,

    /// For a skill the student has: "courses" or "self_reported". A skill a
    /// completed course teaches is "courses" even if also self-reported.
    /// Absent for a missing skill.
    String? source,
  }) = _SkillEntry;

  factory SkillEntry.fromJson(Map<String, dynamic> json) =>
      _$SkillEntryFromJson(json);

  /// The Arabic name is the taxonomy's hand-written translation. It is a
  /// display label: no Arabic text was matched to produce it.
  String nameFor(String languageCode) => languageCode == 'ar' ? ar : en;
}
