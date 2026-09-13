import 'package:freezed_annotation/freezed_annotation.dart';

part 'skill.freezed.dart';
part 'skill.g.dart';

/// A taxonomy skill, as GET /skills lists it.
@freezed
abstract class Skill with _$Skill {
  const Skill._();

  const factory Skill({
    required String id,
    required String en,
    required String ar,
    required String category,
  }) = _Skill;

  factory Skill.fromJson(Map<String, dynamic> json) => _$SkillFromJson(json);

  String nameFor(String languageCode) => languageCode == 'ar' ? ar : en;
}
