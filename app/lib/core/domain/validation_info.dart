import 'package:freezed_annotation/freezed_annotation.dart';

part 'validation_info.freezed.dart';
part 'validation_info.g.dart';

/// The quality flag the backend attaches to every readiness figure.
///
/// The backend also sends a prose `note`, but only in English. The app builds
/// its own message from the structured fields instead, so the flag reads in
/// whichever language the student chose.
@freezed
abstract class ValidationInfo with _$ValidationInfo {
  const factory ValidationInfo({
    required bool gatePassed,
    double? bestF1,
    double? gateMinF1,
    required bool courseMappingValidated,
    required String note,
  }) = _ValidationInfo;

  factory ValidationInfo.fromJson(Map<String, dynamic> json) =>
      _$ValidationInfoFromJson(json);
}
