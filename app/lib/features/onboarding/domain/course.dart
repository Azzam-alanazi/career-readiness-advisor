import 'package:freezed_annotation/freezed_annotation.dart';

part 'course.freezed.dart';
part 'course.g.dart';

@freezed
abstract class Course with _$Course {
  const factory Course({
    required String code,
    required String name,
    required int skillCount,

    /// Skill ids the course teaches, so onboarding can show them as already
    /// covered instead of offering them again.
    @Default(<String>[]) List<String> skills,

    /// The catalog's track -- college, core, or an elective track -- for
    /// grouping the list. Display only; empty when the catalog gives none.
    @Default('') String track,
  }) = _Course;

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
}
