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
GapQuery gapQueryFor(StudentProfile profile, [String? career]) => GapQuery(
      career: career ?? profile.primaryCareer,
      completedCourses: [...profile.completedCourses]..sort(),
      selfReportedSkills: [...profile.selfReportedSkills]..sort(),
    );
