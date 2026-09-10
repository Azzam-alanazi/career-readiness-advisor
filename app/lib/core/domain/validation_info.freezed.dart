// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'validation_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ValidationInfo {

 bool get gatePassed; double? get bestF1; double? get gateMinF1; bool get courseMappingValidated; String get note;
/// Create a copy of ValidationInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidationInfoCopyWith<ValidationInfo> get copyWith => _$ValidationInfoCopyWithImpl<ValidationInfo>(this as ValidationInfo, _$identity);

  /// Serializes this ValidationInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ValidationInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidationInfo&&(identical(other.gatePassed, _this.gatePassed) || other.gatePassed == _this.gatePassed)&&(identical(other.bestF1, _this.bestF1) || other.bestF1 == _this.bestF1)&&(identical(other.gateMinF1, _this.gateMinF1) || other.gateMinF1 == _this.gateMinF1)&&(identical(other.courseMappingValidated, _this.courseMappingValidated) || other.courseMappingValidated == _this.courseMappingValidated)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ValidationInfo;
  return Object.hash(runtimeType,_this.gatePassed,_this.bestF1,_this.gateMinF1,_this.courseMappingValidated,_this.note);
}

@override
String toString() {
  final _this = this as ValidationInfo;
  return 'ValidationInfo(gatePassed: ${_this.gatePassed}, bestF1: ${_this.bestF1}, gateMinF1: ${_this.gateMinF1}, courseMappingValidated: ${_this.courseMappingValidated}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $ValidationInfoCopyWith<$Res>  {
  factory $ValidationInfoCopyWith(ValidationInfo value, $Res Function(ValidationInfo) _then) = _$ValidationInfoCopyWithImpl;
@useResult
$Res call({
 bool gatePassed, double? bestF1, double? gateMinF1, bool courseMappingValidated, String note
});




}
/// @nodoc
class _$ValidationInfoCopyWithImpl<$Res>
    implements $ValidationInfoCopyWith<$Res> {
  _$ValidationInfoCopyWithImpl(this._self, this._then);

  final ValidationInfo _self;
  final $Res Function(ValidationInfo) _then;

/// Create a copy of ValidationInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gatePassed = null,Object? bestF1 = freezed,Object? gateMinF1 = freezed,Object? courseMappingValidated = null,Object? note = null,}) {
  return _then(ValidationInfo(
gatePassed: null == gatePassed ? _self.gatePassed : gatePassed // ignore: cast_nullable_to_non_nullable
as bool,bestF1: freezed == bestF1 ? _self.bestF1 : bestF1 // ignore: cast_nullable_to_non_nullable
as double?,gateMinF1: freezed == gateMinF1 ? _self.gateMinF1 : gateMinF1 // ignore: cast_nullable_to_non_nullable
as double?,courseMappingValidated: null == courseMappingValidated ? _self.courseMappingValidated : courseMappingValidated // ignore: cast_nullable_to_non_nullable
as bool,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ValidationInfo].
extension ValidationInfoPatterns on ValidationInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ValidationInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ValidationInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ValidationInfo value)  $default,){
final _that = this;
switch (_that) {
case _ValidationInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ValidationInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ValidationInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool gatePassed,  double? bestF1,  double? gateMinF1,  bool courseMappingValidated,  String note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ValidationInfo() when $default != null:
return $default(_that.gatePassed,_that.bestF1,_that.gateMinF1,_that.courseMappingValidated,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool gatePassed,  double? bestF1,  double? gateMinF1,  bool courseMappingValidated,  String note)  $default,) {final _that = this;
switch (_that) {
case _ValidationInfo():
return $default(_that.gatePassed,_that.bestF1,_that.gateMinF1,_that.courseMappingValidated,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool gatePassed,  double? bestF1,  double? gateMinF1,  bool courseMappingValidated,  String note)?  $default,) {final _that = this;
switch (_that) {
case _ValidationInfo() when $default != null:
return $default(_that.gatePassed,_that.bestF1,_that.gateMinF1,_that.courseMappingValidated,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ValidationInfo implements ValidationInfo {
  const _ValidationInfo({required this.gatePassed, this.bestF1, this.gateMinF1, required this.courseMappingValidated, required this.note});
  factory _ValidationInfo.fromJson(Map<String, dynamic> json) => _$ValidationInfoFromJson(json);

@override final  bool gatePassed;
@override final  double? bestF1;
@override final  double? gateMinF1;
@override final  bool courseMappingValidated;
@override final  String note;

/// Create a copy of ValidationInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ValidationInfoCopyWith<_ValidationInfo> get copyWith => __$ValidationInfoCopyWithImpl<_ValidationInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ValidationInfoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ValidationInfo&&(identical(other.gatePassed, gatePassed) || other.gatePassed == gatePassed)&&(identical(other.bestF1, bestF1) || other.bestF1 == bestF1)&&(identical(other.gateMinF1, gateMinF1) || other.gateMinF1 == gateMinF1)&&(identical(other.courseMappingValidated, courseMappingValidated) || other.courseMappingValidated == courseMappingValidated)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,gatePassed,bestF1,gateMinF1,courseMappingValidated,note);
}

@override
String toString() {
    return 'ValidationInfo(gatePassed: $gatePassed, bestF1: $bestF1, gateMinF1: $gateMinF1, courseMappingValidated: $courseMappingValidated, note: $note)';
}


}

/// @nodoc
abstract mixin class _$ValidationInfoCopyWith<$Res> implements $ValidationInfoCopyWith<$Res> {
  factory _$ValidationInfoCopyWith(_ValidationInfo value, $Res Function(_ValidationInfo) _then) = __$ValidationInfoCopyWithImpl;
@override @useResult
$Res call({
 bool gatePassed, double? bestF1, double? gateMinF1, bool courseMappingValidated, String note
});




}
/// @nodoc
class __$ValidationInfoCopyWithImpl<$Res>
    implements _$ValidationInfoCopyWith<$Res> {
  __$ValidationInfoCopyWithImpl(this._self, this._then);

  final _ValidationInfo _self;
  final $Res Function(_ValidationInfo) _then;

/// Create a copy of ValidationInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gatePassed = null,Object? bestF1 = freezed,Object? gateMinF1 = freezed,Object? courseMappingValidated = null,Object? note = null,}) {
  return _then(_ValidationInfo(
gatePassed: null == gatePassed ? _self.gatePassed : gatePassed // ignore: cast_nullable_to_non_nullable
as bool,bestF1: freezed == bestF1 ? _self.bestF1 : bestF1 // ignore: cast_nullable_to_non_nullable
as double?,gateMinF1: freezed == gateMinF1 ? _self.gateMinF1 : gateMinF1 // ignore: cast_nullable_to_non_nullable
as double?,courseMappingValidated: null == courseMappingValidated ? _self.courseMappingValidated : courseMappingValidated // ignore: cast_nullable_to_non_nullable
as bool,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
