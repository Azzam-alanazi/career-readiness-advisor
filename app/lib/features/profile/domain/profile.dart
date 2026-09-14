import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String career,
    @Default(<String>[]) List<String> otherCareers,
    String? major,
    required List<String> completedCourses,
    @Default(<String>[]) List<String> selfReportedSkills,
    required String createdAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
}
