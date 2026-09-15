// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StudentProfile {

/// Target careers in the order chosen, one to three. The first is the main
/// one, which the app opens on.
 List<String> get careers; List<String> get completedCourses;/// Skill ids held from outside coursework. Unverified.
 List<String> get selfReportedSkills;/// Courses the student plans to take. Never part of the record: they count
/// only in the what-if projection. A profile saved before planning existed
/// loads with none.
 List<String> get plannedCourses; String? get major;
/// Create a copy of StudentProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudentProfileCopyWith<StudentProfile> get copyWith => _$StudentProfileCopyWithImpl<StudentProfile>(this as StudentProfile, _$identity);

  /// Serializes this StudentProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StudentProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudentProfile&&const DeepCollectionEquality().equals(other.careers, _this.careers)&&const DeepCollectionEquality().equals(other.completedCourses, _this.completedCourses)&&const DeepCollectionEquality().equals(other.selfReportedSkills, _this.selfReportedSkills)&&const DeepCollectionEquality().equals(other.plannedCourses, _this.plannedCourses)&&(identical(other.major, _this.major) || other.major == _this.major));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StudentProfile;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.careers),const DeepCollectionEquality().hash(_this.completedCourses),const DeepCollectionEquality().hash(_this.selfReportedSkills),const DeepCollectionEquality().hash(_this.plannedCourses),_this.major);
}

@override
String toString() {
  final _this = this as StudentProfile;
  return 'StudentProfile(careers: ${_this.careers}, completedCourses: ${_this.completedCourses}, selfReportedSkills: ${_this.selfReportedSkills}, plannedCourses: ${_this.plannedCourses}, major: ${_this.major})';
}


}

