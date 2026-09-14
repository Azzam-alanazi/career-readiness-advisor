// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileDraft {

 String get career;/// Up to two more target careers, compared with [career] side by side.
 List<String> get otherCareers; List<String> get completedCourses;/// Skill ids held from outside coursework. Unverified.
 List<String> get selfReportedSkills; String? get major;
/// Create a copy of ProfileDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileDraftCopyWith<ProfileDraft> get copyWith => _$ProfileDraftCopyWithImpl<ProfileDraft>(this as ProfileDraft, _$identity);

  /// Serializes this ProfileDraft to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProfileDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileDraft&&(identical(other.career, _this.career) || other.career == _this.career)&&const DeepCollectionEquality().equals(other.otherCareers, _this.otherCareers)&&const DeepCollectionEquality().equals(other.completedCourses, _this.completedCourses)&&const DeepCollectionEquality().equals(other.selfReportedSkills, _this.selfReportedSkills)&&(identical(other.major, _this.major) || other.major == _this.major));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProfileDraft;
  return Object.hash(runtimeType,_this.career,const DeepCollectionEquality().hash(_this.otherCareers),const DeepCollectionEquality().hash(_this.completedCourses),const DeepCollectionEquality().hash(_this.selfReportedSkills),_this.major);
}

@override
String toString() {
  final _this = this as ProfileDraft;
  return 'ProfileDraft(career: ${_this.career}, otherCareers: ${_this.otherCareers}, completedCourses: ${_this.completedCourses}, selfReportedSkills: ${_this.selfReportedSkills}, major: ${_this.major})';
}


}

/// @nodoc
abstract mixin class $ProfileDraftCopyWith<$Res>  {
  factory $ProfileDraftCopyWith(ProfileDraft value, $Res Function(ProfileDraft) _then) = _$ProfileDraftCopyWithImpl;
@useResult
$Res call({
 String career, List<String> otherCareers, List<String> completedCourses, List<String> selfReportedSkills, String? major
});




}
/// @nodoc
class _$ProfileDraftCopyWithImpl<$Res>
    implements $ProfileDraftCopyWith<$Res> {
  _$ProfileDraftCopyWithImpl(this._self, this._then);

  final ProfileDraft _self;
  final $Res Function(ProfileDraft) _then;

/// Create a copy of ProfileDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? career = null,Object? otherCareers = null,Object? completedCourses = null,Object? selfReportedSkills = null,Object? major = freezed,}) {
  return _then(ProfileDraft(
career: null == career ? _self.career : career // ignore: cast_nullable_to_non_nullable
as String,otherCareers: null == otherCareers ? _self.otherCareers : otherCareers // ignore: cast_nullable_to_non_nullable
as List<String>,completedCourses: null == completedCourses ? _self.completedCourses : completedCourses // ignore: cast_nullable_to_non_nullable
as List<String>,selfReportedSkills: null == selfReportedSkills ? _self.selfReportedSkills : selfReportedSkills // ignore: cast_nullable_to_non_nullable
as List<String>,major: freezed == major ? _self.major : major // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileDraft].
extension ProfileDraftPatterns on ProfileDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileDraft value)  $default,){
final _that = this;
switch (_that) {
case _ProfileDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileDraft value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String career,  List<String> otherCareers,  List<String> completedCourses,  List<String> selfReportedSkills,  String? major)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileDraft() when $default != null:
return $default(_that.career,_that.otherCareers,_that.completedCourses,_that.selfReportedSkills,_that.major);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String career,  List<String> otherCareers,  List<String> completedCourses,  List<String> selfReportedSkills,  String? major)  $default,) {final _that = this;
switch (_that) {
case _ProfileDraft():
return $default(_that.career,_that.otherCareers,_that.completedCourses,_that.selfReportedSkills,_that.major);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String career,  List<String> otherCareers,  List<String> completedCourses,  List<String> selfReportedSkills,  String? major)?  $default,) {final _that = this;
switch (_that) {
case _ProfileDraft() when $default != null:
return $default(_that.career,_that.otherCareers,_that.completedCourses,_that.selfReportedSkills,_that.major);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileDraft implements ProfileDraft {
  const _ProfileDraft({required this.career,  List<String> otherCareers = const <String>[], required  List<String> completedCourses,  List<String> selfReportedSkills = const <String>[], this.major}): _otherCareers = otherCareers,_completedCourses = completedCourses,_selfReportedSkills = selfReportedSkills;
  factory _ProfileDraft.fromJson(Map<String, dynamic> json) => _$ProfileDraftFromJson(json);

@override final  String career;
/// Up to two more target careers, compared with [career] side by side.
 final  List<String> _otherCareers;
/// Up to two more target careers, compared with [career] side by side.
@override@JsonKey() List<String> get otherCareers {
  if (_otherCareers is EqualUnmodifiableListView) return _otherCareers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_otherCareers);
}

 final  List<String> _completedCourses;
@override List<String> get completedCourses {
  if (_completedCourses is EqualUnmodifiableListView) return _completedCourses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_completedCourses);
}

/// Skill ids held from outside coursework. Unverified.
 final  List<String> _selfReportedSkills;
/// Skill ids held from outside coursework. Unverified.
@override@JsonKey() List<String> get selfReportedSkills {
  if (_selfReportedSkills is EqualUnmodifiableListView) return _selfReportedSkills;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selfReportedSkills);
}

