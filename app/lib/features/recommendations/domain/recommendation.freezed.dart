// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SkillRef {

 String get id; String get en; String get ar; int get demandPercent;
/// Create a copy of SkillRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SkillRefCopyWith<SkillRef> get copyWith => _$SkillRefCopyWithImpl<SkillRef>(this as SkillRef, _$identity);

  /// Serializes this SkillRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SkillRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SkillRef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.en, _this.en) || other.en == _this.en)&&(identical(other.ar, _this.ar) || other.ar == _this.ar)&&(identical(other.demandPercent, _this.demandPercent) || other.demandPercent == _this.demandPercent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SkillRef;
  return Object.hash(runtimeType,_this.id,_this.en,_this.ar,_this.demandPercent);
}

@override
String toString() {
  final _this = this as SkillRef;
  return 'SkillRef(id: ${_this.id}, en: ${_this.en}, ar: ${_this.ar}, demandPercent: ${_this.demandPercent})';
}


}

/// @nodoc
abstract mixin class $SkillRefCopyWith<$Res>  {
  factory $SkillRefCopyWith(SkillRef value, $Res Function(SkillRef) _then) = _$SkillRefCopyWithImpl;
@useResult
$Res call({
 String id, String en, String ar, int demandPercent
});




}
/// @nodoc
class _$SkillRefCopyWithImpl<$Res>
    implements $SkillRefCopyWith<$Res> {
  _$SkillRefCopyWithImpl(this._self, this._then);

  final SkillRef _self;
  final $Res Function(SkillRef) _then;

/// Create a copy of SkillRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? en = null,Object? ar = null,Object? demandPercent = null,}) {
  return _then(SkillRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as String,ar: null == ar ? _self.ar : ar // ignore: cast_nullable_to_non_nullable
as String,demandPercent: null == demandPercent ? _self.demandPercent : demandPercent // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SkillRef].
extension SkillRefPatterns on SkillRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SkillRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SkillRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SkillRef value)  $default,){
final _that = this;
switch (_that) {
case _SkillRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SkillRef value)?  $default,){
final _that = this;
switch (_that) {
case _SkillRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String en,  String ar,  int demandPercent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SkillRef() when $default != null:
return $default(_that.id,_that.en,_that.ar,_that.demandPercent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String en,  String ar,  int demandPercent)  $default,) {final _that = this;
switch (_that) {
case _SkillRef():
return $default(_that.id,_that.en,_that.ar,_that.demandPercent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String en,  String ar,  int demandPercent)?  $default,) {final _that = this;
switch (_that) {
case _SkillRef() when $default != null:
return $default(_that.id,_that.en,_that.ar,_that.demandPercent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SkillRef extends SkillRef {
  const _SkillRef({required this.id, required this.en, required this.ar, required this.demandPercent}): super._();
  factory _SkillRef.fromJson(Map<String, dynamic> json) => _$SkillRefFromJson(json);

@override final  String id;
@override final  String en;
@override final  String ar;
@override final  int demandPercent;

/// Create a copy of SkillRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SkillRefCopyWith<_SkillRef> get copyWith => __$SkillRefCopyWithImpl<_SkillRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SkillRefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SkillRef&&(identical(other.id, id) || other.id == id)&&(identical(other.en, en) || other.en == en)&&(identical(other.ar, ar) || other.ar == ar)&&(identical(other.demandPercent, demandPercent) || other.demandPercent == demandPercent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,en,ar,demandPercent);
}

@override
String toString() {
    return 'SkillRef(id: $id, en: $en, ar: $ar, demandPercent: $demandPercent)';
}


}

/// @nodoc
abstract mixin class _$SkillRefCopyWith<$Res> implements $SkillRefCopyWith<$Res> {
  factory _$SkillRefCopyWith(_SkillRef value, $Res Function(_SkillRef) _then) = __$SkillRefCopyWithImpl;
@override @useResult
$Res call({
 String id, String en, String ar, int demandPercent
});




}
/// @nodoc
class __$SkillRefCopyWithImpl<$Res>
    implements _$SkillRefCopyWith<$Res> {
  __$SkillRefCopyWithImpl(this._self, this._then);

  final _SkillRef _self;
  final $Res Function(_SkillRef) _then;

/// Create a copy of SkillRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? en = null,Object? ar = null,Object? demandPercent = null,}) {
  return _then(_SkillRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as String,ar: null == ar ? _self.ar : ar // ignore: cast_nullable_to_non_nullable
as String,demandPercent: null == demandPercent ? _self.demandPercent : demandPercent // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Recommendation {

 String get code; String get name; List<SkillRef> get closes;/// Total demand of the gaps this course closes; the backend ranks by it.
 double get value;
/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendationCopyWith<Recommendation> get copyWith => _$RecommendationCopyWithImpl<Recommendation>(this as Recommendation, _$identity);

  /// Serializes this Recommendation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Recommendation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Recommendation&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.closes, _this.closes)&&(identical(other.value, _this.value) || other.value == _this.value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Recommendation;
  return Object.hash(runtimeType,_this.code,_this.name,const DeepCollectionEquality().hash(_this.closes),_this.value);
}

@override
String toString() {
  final _this = this as Recommendation;
  return 'Recommendation(code: ${_this.code}, name: ${_this.name}, closes: ${_this.closes}, value: ${_this.value})';
}


}

/// @nodoc
abstract mixin class $RecommendationCopyWith<$Res>  {
  factory $RecommendationCopyWith(Recommendation value, $Res Function(Recommendation) _then) = _$RecommendationCopyWithImpl;
@useResult
$Res call({
 String code, String name, List<SkillRef> closes, double value
});




}
/// @nodoc
class _$RecommendationCopyWithImpl<$Res>
    implements $RecommendationCopyWith<$Res> {
  _$RecommendationCopyWithImpl(this._self, this._then);

  final Recommendation _self;
  final $Res Function(Recommendation) _then;

/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? name = null,Object? closes = null,Object? value = null,}) {
  return _then(Recommendation(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,closes: null == closes ? _self.closes : closes // ignore: cast_nullable_to_non_nullable
as List<SkillRef>,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Recommendation].
extension RecommendationPatterns on Recommendation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Recommendation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Recommendation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Recommendation value)  $default,){
final _that = this;
switch (_that) {
case _Recommendation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Recommendation value)?  $default,){
final _that = this;
switch (_that) {
case _Recommendation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String name,  List<SkillRef> closes,  double value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Recommendation() when $default != null:
return $default(_that.code,_that.name,_that.closes,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String name,  List<SkillRef> closes,  double value)  $default,) {final _that = this;
switch (_that) {
case _Recommendation():
return $default(_that.code,_that.name,_that.closes,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String name,  List<SkillRef> closes,  double value)?  $default,) {final _that = this;
switch (_that) {
case _Recommendation() when $default != null:
return $default(_that.code,_that.name,_that.closes,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Recommendation implements Recommendation {
  const _Recommendation({required this.code, required this.name, required  List<SkillRef> closes, required this.value}): _closes = closes;
  factory _Recommendation.fromJson(Map<String, dynamic> json) => _$RecommendationFromJson(json);

@override final  String code;
@override final  String name;
 final  List<SkillRef> _closes;
@override List<SkillRef> get closes {
  if (_closes is EqualUnmodifiableListView) return _closes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_closes);
}

/// Total demand of the gaps this course closes; the backend ranks by it.
@override final  double value;

/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendationCopyWith<_Recommendation> get copyWith => __$RecommendationCopyWithImpl<_Recommendation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecommendationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Recommendation&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.closes, _closes)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,name,const DeepCollectionEquality().hash(_closes),value);
}

@override
String toString() {
    return 'Recommendation(code: $code, name: $name, closes: $closes, value: $value)';
}


}

/// @nodoc
abstract mixin class _$RecommendationCopyWith<$Res> implements $RecommendationCopyWith<$Res> {
  factory _$RecommendationCopyWith(_Recommendation value, $Res Function(_Recommendation) _then) = __$RecommendationCopyWithImpl;
@override @useResult
$Res call({
 String code, String name, List<SkillRef> closes, double value
});




}
/// @nodoc
class __$RecommendationCopyWithImpl<$Res>
    implements _$RecommendationCopyWith<$Res> {
  __$RecommendationCopyWithImpl(this._self, this._then);

  final _Recommendation _self;
  final $Res Function(_Recommendation) _then;

/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? name = null,Object? closes = null,Object? value = null,}) {
  return _then(_Recommendation(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,closes: null == closes ? _self._closes : closes // ignore: cast_nullable_to_non_nullable
as List<SkillRef>,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$RecommendationsReport {

 String get profileId; String get career; List<Recommendation> get recommendations; ValidationInfo get validation;
/// Create a copy of RecommendationsReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendationsReportCopyWith<RecommendationsReport> get copyWith => _$RecommendationsReportCopyWithImpl<RecommendationsReport>(this as RecommendationsReport, _$identity);

  /// Serializes this RecommendationsReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RecommendationsReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecommendationsReport&&(identical(other.profileId, _this.profileId) || other.profileId == _this.profileId)&&(identical(other.career, _this.career) || other.career == _this.career)&&const DeepCollectionEquality().equals(other.recommendations, _this.recommendations)&&(identical(other.validation, _this.validation) || other.validation == _this.validation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RecommendationsReport;
  return Object.hash(runtimeType,_this.profileId,_this.career,const DeepCollectionEquality().hash(_this.recommendations),_this.validation);
}

@override
String toString() {
  final _this = this as RecommendationsReport;
  return 'RecommendationsReport(profileId: ${_this.profileId}, career: ${_this.career}, recommendations: ${_this.recommendations}, validation: ${_this.validation})';
}


}

/// @nodoc
abstract mixin class $RecommendationsReportCopyWith<$Res>  {
  factory $RecommendationsReportCopyWith(RecommendationsReport value, $Res Function(RecommendationsReport) _then) = _$RecommendationsReportCopyWithImpl;
@useResult
$Res call({
 String profileId, String career, List<Recommendation> recommendations, ValidationInfo validation
});


$ValidationInfoCopyWith<$Res> get validation;

}
/// @nodoc
class _$RecommendationsReportCopyWithImpl<$Res>
    implements $RecommendationsReportCopyWith<$Res> {
  _$RecommendationsReportCopyWithImpl(this._self, this._then);

  final RecommendationsReport _self;
  final $Res Function(RecommendationsReport) _then;

/// Create a copy of RecommendationsReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profileId = null,Object? career = null,Object? recommendations = null,Object? validation = null,}) {
  return _then(RecommendationsReport(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,career: null == career ? _self.career : career // ignore: cast_nullable_to_non_nullable
as String,recommendations: null == recommendations ? _self.recommendations : recommendations // ignore: cast_nullable_to_non_nullable
as List<Recommendation>,validation: null == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ValidationInfo,
  ));
}
/// Create a copy of RecommendationsReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ValidationInfoCopyWith<$Res> get validation {
  
  return $ValidationInfoCopyWith<$Res>(_self.validation, (value) {
    return _then(_self.copyWith(validation: value));
  });
}
}


/// Adds pattern-matching-related methods to [RecommendationsReport].
extension RecommendationsReportPatterns on RecommendationsReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecommendationsReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecommendationsReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecommendationsReport value)  $default,){
final _that = this;
switch (_that) {
case _RecommendationsReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecommendationsReport value)?  $default,){
final _that = this;
switch (_that) {
case _RecommendationsReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String profileId,  String career,  List<Recommendation> recommendations,  ValidationInfo validation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecommendationsReport() when $default != null:
return $default(_that.profileId,_that.career,_that.recommendations,_that.validation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String profileId,  String career,  List<Recommendation> recommendations,  ValidationInfo validation)  $default,) {final _that = this;
switch (_that) {
case _RecommendationsReport():
return $default(_that.profileId,_that.career,_that.recommendations,_that.validation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String profileId,  String career,  List<Recommendation> recommendations,  ValidationInfo validation)?  $default,) {final _that = this;
switch (_that) {
case _RecommendationsReport() when $default != null:
return $default(_that.profileId,_that.career,_that.recommendations,_that.validation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecommendationsReport implements RecommendationsReport {
  const _RecommendationsReport({required this.profileId, required this.career, required  List<Recommendation> recommendations, required this.validation}): _recommendations = recommendations;
  factory _RecommendationsReport.fromJson(Map<String, dynamic> json) => _$RecommendationsReportFromJson(json);

@override final  String profileId;
@override final  String career;
 final  List<Recommendation> _recommendations;
@override List<Recommendation> get recommendations {
  if (_recommendations is EqualUnmodifiableListView) return _recommendations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recommendations);
}

@override final  ValidationInfo validation;

/// Create a copy of RecommendationsReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendationsReportCopyWith<_RecommendationsReport> get copyWith => __$RecommendationsReportCopyWithImpl<_RecommendationsReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecommendationsReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecommendationsReport&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.career, career) || other.career == career)&&const DeepCollectionEquality().equals(other.recommendations, _recommendations)&&(identical(other.validation, validation) || other.validation == validation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,profileId,career,const DeepCollectionEquality().hash(_recommendations),validation);
}

@override
String toString() {
    return 'RecommendationsReport(profileId: $profileId, career: $career, recommendations: $recommendations, validation: $validation)';
}


}

/// @nodoc
abstract mixin class _$RecommendationsReportCopyWith<$Res> implements $RecommendationsReportCopyWith<$Res> {
  factory _$RecommendationsReportCopyWith(_RecommendationsReport value, $Res Function(_RecommendationsReport) _then) = __$RecommendationsReportCopyWithImpl;
@override @useResult
$Res call({
 String profileId, String career, List<Recommendation> recommendations, ValidationInfo validation
});


@override $ValidationInfoCopyWith<$Res> get validation;

}
/// @nodoc
class __$RecommendationsReportCopyWithImpl<$Res>
    implements _$RecommendationsReportCopyWith<$Res> {
  __$RecommendationsReportCopyWithImpl(this._self, this._then);

  final _RecommendationsReport _self;
  final $Res Function(_RecommendationsReport) _then;

/// Create a copy of RecommendationsReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profileId = null,Object? career = null,Object? recommendations = null,Object? validation = null,}) {
  return _then(_RecommendationsReport(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,career: null == career ? _self.career : career // ignore: cast_nullable_to_non_nullable
as String,recommendations: null == recommendations ? _self._recommendations : recommendations // ignore: cast_nullable_to_non_nullable
as List<Recommendation>,validation: null == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ValidationInfo,
  ));
}

/// Create a copy of RecommendationsReport
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
