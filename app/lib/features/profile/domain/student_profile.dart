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
    String? major,
  }) = _StudentProfile;

  factory StudentProfile.fromJson(Map<String, dynamic> json) =>
      _$StudentProfileFromJson(json);

  String get primaryCareer => careers.first;
}
