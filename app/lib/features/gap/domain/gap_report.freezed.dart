// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gap_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GapReport {

 String get profileId; String get career;/// Demand-weighted share of the career's required skills the student has.
 double get readiness; int get readinessPercent; List<SkillEntry> get covered;/// Ranked by demand, highest first -- the backend's contract, rendered
/// in the order received.
 List<SkillEntry> get missing; ValidationInfo get validation;
/// Create a copy of GapReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GapReportCopyWith<GapReport> get copyWith => _$GapReportCopyWithImpl<GapReport>(this as GapReport, _$identity);

  /// Serializes this GapReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GapReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GapReport&&(identical(other.profileId, _this.profileId) || other.profileId == _this.profileId)&&(identical(other.career, _this.career) || other.career == _this.career)&&(identical(other.readiness, _this.readiness) || other.readiness == _this.readiness)&&(identical(other.readinessPercent, _this.readinessPercent) || other.readinessPercent == _this.readinessPercent)&&const DeepCollectionEquality().equals(other.covered, _this.covered)&&const DeepCollectionEquality().equals(other.missing, _this.missing)&&(identical(other.validation, _this.validation) || other.validation == _this.validation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GapReport;
  return Object.hash(runtimeType,_this.profileId,_this.career,_this.readiness,_this.readinessPercent,const DeepCollectionEquality().hash(_this.covered),const DeepCollectionEquality().hash(_this.missing),_this.validation);
}

@override
String toString() {
  final _this = this as GapReport;
  return 'GapReport(profileId: ${_this.profileId}, career: ${_this.career}, readiness: ${_this.readiness}, readinessPercent: ${_this.readinessPercent}, covered: ${_this.covered}, missing: ${_this.missing}, validation: ${_this.validation})';
}


}

/// @nodoc
abstract mixin class $GapReportCopyWith<$Res>  {
  factory $GapReportCopyWith(GapReport value, $Res Function(GapReport) _then) = _$GapReportCopyWithImpl;
@useResult
$Res call({
 String profileId, String career, double readiness, int readinessPercent, List<SkillEntry> covered, List<SkillEntry> missing, ValidationInfo validation
});


$ValidationInfoCopyWith<$Res> get validation;

}
/// @nodoc
class _$GapReportCopyWithImpl<$Res>
    implements $GapReportCopyWith<$Res> {
  _$GapReportCopyWithImpl(this._self, this._then);

  final GapReport _self;
  final $Res Function(GapReport) _then;

/// Create a copy of GapReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profileId = null,Object? career = null,Object? readiness = null,Object? readinessPercent = null,Object? covered = null,Object? missing = null,Object? validation = null,}) {
  return _then(GapReport(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,career: null == career ? _self.career : career // ignore: cast_nullable_to_non_nullable
as String,readiness: null == readiness ? _self.readiness : readiness // ignore: cast_nullable_to_non_nullable
as double,readinessPercent: null == readinessPercent ? _self.readinessPercent : readinessPercent // ignore: cast_nullable_to_non_nullable
as int,covered: null == covered ? _self.covered : covered // ignore: cast_nullable_to_non_nullable
as List<SkillEntry>,missing: null == missing ? _self.missing : missing // ignore: cast_nullable_to_non_nullable
as List<SkillEntry>,validation: null == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ValidationInfo,
  ));
}
/// Create a copy of GapReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ValidationInfoCopyWith<$Res> get validation {
  
  return $ValidationInfoCopyWith<$Res>(_self.validation, (value) {
    return _then(_self.copyWith(validation: value));
  });
}
}


