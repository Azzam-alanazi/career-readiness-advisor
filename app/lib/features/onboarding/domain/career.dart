import 'package:freezed_annotation/freezed_annotation.dart';

part 'career.freezed.dart';
part 'career.g.dart';

@freezed
abstract class Career with _$Career {
  const factory Career({
    required String name,
    required int postingCount,
  }) = _Career;

  factory Career.fromJson(Map<String, dynamic> json) => _$CareerFromJson(json);
}