@override final  String? major;

/// Create a copy of ProfileDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileDraftCopyWith<_ProfileDraft> get copyWith => __$ProfileDraftCopyWithImpl<_ProfileDraft>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileDraftToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileDraft&&(identical(other.career, career) || other.career == career)&&const DeepCollectionEquality().equals(other.otherCareers, _otherCareers)&&const DeepCollectionEquality().equals(other.completedCourses, _completedCourses)&&const DeepCollectionEquality().equals(other.selfReportedSkills, _selfReportedSkills)&&(identical(other.major, major) || other.major == major));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,career,const DeepCollectionEquality().hash(_otherCareers),const DeepCollectionEquality().hash(_completedCourses),const DeepCollectionEquality().hash(_selfReportedSkills),major);
}

@override
String toString() {
    return 'ProfileDraft(career: $career, otherCareers: $otherCareers, completedCourses: $completedCourses, selfReportedSkills: $selfReportedSkills, major: $major)';
}


}

/// @nodoc
abstract mixin class _$ProfileDraftCopyWith<$Res> implements $ProfileDraftCopyWith<$Res> {
  factory _$ProfileDraftCopyWith(_ProfileDraft value, $Res Function(_ProfileDraft) _then) = __$ProfileDraftCopyWithImpl;
@override @useResult
$Res call({
 String career, List<String> otherCareers, List<String> completedCourses, List<String> selfReportedSkills, String? major
});




}
/// @nodoc
class __$ProfileDraftCopyWithImpl<$Res>
    implements _$ProfileDraftCopyWith<$Res> {
  __$ProfileDraftCopyWithImpl(this._self, this._then);

  final _ProfileDraft _self;
  final $Res Function(_ProfileDraft) _then;

/// Create a copy of ProfileDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? career = null,Object? otherCareers = null,Object? completedCourses = null,Object? selfReportedSkills = null,Object? major = freezed,}) {
  return _then(_ProfileDraft(
career: null == career ? _self.career : career // ignore: cast_nullable_to_non_nullable
as String,otherCareers: null == otherCareers ? _self._otherCareers : otherCareers // ignore: cast_nullable_to_non_nullable
as List<String>,completedCourses: null == completedCourses ? _self._completedCourses : completedCourses // ignore: cast_nullable_to_non_nullable
as List<String>,selfReportedSkills: null == selfReportedSkills ? _self._selfReportedSkills : selfReportedSkills // ignore: cast_nullable_to_non_nullable
as List<String>,major: freezed == major ? _self.major : major // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