/// @nodoc
abstract mixin class $StudentProfileCopyWith<$Res>  {
  factory $StudentProfileCopyWith(StudentProfile value, $Res Function(StudentProfile) _then) = _$StudentProfileCopyWithImpl;
@useResult
$Res call({
 List<String> careers, List<String> completedCourses, List<String> selfReportedSkills, List<String> plannedCourses, String? major
});




}
/// @nodoc
class _$StudentProfileCopyWithImpl<$Res>
    implements $StudentProfileCopyWith<$Res> {
  _$StudentProfileCopyWithImpl(this._self, this._then);

  final StudentProfile _self;
  final $Res Function(StudentProfile) _then;

/// Create a copy of StudentProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? careers = null,Object? completedCourses = null,Object? selfReportedSkills = null,Object? plannedCourses = null,Object? major = freezed,}) {
  return _then(StudentProfile(
careers: null == careers ? _self.careers : careers // ignore: cast_nullable_to_non_nullable
as List<String>,completedCourses: null == completedCourses ? _self.completedCourses : completedCourses // ignore: cast_nullable_to_non_nullable
as List<String>,selfReportedSkills: null == selfReportedSkills ? _self.selfReportedSkills : selfReportedSkills // ignore: cast_nullable_to_non_nullable
as List<String>,plannedCourses: null == plannedCourses ? _self.plannedCourses : plannedCourses // ignore: cast_nullable_to_non_nullable
as List<String>,major: freezed == major ? _self.major : major // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StudentProfile].
extension StudentProfilePatterns on StudentProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudentProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudentProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudentProfile value)  $default,){
final _that = this;
switch (_that) {
case _StudentProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudentProfile value)?  $default,){
final _that = this;
switch (_that) {
case _StudentProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> careers,  List<String> completedCourses,  List<String> selfReportedSkills,  List<String> plannedCourses,  String? major)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudentProfile() when $default != null:
return $default(_that.careers,_that.completedCourses,_that.selfReportedSkills,_that.plannedCourses,_that.major);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> careers,  List<String> completedCourses,  List<String> selfReportedSkills,  List<String> plannedCourses,  String? major)  $default,) {final _that = this;
switch (_that) {
case _StudentProfile():
return $default(_that.careers,_that.completedCourses,_that.selfReportedSkills,_that.plannedCourses,_that.major);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> careers,  List<String> completedCourses,  List<String> selfReportedSkills,  List<String> plannedCourses,  String? major)?  $default,) {final _that = this;
switch (_that) {
case _StudentProfile() when $default != null:
return $default(_that.careers,_that.completedCourses,_that.selfReportedSkills,_that.plannedCourses,_that.major);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StudentProfile extends StudentProfile {
  const _StudentProfile({required  List<String> careers,  List<String> completedCourses = const <String>[],  List<String> selfReportedSkills = const <String>[],  List<String> plannedCourses = const <String>[], this.major}): _careers = careers,_completedCourses = completedCourses,_selfReportedSkills = selfReportedSkills,_plannedCourses = plannedCourses,super._();
  factory _StudentProfile.fromJson(Map<String, dynamic> json) => _$StudentProfileFromJson(json);

/// Target careers in the order chosen, one to three. The first is the main
/// one, which the app opens on.
 final  List<String> _careers;
/// Target careers in the order chosen, one to three. The first is the main
/// one, which the app opens on.
@override List<String> get careers {
  if (_careers is EqualUnmodifiableListView) return _careers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_careers);
}

 final  List<String> _completedCourses;
@override@JsonKey() List<String> get completedCourses {
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

/// Courses the student plans to take. Never part of the record: they count
/// only in the what-if projection. A profile saved before planning existed
/// loads with none.
 final  List<String> _plannedCourses;
/// Courses the student plans to take. Never part of the record: they count
/// only in the what-if projection. A profile saved before planning existed
/// loads with none.
@override@JsonKey() List<String> get plannedCourses {
  if (_plannedCourses is EqualUnmodifiableListView) return _plannedCourses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_plannedCourses);
}

@override final  String? major;

/// Create a copy of StudentProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudentProfileCopyWith<_StudentProfile> get copyWith => __$StudentProfileCopyWithImpl<_StudentProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudentProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudentProfile&&const DeepCollectionEquality().equals(other.careers, _careers)&&const DeepCollectionEquality().equals(other.completedCourses, _completedCourses)&&const DeepCollectionEquality().equals(other.selfReportedSkills, _selfReportedSkills)&&const DeepCollectionEquality().equals(other.plannedCourses, _plannedCourses)&&(identical(other.major, major) || other.major == major));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_careers),const DeepCollectionEquality().hash(_completedCourses),const DeepCollectionEquality().hash(_selfReportedSkills),const DeepCollectionEquality().hash(_plannedCourses),major);
}

@override
String toString() {
    return 'StudentProfile(careers: $careers, completedCourses: $completedCourses, selfReportedSkills: $selfReportedSkills, plannedCourses: $plannedCourses, major: $major)';
}


}

/// @nodoc
abstract mixin class _$StudentProfileCopyWith<$Res> implements $StudentProfileCopyWith<$Res> {
  factory _$StudentProfileCopyWith(_StudentProfile value, $Res Function(_StudentProfile) _then) = __$StudentProfileCopyWithImpl;
@override @useResult
$Res call({
 List<String> careers, List<String> completedCourses, List<String> selfReportedSkills, List<String> plannedCourses, String? major
});




}
/// @nodoc
class __$StudentProfileCopyWithImpl<$Res>
    implements _$StudentProfileCopyWith<$Res> {
  __$StudentProfileCopyWithImpl(this._self, this._then);

  final _StudentProfile _self;
  final $Res Function(_StudentProfile) _then;

/// Create a copy of StudentProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? careers = null,Object? completedCourses = null,Object? selfReportedSkills = null,Object? plannedCourses = null,Object? major = freezed,}) {
  return _then(_StudentProfile(
careers: null == careers ? _self._careers : careers // ignore: cast_nullable_to_non_nullable
as List<String>,completedCourses: null == completedCourses ? _self._completedCourses : completedCourses // ignore: cast_nullable_to_non_nullable
as List<String>,selfReportedSkills: null == selfReportedSkills ? _self._selfReportedSkills : selfReportedSkills // ignore: cast_nullable_to_non_nullable
as List<String>,plannedCourses: null == plannedCourses ? _self._plannedCourses : plannedCourses // ignore: cast_nullable_to_non_nullable
as List<String>,major: freezed == major ? _self.major : major // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
