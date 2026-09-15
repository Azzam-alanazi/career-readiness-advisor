import 'package:career_readiness/features/profile/domain/student_profile.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'gap_query.freezed.dart';
part 'gap_query.g.dart';

/// What the backend needs to read a gap: one career, and what the student
/// holds. Sent with every request -- the server keeps nothing -- and compared
/// by value, so a provider keyed on it caches per profile content.
@freezed
abstract class GapQuery with _$GapQuery {
  const factory GapQuery({
    required String career,
    @Default(<String>[]) List<String> completedCourses,
    @Default(<String>[]) List<String> selfReportedSkills,
  }) = _GapQuery;

  factory GapQuery.fromJson(Map<String, dynamic> json) => _$GapQueryFromJson(json);
}

/// [profile] read against [career], or against its main career.
///
/// With [withPlanned], the planned courses are sent as if completed: the
/// what-if projection is the same readiness calculation over completed and
/// planned courses together.
GapQuery gapQueryFor(StudentProfile profile, {String? career, bool withPlanned = false}) =>
    GapQuery(
      career: career ?? profile.primaryCareer,
      completedCourses: {
        ...profile.completedCourses,
        if (withPlanned) ...profile.plannedCourses,
      }.toList()
        ..sort(),
      selfReportedSkills: [...profile.selfReportedSkills]..sort(),
    );
