// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gap_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GapQuery {

 String get career; List<String> get completedCourses; List<String> get selfReportedSkills;
/// Create a copy of GapQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GapQueryCopyWith<GapQuery> get copyWith => _$GapQueryCopyWithImpl<GapQuery>(this as GapQuery, _$identity);

  /// Serializes this GapQuery to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GapQuery;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GapQuery&&(identical(other.career, _this.career) || other.career == _this.career)&&const DeepCollectionEquality().equals(other.completedCourses, _this.completedCourses)&&const DeepCollectionEquality().equals(other.selfReportedSkills, _this.selfReportedSkills));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GapQuery;
  return Object.hash(runtimeType,_this.career,const DeepCollectionEquality().hash(_this.completedCourses),const DeepCollectionEquality().hash(_this.selfReportedSkills));
}

@override
String toString() {
  final _this = this as GapQuery;
  return 'GapQuery(career: ${_this.career}, completedCourses: ${_this.completedCourses}, selfReportedSkills: ${_this.selfReportedSkills})';
}


}

/// @nodoc
abstract mixin class $GapQueryCopyWith<$Res>  {
  factory $GapQueryCopyWith(GapQuery value, $Res Function(GapQuery) _then) = _$GapQueryCopyWithImpl;
@useResult
$Res call({
 String career, List<String> completedCourses, List<String> selfReportedSkills
});




}
/// @nodoc
class _$GapQueryCopyWithImpl<$Res>
    implements $GapQueryCopyWith<$Res> {
  _$GapQueryCopyWithImpl(this._self, this._then);

  final GapQuery _self;
  final $Res Function(GapQuery) _then;

/// Create a copy of GapQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? career = null,Object? completedCourses = null,Object? selfReportedSkills = null,}) {
  return _then(GapQuery(
career: null == career ? _self.career : career // ignore: cast_nullable_to_non_nullable
as String,completedCourses: null == completedCourses ? _self.completedCourses : completedCourses // ignore: cast_nullable_to_non_nullable
as List<String>,selfReportedSkills: null == selfReportedSkills ? _self.selfReportedSkills : selfReportedSkills // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [GapQuery].
extension GapQueryPatterns on GapQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GapQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GapQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GapQuery value)  $default,){
final _that = this;
switch (_that) {
case _GapQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GapQuery value)?  $default,){
final _that = this;
switch (_that) {
case _GapQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String career,  List<String> completedCourses,  List<String> selfReportedSkills)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GapQuery() when $default != null:
return $default(_that.career,_that.completedCourses,_that.selfReportedSkills);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String career,  List<String> completedCourses,  List<String> selfReportedSkills)  $default,) {final _that = this;
switch (_that) {
case _GapQuery():
return $default(_that.career,_that.completedCourses,_that.selfReportedSkills);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String career,  List<String> completedCourses,  List<String> selfReportedSkills)?  $default,) {final _that = this;
switch (_that) {
case _GapQuery() when $default != null:
return $default(_that.career,_that.completedCourses,_that.selfReportedSkills);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GapQuery implements GapQuery {
  const _GapQuery({required this.career,  List<String> completedCourses = const <String>[],  List<String> selfReportedSkills = const <String>[]}): _completedCourses = completedCourses,_selfReportedSkills = selfReportedSkills;
  factory _GapQuery.fromJson(Map<String, dynamic> json) => _$GapQueryFromJson(json);

@override final  String career;
 final  List<String> _completedCourses;
@override@JsonKey() List<String> get completedCourses {
  if (_completedCourses is EqualUnmodifiableListView) return _completedCourses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_completedCourses);
}

 final  List<String> _selfReportedSkills;
@override@JsonKey() List<String> get selfReportedSkills {
  if (_selfReportedSkills is EqualUnmodifiableListView) return _selfReportedSkills;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selfReportedSkills);
}


/// Create a copy of GapQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GapQueryCopyWith<_GapQuery> get copyWith => __$GapQueryCopyWithImpl<_GapQuery>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GapQueryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GapQuery&&(identical(other.career, career) || other.career == career)&&const DeepCollectionEquality().equals(other.completedCourses, _completedCourses)&&const DeepCollectionEquality().equals(other.selfReportedSkills, _selfReportedSkills));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,career,const DeepCollectionEquality().hash(_completedCourses),const DeepCollectionEquality().hash(_selfReportedSkills));
}

@override
String toString() {
    return 'GapQuery(career: $career, completedCourses: $completedCourses, selfReportedSkills: $selfReportedSkills)';
}


}

/// @nodoc
abstract mixin class _$GapQueryCopyWith<$Res> implements $GapQueryCopyWith<$Res> {
  factory _$GapQueryCopyWith(_GapQuery value, $Res Function(_GapQuery) _then) = __$GapQueryCopyWithImpl;
@override @useResult
$Res call({
 String career, List<String> completedCourses, List<String> selfReportedSkills
});




}
/// @nodoc
class __$GapQueryCopyWithImpl<$Res>
    implements _$GapQueryCopyWith<$Res> {
  __$GapQueryCopyWithImpl(this._self, this._then);

  final _GapQuery _self;
  final $Res Function(_GapQuery) _then;

/// Create a copy of GapQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? career = null,Object? completedCourses = null,Object? selfReportedSkills = null,}) {
  return _then(_GapQuery(
career: null == career ? _self.career : career // ignore: cast_nullable_to_non_nullable
as String,completedCourses: null == completedCourses ? _self._completedCourses : completedCourses // ignore: cast_nullable_to_non_nullable
as List<String>,selfReportedSkills: null == selfReportedSkills ? _self._selfReportedSkills : selfReportedSkills // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