/// Adds pattern-matching-related methods to [GapReport].
extension GapReportPatterns on GapReport {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GapReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GapReport() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GapReport value)  $default,){
final _that = this;
switch (_that) {
case _GapReport():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GapReport value)?  $default,){
final _that = this;
switch (_that) {
case _GapReport() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String profileId,  String career,  double readiness,  int readinessPercent,  List<SkillEntry> covered,  List<SkillEntry> missing,  ValidationInfo validation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GapReport() when $default != null:
return $default(_that.profileId,_that.career,_that.readiness,_that.readinessPercent,_that.covered,_that.missing,_that.validation);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String profileId,  String career,  double readiness,  int readinessPercent,  List<SkillEntry> covered,  List<SkillEntry> missing,  ValidationInfo validation)  $default,) {final _that = this;
switch (_that) {
case _GapReport():
return $default(_that.profileId,_that.career,_that.readiness,_that.readinessPercent,_that.covered,_that.missing,_that.validation);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String profileId,  String career,  double readiness,  int readinessPercent,  List<SkillEntry> covered,  List<SkillEntry> missing,  ValidationInfo validation)?  $default,) {final _that = this;
switch (_that) {
case _GapReport() when $default != null:
return $default(_that.profileId,_that.career,_that.readiness,_that.readinessPercent,_that.covered,_that.missing,_that.validation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GapReport implements GapReport {
  const _GapReport({required this.profileId, required this.career, required this.readiness, required this.readinessPercent, required  List<SkillEntry> covered, required  List<SkillEntry> missing, required this.validation}): _covered = covered,_missing = missing;
  factory _GapReport.fromJson(Map<String, dynamic> json) => _$GapReportFromJson(json);

@override final  String profileId;
@override final  String career;
/// Demand-weighted share of the career's required skills the student has.
@override final  double readiness;
@override final  int readinessPercent;
 final  List<SkillEntry> _covered;
@override List<SkillEntry> get covered {
  if (_covered is EqualUnmodifiableListView) return _covered;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_covered);
}

/// Ranked by demand, highest first -- the backend's contract, rendered
/// in the order received.
 final  List<SkillEntry> _missing;
/// Ranked by demand, highest first -- the backend's contract, rendered
/// in the order received.
@override List<SkillEntry> get missing {
  if (_missing is EqualUnmodifiableListView) return _missing;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_missing);
}

@override final  ValidationInfo validation;

/// Create a copy of GapReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GapReportCopyWith<_GapReport> get copyWith => __$GapReportCopyWithImpl<_GapReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GapReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GapReport&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.career, career) || other.career == career)&&(identical(other.readiness, readiness) || other.readiness == readiness)&&(identical(other.readinessPercent, readinessPercent) || other.readinessPercent == readinessPercent)&&const DeepCollectionEquality().equals(other.covered, _covered)&&const DeepCollectionEquality().equals(other.missing, _missing)&&(identical(other.validation, validation) || other.validation == validation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,profileId,career,readiness,readinessPercent,const DeepCollectionEquality().hash(_covered),const DeepCollectionEquality().hash(_missing),validation);
}

@override
String toString() {
    return 'GapReport(profileId: $profileId, career: $career, readiness: $readiness, readinessPercent: $readinessPercent, covered: $covered, missing: $missing, validation: $validation)';
}


}

/// @nodoc
abstract mixin class _$GapReportCopyWith<$Res> implements $GapReportCopyWith<$Res> {
  factory _$GapReportCopyWith(_GapReport value, $Res Function(_GapReport) _then) = __$GapReportCopyWithImpl;
@override @useResult
$Res call({
 String profileId, String career, double readiness, int readinessPercent, List<SkillEntry> covered, List<SkillEntry> missing, ValidationInfo validation
});


@override $ValidationInfoCopyWith<$Res> get validation;

}
/// @nodoc
class __$GapReportCopyWithImpl<$Res>
    implements _$GapReportCopyWith<$Res> {
  __$GapReportCopyWithImpl(this._self, this._then);

  final _GapReport _self;
  final $Res Function(_GapReport) _then;

/// Create a copy of GapReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profileId = null,Object? career = null,Object? readiness = null,Object? readinessPercent = null,Object? covered = null,Object? missing = null,Object? validation = null,}) {
  return _then(_GapReport(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,career: null == career ? _self.career : career // ignore: cast_nullable_to_non_nullable
as String,readiness: null == readiness ? _self.readiness : readiness // ignore: cast_nullable_to_non_nullable
as double,readinessPercent: null == readinessPercent ? _self.readinessPercent : readinessPercent // ignore: cast_nullable_to_non_nullable
as int,covered: null == covered ? _self._covered : covered // ignore: cast_nullable_to_non_nullable
as List<SkillEntry>,missing: null == missing ? _self._missing : missing // ignore: cast_nullable_to_non_nullable
as List<SkillEntry>,validation: null == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ValidationInfo,
  ));
}

/// Create a copy of GapReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ValidationInfoCopyWith<$Res> get validation {
  
  return $ValidationInfoCopyWith<$Res>(_self.validation, (value) {
    return _then(_self.copyWith(validation: value));
  });
}
}

// dart format on
