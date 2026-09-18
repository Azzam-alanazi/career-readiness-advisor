import 'package:career_readiness/features/gap/domain/gap_query.dart';
import 'package:career_readiness/features/profile/domain/student_profile.dart';

/// A career the backend no longer reads a gap against: it has left the
/// posting corpus since the profile was saved. Only the student can fix it,
/// by choosing another career.
class CareerNotServed implements Exception {
  const CareerNotServed(this.career);

  final String career;

  @override
  String toString() => 'CareerNotServed($career)';
}

/// The ids the backend serves now: its careers, catalog courses and taxonomy
/// skills.
///
/// The profile lives on the device and can outlive them -- a course dropped
/// from the catalog, a skill from the taxonomy, a career from the postings.
/// The backend refuses a request naming any of them, so a profile saved
/// before such a change would fail on every screen, and "try again" could
/// never succeed. Instead the app stops sending what the backend no longer
/// knows, as the backend itself does for a stored profile: a dropped course
/// or skill simply stops counting.
class ServedIds {
  const ServedIds({required this.careers, required this.courses, required this.skills});

  final Set<String> careers;
  final Set<String> courses;
  final Set<String> skills;

  List<String> _servedCourses(List<String> codes) => [...codes.where(courses.contains)];

  List<String> _servedSkills(List<String> ids) => [...ids.where(skills.contains)];

  /// [query] without the courses and skills the backend no longer serves.
  /// Throws [CareerNotServed] when the career itself is gone: nothing can be
  /// read against it.
  GapQuery restrictQuery(GapQuery query) {
    if (!careers.contains(query.career)) throw CareerNotServed(query.career);
    return query.copyWith(
      completedCourses: _servedCourses(query.completedCourses),
      selfReportedSkills: _servedSkills(query.selfReportedSkills),
    );
  }

  /// [profile] without anything the backend no longer serves. Its careers may
  /// come out empty; the student then chooses again.
  StudentProfile restrictProfile(StudentProfile profile) => profile.copyWith(
        careers: [...profile.careers.where(careers.contains)],
        completedCourses: _servedCourses(profile.completedCourses),
        selfReportedSkills: _servedSkills(profile.selfReportedSkills),
        plannedCourses: _servedCourses(profile.plannedCourses),
      );
}
