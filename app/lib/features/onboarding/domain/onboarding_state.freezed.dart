// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OnboardingState {

 String get major; String? get career; Set<String> get courses; bool get submitting; Object? get error;/// Bumped on reset, so the screen can rebuild fields that keep their own
/// text (the major) instead of showing a value the draft no longer holds.
 int get revision;
/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingStateCopyWith<OnboardingState> get copyWith => _$OnboardingStateCopyWithImpl<OnboardingState>(this as OnboardingState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OnboardingState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingState&&(identical(other.major, _this.major) || other.major == _this.major)&&(identical(other.career, _this.career) || other.career == _this.career)&&const DeepCollectionEquality().equals(other.courses, _this.courses)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&const DeepCollectionEquality().equals(other.error, _this.error)&&(identical(other.revision, _this.revision) || other.revision == _this.revision));
}


@override
int get hashCode {
  final _this = this as OnboardingState;
  return Object.hash(runtimeType,_this.major,_this.career,const DeepCollectionEquality().hash(_this.courses),_this.submitting,const DeepCollectionEquality().hash(_this.error),_this.revision);
}

@override
String toString() {
  final _this = this as OnboardingState;
  return 'OnboardingState(major: ${_this.major}, career: ${_this.career}, courses: ${_this.courses}, submitting: ${_this.submitting}, error: ${_this.error}, revision: ${_this.revision})';
}


}

/// @nodoc
abstract mixin class $OnboardingStateCopyWith<$Res>  {
  factory $OnboardingStateCopyWith(OnboardingState value, $Res Function(OnboardingState) _then) = _$OnboardingStateCopyWithImpl;
@useResult
$Res call({
 String major, String? career, Set<String> courses, bool submitting, Object? error, int revision
});




}
/// @nodoc
class _$OnboardingStateCopyWithImpl<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  _$OnboardingStateCopyWithImpl(this._self, this._then);

  final OnboardingState _self;
  final $Res Function(OnboardingState) _then;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? major = null,Object? career = freezed,Object? courses = null,Object? submitting = null,Object? error = freezed,Object? revision = null,}) {
  return _then(OnboardingState(
major: null == major ? _self.major : major // ignore: cast_nullable_to_non_nullable
as String,career: freezed == career ? _self.career : career // ignore: cast_nullable_to_non_nullable
as String?,courses: null == courses ? _self.courses : courses // ignore: cast_nullable_to_non_nullable
as Set<String>,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error ,revision: null == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingState].
extension OnboardingStatePatterns on OnboardingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingState value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingState value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String major,  String? career,  Set<String> courses,  bool submitting,  Object? error,  int revision)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
return $default(_that.major,_that.career,_that.courses,_that.submitting,_that.error,_that.revision);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String major,  String? career,  Set<String> courses,  bool submitting,  Object? error,  int revision)  $default,) {final _that = this;
switch (_that) {
case _OnboardingState():
return $default(_that.major,_that.career,_that.courses,_that.submitting,_that.error,_that.revision);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String major,  String? career,  Set<String> courses,  bool submitting,  Object? error,  int revision)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
return $default(_that.major,_that.career,_that.courses,_that.submitting,_that.error,_that.revision);case _:
  return null;

}
}

}

/// @nodoc


class _OnboardingState extends OnboardingState {
  const _OnboardingState({this.major = '', this.career,  Set<String> courses = const <String>{}, this.submitting = false, this.error, this.revision = 0}): _courses = courses,super._();
  

@override@JsonKey() final  String major;
@override final  String? career;
 final  Set<String> _courses;
@override@JsonKey() Set<String> get courses {
  if (_courses is EqualUnmodifiableSetView) return _courses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_courses);
}

@override@JsonKey() final  bool submitting;
@override final  Object? error;
/// Bumped on reset, so the screen can rebuild fields that keep their own
/// text (the major) instead of showing a value the draft no longer holds.
@override@JsonKey() final  int revision;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingStateCopyWith<_OnboardingState> get copyWith => __$OnboardingStateCopyWithImpl<_OnboardingState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingState&&(identical(other.major, major) || other.major == major)&&(identical(other.career, career) || other.career == career)&&const DeepCollectionEquality().equals(other.courses, _courses)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.revision, revision) || other.revision == revision));
}


@override
int get hashCode {
    return Object.hash(runtimeType,major,career,const DeepCollectionEquality().hash(_courses),submitting,const DeepCollectionEquality().hash(error),revision);
}

@override
String toString() {
    return 'OnboardingState(major: $major, career: $career, courses: $courses, submitting: $submitting, error: $error, revision: $revision)';
}


}

/// @nodoc
abstract mixin class _$OnboardingStateCopyWith<$Res> implements $OnboardingStateCopyWith<$Res> {
  factory _$OnboardingStateCopyWith(_OnboardingState value, $Res Function(_OnboardingState) _then) = __$OnboardingStateCopyWithImpl;
@override @useResult
$Res call({
 String major, String? career, Set<String> courses, bool submitting, Object? error, int revision
});




}
/// @nodoc
class __$OnboardingStateCopyWithImpl<$Res>
    implements _$OnboardingStateCopyWith<$Res> {
  __$OnboardingStateCopyWithImpl(this._self, this._then);

  final _OnboardingState _self;
  final $Res Function(_OnboardingState) _then;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? major = null,Object? career = freezed,Object? courses = null,Object? submitting = null,Object? error = freezed,Object? revision = null,}) {
  return _then(_OnboardingState(
major: null == major ? _self.major : major // ignore: cast_nullable_to_non_nullable
as String,career: freezed == career ? _self.career : career // ignore: cast_nullable_to_non_nullable
as String?,courses: null == courses ? _self._courses : courses // ignore: cast_nullable_to_non_nullable
as Set<String>,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error ,revision: null == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
