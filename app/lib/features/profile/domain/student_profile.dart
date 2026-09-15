import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_profile.freezed.dart';
part 'student_profile.g.dart';

/// The student's profile, kept on this device and nowhere else: no server
/// copy, no account. The backend is sent what it needs with each request.
@freezed
abstract class StudentProfile with _$StudentProfile {
  const StudentProfile._();

  const factory StudentProfile({
    /// Target careers in the order chosen, one to three. The first is the main
    /// one, which the app opens on.
    required List<String> careers,
    @Default(<String>[]) List<String> completedCourses,

    /// Skill ids held from outside coursework. Unverified.
    @Default(<String>[]) List<String> selfReportedSkills,

    /// Courses the student plans to take. Never part of the record: they count
    /// only in the what-if projection. A profile saved before planning existed
    /// loads with none.
    @Default(<String>[]) List<String> plannedCourses,
    String? major,
  }) = _StudentProfile;

  factory StudentProfile.fromJson(Map<String, dynamic> json) =>
      _$StudentProfileFromJson(json);

  String get primaryCareer => careers.first;
}
