// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'curriculum_gap.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CurriculumGap {

/// The career asked for; null for every career.
 String? get career; int get postingCount;/// The share of a career's postings a skill needs to count as demanded:
/// the same threshold a student's gap uses.
 double get minDemand; int get demanded; int get taught;/// taught / demanded. Each skill counts once, however many postings name it.
 double get coverage; int get coveragePercent;/// Demanded skills no course teaches, most in demand first -- the
/// backend's order, rendered as received.
 List<CurriculumSkill> get uncovered;/// Skills the catalog teaches that no posting in scope names.
 List<TaughtSkill> get notAsked;/// Skills some posting names, but too few to count as demanded in any
/// career in scope -- in neither list above, so listed on their own.
 List<BelowThresholdSkill> get belowThreshold;/// Every career's coverage, whatever the scope.
 List<CareerCoverage> get perCareer; ValidationInfo get validation;
/// Create a copy of CurriculumGap
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurriculumGapCopyWith<CurriculumGap> get copyWith => _$CurriculumGapCopyWithImpl<CurriculumGap>(this as CurriculumGap, _$identity);

  /// Serializes this CurriculumGap to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CurriculumGap;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurriculumGap&&(identical(other.career, _this.career) || other.career == _this.career)&&(identical(other.postingCount, _this.postingCount) || other.postingCount == _this.postingCount)&&(identical(other.minDemand, _this.minDemand) || other.minDemand == _this.minDemand)&&(identical(other.demanded, _this.demanded) || other.demanded == _this.demanded)&&(identical(other.taught, _this.taught) || other.taught == _this.taught)&&(identical(other.coverage, _this.coverage) || other.coverage == _this.coverage)&&(identical(other.coveragePercent, _this.coveragePercent) || other.coveragePercent == _this.coveragePercent)&&const DeepCollectionEquality().equals(other.uncovered, _this.uncovered)&&const DeepCollectionEquality().equals(other.notAsked, _this.notAsked)&&const DeepCollectionEquality().equals(other.belowThreshold, _this.belowThreshold)&&const DeepCollectionEquality().equals(other.perCareer, _this.perCareer)&&(identical(other.validation, _this.validation) || other.validation == _this.validation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CurriculumGap;
  return Object.hash(runtimeType,_this.career,_this.postingCount,_this.minDemand,_this.demanded,_this.taught,_this.coverage,_this.coveragePercent,const DeepCollectionEquality().hash(_this.uncovered),const DeepCollectionEquality().hash(_this.notAsked),const DeepCollectionEquality().hash(_this.belowThreshold),const DeepCollectionEquality().hash(_this.perCareer),_this.validation);
}

@override
String toString() {
  final _this = this as CurriculumGap;
  return 'CurriculumGap(career: ${_this.career}, postingCount: ${_this.postingCount}, minDemand: ${_this.minDemand}, demanded: ${_this.demanded}, taught: ${_this.taught}, coverage: ${_this.coverage}, coveragePercent: ${_this.coveragePercent}, uncovered: ${_this.uncovered}, notAsked: ${_this.notAsked}, belowThreshold: ${_this.belowThreshold}, perCareer: ${_this.perCareer}, validation: ${_this.validation})';
}


}

/// @nodoc
abstract mixin class $CurriculumGapCopyWith<$Res>  {
  factory $CurriculumGapCopyWith(CurriculumGap value, $Res Function(CurriculumGap) _then) = _$CurriculumGapCopyWithImpl;
@useResult
$Res call({
 String? career, int postingCount, double minDemand, int demanded, int taught, double coverage, int coveragePercent, List<CurriculumSkill> uncovered, List<TaughtSkill> notAsked, List<BelowThresholdSkill> belowThreshold, List<CareerCoverage> perCareer, ValidationInfo validation
});


$ValidationInfoCopyWith<$Res> get validation;

}
/// @nodoc
class _$CurriculumGapCopyWithImpl<$Res>
    implements $CurriculumGapCopyWith<$Res> {
  _$CurriculumGapCopyWithImpl(this._self, this._then);

  final CurriculumGap _self;
  final $Res Function(CurriculumGap) _then;

/// Create a copy of CurriculumGap
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? career = freezed,Object? postingCount = null,Object? minDemand = null,Object? demanded = null,Object? taught = null,Object? coverage = null,Object? coveragePercent = null,Object? uncovered = null,Object? notAsked = null,Object? belowThreshold = null,Object? perCareer = null,Object? validation = null,}) {
  return _then(CurriculumGap(
career: freezed == career ? _self.career : career // ignore: cast_nullable_to_non_nullable
as String?,postingCount: null == postingCount ? _self.postingCount : postingCount // ignore: cast_nullable_to_non_nullable
as int,minDemand: null == minDemand ? _self.minDemand : minDemand // ignore: cast_nullable_to_non_nullable
as double,demanded: null == demanded ? _self.demanded : demanded // ignore: cast_nullable_to_non_nullable
as int,taught: null == taught ? _self.taught : taught // ignore: cast_nullable_to_non_nullable
as int,coverage: null == coverage ? _self.coverage : coverage // ignore: cast_nullable_to_non_nullable
as double,coveragePercent: null == coveragePercent ? _self.coveragePercent : coveragePercent // ignore: cast_nullable_to_non_nullable
as int,uncovered: null == uncovered ? _self.uncovered : uncovered // ignore: cast_nullable_to_non_nullable
as List<CurriculumSkill>,notAsked: null == notAsked ? _self.notAsked : notAsked // ignore: cast_nullable_to_non_nullable
as List<TaughtSkill>,belowThreshold: null == belowThreshold ? _self.belowThreshold : belowThreshold // ignore: cast_nullable_to_non_nullable
as List<BelowThresholdSkill>,perCareer: null == perCareer ? _self.perCareer : perCareer // ignore: cast_nullable_to_non_nullable
as List<CareerCoverage>,validation: null == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ValidationInfo,
  ));
}
/// Create a copy of CurriculumGap
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ValidationInfoCopyWith<$Res> get validation {
  
  return $ValidationInfoCopyWith<$Res>(_self.validation, (value) {
    return _then(_self.copyWith(validation: value));
  });
}
}


/// Adds pattern-matching-related methods to [CurriculumGap].
extension CurriculumGapPatterns on CurriculumGap {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurriculumGap value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurriculumGap() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurriculumGap value)  $default,){
final _that = this;
switch (_that) {
case _CurriculumGap():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurriculumGap value)?  $default,){
final _that = this;
switch (_that) {
case _CurriculumGap() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? career,  int postingCount,  double minDemand,  int demanded,  int taught,  double coverage,  int coveragePercent,  List<CurriculumSkill> uncovered,  List<TaughtSkill> notAsked,  List<BelowThresholdSkill> belowThreshold,  List<CareerCoverage> perCareer,  ValidationInfo validation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurriculumGap() when $default != null:
return $default(_that.career,_that.postingCount,_that.minDemand,_that.demanded,_that.taught,_that.coverage,_that.coveragePercent,_that.uncovered,_that.notAsked,_that.belowThreshold,_that.perCareer,_that.validation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? career,  int postingCount,  double minDemand,  int demanded,  int taught,  double coverage,  int coveragePercent,  List<CurriculumSkill> uncovered,  List<TaughtSkill> notAsked,  List<BelowThresholdSkill> belowThreshold,  List<CareerCoverage> perCareer,  ValidationInfo validation)  $default,) {final _that = this;
switch (_that) {
case _CurriculumGap():
return $default(_that.career,_that.postingCount,_that.minDemand,_that.demanded,_that.taught,_that.coverage,_that.coveragePercent,_that.uncovered,_that.notAsked,_that.belowThreshold,_that.perCareer,_that.validation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? career,  int postingCount,  double minDemand,  int demanded,  int taught,  double coverage,  int coveragePercent,  List<CurriculumSkill> uncovered,  List<TaughtSkill> notAsked,  List<BelowThresholdSkill> belowThreshold,  List<CareerCoverage> perCareer,  ValidationInfo validation)?  $default,) {final _that = this;
switch (_that) {
case _CurriculumGap() when $default != null:
return $default(_that.career,_that.postingCount,_that.minDemand,_that.demanded,_that.taught,_that.coverage,_that.coveragePercent,_that.uncovered,_that.notAsked,_that.belowThreshold,_that.perCareer,_that.validation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CurriculumGap implements CurriculumGap {
  const _CurriculumGap({this.career, required this.postingCount, required this.minDemand, required this.demanded, required this.taught, required this.coverage, required this.coveragePercent, required  List<CurriculumSkill> uncovered, required  List<TaughtSkill> notAsked, required  List<BelowThresholdSkill> belowThreshold, required  List<CareerCoverage> perCareer, required this.validation}): _uncovered = uncovered,_notAsked = notAsked,_belowThreshold = belowThreshold,_perCareer = perCareer;
  factory _CurriculumGap.fromJson(Map<String, dynamic> json) => _$CurriculumGapFromJson(json);

/// The career asked for; null for every career.
@override final  String? career;
@override final  int postingCount;
/// The share of a career's postings a skill needs to count as demanded:
/// the same threshold a student's gap uses.
@override final  double minDemand;
@override final  int demanded;
@override final  int taught;
/// taught / demanded. Each skill counts once, however many postings name it.
@override final  double coverage;
@override final  int coveragePercent;
/// Demanded skills no course teaches, most in demand first -- the
/// backend's order, rendered as received.
 final  List<CurriculumSkill> _uncovered;
/// Demanded skills no course teaches, most in demand first -- the
/// backend's order, rendered as received.
@override List<CurriculumSkill> get uncovered {
  if (_uncovered is EqualUnmodifiableListView) return _uncovered;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_uncovered);
}

/// Skills the catalog teaches that no posting in scope names.
 final  List<TaughtSkill> _notAsked;
/// Skills the catalog teaches that no posting in scope names.
@override List<TaughtSkill> get notAsked {
  if (_notAsked is EqualUnmodifiableListView) return _notAsked;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notAsked);
}

/// Skills some posting names, but too few to count as demanded in any
/// career in scope -- in neither list above, so listed on their own.
 final  List<BelowThresholdSkill> _belowThreshold;
/// Skills some posting names, but too few to count as demanded in any
/// career in scope -- in neither list above, so listed on their own.
@override List<BelowThresholdSkill> get belowThreshold {
  if (_belowThreshold is EqualUnmodifiableListView) return _belowThreshold;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_belowThreshold);
}

/// Every career's coverage, whatever the scope.
 final  List<CareerCoverage> _perCareer;
/// Every career's coverage, whatever the scope.
@override List<CareerCoverage> get perCareer {
  if (_perCareer is EqualUnmodifiableListView) return _perCareer;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_perCareer);
}

@override final  ValidationInfo validation;

/// Create a copy of CurriculumGap
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurriculumGapCopyWith<_CurriculumGap> get copyWith => __$CurriculumGapCopyWithImpl<_CurriculumGap>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurriculumGapToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurriculumGap&&(identical(other.career, career) || other.career == career)&&(identical(other.postingCount, postingCount) || other.postingCount == postingCount)&&(identical(other.minDemand, minDemand) || other.minDemand == minDemand)&&(identical(other.demanded, demanded) || other.demanded == demanded)&&(identical(other.taught, taught) || other.taught == taught)&&(identical(other.coverage, coverage) || other.coverage == coverage)&&(identical(other.coveragePercent, coveragePercent) || other.coveragePercent == coveragePercent)&&const DeepCollectionEquality().equals(other.uncovered, _uncovered)&&const DeepCollectionEquality().equals(other.notAsked, _notAsked)&&const DeepCollectionEquality().equals(other.belowThreshold, _belowThreshold)&&const DeepCollectionEquality().equals(other.perCareer, _perCareer)&&(identical(other.validation, validation) || other.validation == validation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,career,postingCount,minDemand,demanded,taught,coverage,coveragePercent,const DeepCollectionEquality().hash(_uncovered),const DeepCollectionEquality().hash(_notAsked),const DeepCollectionEquality().hash(_belowThreshold),const DeepCollectionEquality().hash(_perCareer),validation);
}

@override
String toString() {
    return 'CurriculumGap(career: $career, postingCount: $postingCount, minDemand: $minDemand, demanded: $demanded, taught: $taught, coverage: $coverage, coveragePercent: $coveragePercent, uncovered: $uncovered, notAsked: $notAsked, belowThreshold: $belowThreshold, perCareer: $perCareer, validation: $validation)';
}


}

/// @nodoc
abstract mixin class _$CurriculumGapCopyWith<$Res> implements $CurriculumGapCopyWith<$Res> {
  factory _$CurriculumGapCopyWith(_CurriculumGap value, $Res Function(_CurriculumGap) _then) = __$CurriculumGapCopyWithImpl;
@override @useResult
$Res call({
 String? career, int postingCount, double minDemand, int demanded, int taught, double coverage, int coveragePercent, List<CurriculumSkill> uncovered, List<TaughtSkill> notAsked, List<BelowThresholdSkill> belowThreshold, List<CareerCoverage> perCareer, ValidationInfo validation
});


@override $ValidationInfoCopyWith<$Res> get validation;

}
/// @nodoc
class __$CurriculumGapCopyWithImpl<$Res>
    implements _$CurriculumGapCopyWith<$Res> {
  __$CurriculumGapCopyWithImpl(this._self, this._then);

  final _CurriculumGap _self;
  final $Res Function(_CurriculumGap) _then;

/// Create a copy of CurriculumGap
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? career = freezed,Object? postingCount = null,Object? minDemand = null,Object? demanded = null,Object? taught = null,Object? coverage = null,Object? coveragePercent = null,Object? uncovered = null,Object? notAsked = null,Object? belowThreshold = null,Object? perCareer = null,Object? validation = null,}) {
  return _then(_CurriculumGap(
career: freezed == career ? _self.career : career // ignore: cast_nullable_to_non_nullable
as String?,postingCount: null == postingCount ? _self.postingCount : postingCount // ignore: cast_nullable_to_non_nullable
as int,minDemand: null == minDemand ? _self.minDemand : minDemand // ignore: cast_nullable_to_non_nullable
as double,demanded: null == demanded ? _self.demanded : demanded // ignore: cast_nullable_to_non_nullable
as int,taught: null == taught ? _self.taught : taught // ignore: cast_nullable_to_non_nullable
as int,coverage: null == coverage ? _self.coverage : coverage // ignore: cast_nullable_to_non_nullable
as double,coveragePercent: null == coveragePercent ? _self.coveragePercent : coveragePercent // ignore: cast_nullable_to_non_nullable
as int,uncovered: null == uncovered ? _self._uncovered : uncovered // ignore: cast_nullable_to_non_nullable
as List<CurriculumSkill>,notAsked: null == notAsked ? _self._notAsked : notAsked // ignore: cast_nullable_to_non_nullable
as List<TaughtSkill>,belowThreshold: null == belowThreshold ? _self._belowThreshold : belowThreshold // ignore: cast_nullable_to_non_nullable
as List<BelowThresholdSkill>,perCareer: null == perCareer ? _self._perCareer : perCareer // ignore: cast_nullable_to_non_nullable
as List<CareerCoverage>,validation: null == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ValidationInfo,
  ));
}

/// Create a copy of CurriculumGap
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ValidationInfoCopyWith<$Res> get validation {
  
  return $ValidationInfoCopyWith<$Res>(_self.validation, (value) {
    return _then(_self.copyWith(validation: value));
  });
}
}


/// @nodoc
mixin _$CurriculumSkill {

 String get id; String get en; String get ar; String get category;/// Postings in scope that name the skill, and their share of all of them.
 int get postings; double get demand; int get demandPercent;/// Careers in scope that count it as demanded.
 List<String> get careers;
/// Create a copy of CurriculumSkill
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurriculumSkillCopyWith<CurriculumSkill> get copyWith => _$CurriculumSkillCopyWithImpl<CurriculumSkill>(this as CurriculumSkill, _$identity);

  /// Serializes this CurriculumSkill to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CurriculumSkill;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurriculumSkill&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.en, _this.en) || other.en == _this.en)&&(identical(other.ar, _this.ar) || other.ar == _this.ar)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.postings, _this.postings) || other.postings == _this.postings)&&(identical(other.demand, _this.demand) || other.demand == _this.demand)&&(identical(other.demandPercent, _this.demandPercent) || other.demandPercent == _this.demandPercent)&&const DeepCollectionEquality().equals(other.careers, _this.careers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CurriculumSkill;
  return Object.hash(runtimeType,_this.id,_this.en,_this.ar,_this.category,_this.postings,_this.demand,_this.demandPercent,const DeepCollectionEquality().hash(_this.careers));
}

@override
String toString() {
  final _this = this as CurriculumSkill;
  return 'CurriculumSkill(id: ${_this.id}, en: ${_this.en}, ar: ${_this.ar}, category: ${_this.category}, postings: ${_this.postings}, demand: ${_this.demand}, demandPercent: ${_this.demandPercent}, careers: ${_this.careers})';
}


}

/// @nodoc
abstract mixin class $CurriculumSkillCopyWith<$Res>  {
  factory $CurriculumSkillCopyWith(CurriculumSkill value, $Res Function(CurriculumSkill) _then) = _$CurriculumSkillCopyWithImpl;
@useResult
$Res call({
 String id, String en, String ar, String category, int postings, double demand, int demandPercent, List<String> careers
});




}
/// @nodoc
class _$CurriculumSkillCopyWithImpl<$Res>
    implements $CurriculumSkillCopyWith<$Res> {
  _$CurriculumSkillCopyWithImpl(this._self, this._then);

  final CurriculumSkill _self;
  final $Res Function(CurriculumSkill) _then;

/// Create a copy of CurriculumSkill
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? en = null,Object? ar = null,Object? category = null,Object? postings = null,Object? demand = null,Object? demandPercent = null,Object? careers = null,}) {
  return _then(CurriculumSkill(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as String,ar: null == ar ? _self.ar : ar // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,postings: null == postings ? _self.postings : postings // ignore: cast_nullable_to_non_nullable
as int,demand: null == demand ? _self.demand : demand // ignore: cast_nullable_to_non_nullable
as double,demandPercent: null == demandPercent ? _self.demandPercent : demandPercent // ignore: cast_nullable_to_non_nullable
as int,careers: null == careers ? _self.careers : careers // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CurriculumSkill].
extension CurriculumSkillPatterns on CurriculumSkill {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurriculumSkill value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurriculumSkill() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurriculumSkill value)  $default,){
final _that = this;
switch (_that) {
case _CurriculumSkill():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurriculumSkill value)?  $default,){
final _that = this;
switch (_that) {
case _CurriculumSkill() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String en,  String ar,  String category,  int postings,  double demand,  int demandPercent,  List<String> careers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurriculumSkill() when $default != null:
return $default(_that.id,_that.en,_that.ar,_that.category,_that.postings,_that.demand,_that.demandPercent,_that.careers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String en,  String ar,  String category,  int postings,  double demand,  int demandPercent,  List<String> careers)  $default,) {final _that = this;
switch (_that) {
case _CurriculumSkill():
return $default(_that.id,_that.en,_that.ar,_that.category,_that.postings,_that.demand,_that.demandPercent,_that.careers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String en,  String ar,  String category,  int postings,  double demand,  int demandPercent,  List<String> careers)?  $default,) {final _that = this;
switch (_that) {
case _CurriculumSkill() when $default != null:
return $default(_that.id,_that.en,_that.ar,_that.category,_that.postings,_that.demand,_that.demandPercent,_that.careers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CurriculumSkill extends CurriculumSkill {
  const _CurriculumSkill({required this.id, required this.en, required this.ar, required this.category, required this.postings, required this.demand, required this.demandPercent, required  List<String> careers}): _careers = careers,super._();
  factory _CurriculumSkill.fromJson(Map<String, dynamic> json) => _$CurriculumSkillFromJson(json);

@override final  String id;
@override final  String en;
@override final  String ar;
@override final  String category;
/// Postings in scope that name the skill, and their share of all of them.
@override final  int postings;
@override final  double demand;
@override final  int demandPercent;
/// Careers in scope that count it as demanded.
 final  List<String> _careers;
/// Careers in scope that count it as demanded.
@override List<String> get careers {
  if (_careers is EqualUnmodifiableListView) return _careers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_careers);
}


/// Create a copy of CurriculumSkill
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurriculumSkillCopyWith<_CurriculumSkill> get copyWith => __$CurriculumSkillCopyWithImpl<_CurriculumSkill>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurriculumSkillToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurriculumSkill&&(identical(other.id, id) || other.id == id)&&(identical(other.en, en) || other.en == en)&&(identical(other.ar, ar) || other.ar == ar)&&(identical(other.category, category) || other.category == category)&&(identical(other.postings, postings) || other.postings == postings)&&(identical(other.demand, demand) || other.demand == demand)&&(identical(other.demandPercent, demandPercent) || other.demandPercent == demandPercent)&&const DeepCollectionEquality().equals(other.careers, _careers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,en,ar,category,postings,demand,demandPercent,const DeepCollectionEquality().hash(_careers));
}

@override
String toString() {
    return 'CurriculumSkill(id: $id, en: $en, ar: $ar, category: $category, postings: $postings, demand: $demand, demandPercent: $demandPercent, careers: $careers)';
}


}

/// @nodoc
abstract mixin class _$CurriculumSkillCopyWith<$Res> implements $CurriculumSkillCopyWith<$Res> {
  factory _$CurriculumSkillCopyWith(_CurriculumSkill value, $Res Function(_CurriculumSkill) _then) = __$CurriculumSkillCopyWithImpl;
@override @useResult
$Res call({
 String id, String en, String ar, String category, int postings, double demand, int demandPercent, List<String> careers
});




}
/// @nodoc
class __$CurriculumSkillCopyWithImpl<$Res>
    implements _$CurriculumSkillCopyWith<$Res> {
  __$CurriculumSkillCopyWithImpl(this._self, this._then);

  final _CurriculumSkill _self;
  final $Res Function(_CurriculumSkill) _then;

/// Create a copy of CurriculumSkill
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? en = null,Object? ar = null,Object? category = null,Object? postings = null,Object? demand = null,Object? demandPercent = null,Object? careers = null,}) {
  return _then(_CurriculumSkill(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as String,ar: null == ar ? _self.ar : ar // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,postings: null == postings ? _self.postings : postings // ignore: cast_nullable_to_non_nullable
as int,demand: null == demand ? _self.demand : demand // ignore: cast_nullable_to_non_nullable
as double,demandPercent: null == demandPercent ? _self.demandPercent : demandPercent // ignore: cast_nullable_to_non_nullable
as int,careers: null == careers ? _self._careers : careers // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$TaughtSkill {

 String get id; String get en; String get ar; String get category;/// Codes of the catalog courses that teach it.
 List<String> get courses;
/// Create a copy of TaughtSkill
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaughtSkillCopyWith<TaughtSkill> get copyWith => _$TaughtSkillCopyWithImpl<TaughtSkill>(this as TaughtSkill, _$identity);

  /// Serializes this TaughtSkill to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TaughtSkill;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaughtSkill&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.en, _this.en) || other.en == _this.en)&&(identical(other.ar, _this.ar) || other.ar == _this.ar)&&(identical(other.category, _this.category) || other.category == _this.category)&&const DeepCollectionEquality().equals(other.courses, _this.courses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TaughtSkill;
  return Object.hash(runtimeType,_this.id,_this.en,_this.ar,_this.category,const DeepCollectionEquality().hash(_this.courses));
}

@override
String toString() {
  final _this = this as TaughtSkill;
  return 'TaughtSkill(id: ${_this.id}, en: ${_this.en}, ar: ${_this.ar}, category: ${_this.category}, courses: ${_this.courses})';
}


}

/// @nodoc
abstract mixin class $TaughtSkillCopyWith<$Res>  {
  factory $TaughtSkillCopyWith(TaughtSkill value, $Res Function(TaughtSkill) _then) = _$TaughtSkillCopyWithImpl;
@useResult
$Res call({
 String id, String en, String ar, String category, List<String> courses
});




}
/// @nodoc
class _$TaughtSkillCopyWithImpl<$Res>
    implements $TaughtSkillCopyWith<$Res> {
  _$TaughtSkillCopyWithImpl(this._self, this._then);

  final TaughtSkill _self;
  final $Res Function(TaughtSkill) _then;

/// Create a copy of TaughtSkill
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? en = null,Object? ar = null,Object? category = null,Object? courses = null,}) {
  return _then(TaughtSkill(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as String,ar: null == ar ? _self.ar : ar // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,courses: null == courses ? _self.courses : courses // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [TaughtSkill].
extension TaughtSkillPatterns on TaughtSkill {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaughtSkill value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaughtSkill() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaughtSkill value)  $default,){
final _that = this;
switch (_that) {
case _TaughtSkill():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaughtSkill value)?  $default,){
final _that = this;
switch (_that) {
case _TaughtSkill() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String en,  String ar,  String category,  List<String> courses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaughtSkill() when $default != null:
return $default(_that.id,_that.en,_that.ar,_that.category,_that.courses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String en,  String ar,  String category,  List<String> courses)  $default,) {final _that = this;
switch (_that) {
case _TaughtSkill():
return $default(_that.id,_that.en,_that.ar,_that.category,_that.courses);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String en,  String ar,  String category,  List<String> courses)?  $default,) {final _that = this;
switch (_that) {
case _TaughtSkill() when $default != null:
return $default(_that.id,_that.en,_that.ar,_that.category,_that.courses);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaughtSkill extends TaughtSkill {
  const _TaughtSkill({required this.id, required this.en, required this.ar, required this.category, required  List<String> courses}): _courses = courses,super._();
  factory _TaughtSkill.fromJson(Map<String, dynamic> json) => _$TaughtSkillFromJson(json);

@override final  String id;
@override final  String en;
@override final  String ar;
@override final  String category;
/// Codes of the catalog courses that teach it.
 final  List<String> _courses;
/// Codes of the catalog courses that teach it.
@override List<String> get courses {
  if (_courses is EqualUnmodifiableListView) return _courses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_courses);
}


/// Create a copy of TaughtSkill
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaughtSkillCopyWith<_TaughtSkill> get copyWith => __$TaughtSkillCopyWithImpl<_TaughtSkill>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaughtSkillToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaughtSkill&&(identical(other.id, id) || other.id == id)&&(identical(other.en, en) || other.en == en)&&(identical(other.ar, ar) || other.ar == ar)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.courses, _courses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,en,ar,category,const DeepCollectionEquality().hash(_courses));
}

@override
String toString() {
    return 'TaughtSkill(id: $id, en: $en, ar: $ar, category: $category, courses: $courses)';
}


}

/// @nodoc
abstract mixin class _$TaughtSkillCopyWith<$Res> implements $TaughtSkillCopyWith<$Res> {
  factory _$TaughtSkillCopyWith(_TaughtSkill value, $Res Function(_TaughtSkill) _then) = __$TaughtSkillCopyWithImpl;
@override @useResult
$Res call({
 String id, String en, String ar, String category, List<String> courses
});




}
/// @nodoc
class __$TaughtSkillCopyWithImpl<$Res>
    implements _$TaughtSkillCopyWith<$Res> {
  __$TaughtSkillCopyWithImpl(this._self, this._then);

  final _TaughtSkill _self;
  final $Res Function(_TaughtSkill) _then;

/// Create a copy of TaughtSkill
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? en = null,Object? ar = null,Object? category = null,Object? courses = null,}) {
  return _then(_TaughtSkill(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as String,ar: null == ar ? _self.ar : ar // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,courses: null == courses ? _self._courses : courses // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$BelowThresholdSkill {

 String get id; String get en; String get ar; String get category;/// Postings in scope that name it, and the careers they belong to.
 int get postings; List<String> get careers;/// Catalog courses that teach it; empty when none does.
 List<String> get courses;
/// Create a copy of BelowThresholdSkill
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BelowThresholdSkillCopyWith<BelowThresholdSkill> get copyWith => _$BelowThresholdSkillCopyWithImpl<BelowThresholdSkill>(this as BelowThresholdSkill, _$identity);

  /// Serializes this BelowThresholdSkill to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BelowThresholdSkill;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BelowThresholdSkill&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.en, _this.en) || other.en == _this.en)&&(identical(other.ar, _this.ar) || other.ar == _this.ar)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.postings, _this.postings) || other.postings == _this.postings)&&const DeepCollectionEquality().equals(other.careers, _this.careers)&&const DeepCollectionEquality().equals(other.courses, _this.courses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BelowThresholdSkill;
  return Object.hash(runtimeType,_this.id,_this.en,_this.ar,_this.category,_this.postings,const DeepCollectionEquality().hash(_this.careers),const DeepCollectionEquality().hash(_this.courses));
}

@override
String toString() {
  final _this = this as BelowThresholdSkill;
  return 'BelowThresholdSkill(id: ${_this.id}, en: ${_this.en}, ar: ${_this.ar}, category: ${_this.category}, postings: ${_this.postings}, careers: ${_this.careers}, courses: ${_this.courses})';
}


}

/// @nodoc
abstract mixin class $BelowThresholdSkillCopyWith<$Res>  {
  factory $BelowThresholdSkillCopyWith(BelowThresholdSkill value, $Res Function(BelowThresholdSkill) _then) = _$BelowThresholdSkillCopyWithImpl;
@useResult
$Res call({
 String id, String en, String ar, String category, int postings, List<String> careers, List<String> courses
});




}
/// @nodoc
class _$BelowThresholdSkillCopyWithImpl<$Res>
    implements $BelowThresholdSkillCopyWith<$Res> {
  _$BelowThresholdSkillCopyWithImpl(this._self, this._then);

  final BelowThresholdSkill _self;
  final $Res Function(BelowThresholdSkill) _then;

/// Create a copy of BelowThresholdSkill
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? en = null,Object? ar = null,Object? category = null,Object? postings = null,Object? careers = null,Object? courses = null,}) {
  return _then(BelowThresholdSkill(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as String,ar: null == ar ? _self.ar : ar // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,postings: null == postings ? _self.postings : postings // ignore: cast_nullable_to_non_nullable
as int,careers: null == careers ? _self.careers : careers // ignore: cast_nullable_to_non_nullable
as List<String>,courses: null == courses ? _self.courses : courses // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [BelowThresholdSkill].
extension BelowThresholdSkillPatterns on BelowThresholdSkill {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BelowThresholdSkill value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BelowThresholdSkill() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BelowThresholdSkill value)  $default,){
final _that = this;
switch (_that) {
case _BelowThresholdSkill():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BelowThresholdSkill value)?  $default,){
final _that = this;
switch (_that) {
case _BelowThresholdSkill() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String en,  String ar,  String category,  int postings,  List<String> careers,  List<String> courses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BelowThresholdSkill() when $default != null:
return $default(_that.id,_that.en,_that.ar,_that.category,_that.postings,_that.careers,_that.courses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String en,  String ar,  String category,  int postings,  List<String> careers,  List<String> courses)  $default,) {final _that = this;
switch (_that) {
case _BelowThresholdSkill():
return $default(_that.id,_that.en,_that.ar,_that.category,_that.postings,_that.careers,_that.courses);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String en,  String ar,  String category,  int postings,  List<String> careers,  List<String> courses)?  $default,) {final _that = this;
switch (_that) {
case _BelowThresholdSkill() when $default != null:
return $default(_that.id,_that.en,_that.ar,_that.category,_that.postings,_that.careers,_that.courses);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BelowThresholdSkill extends BelowThresholdSkill {
  const _BelowThresholdSkill({required this.id, required this.en, required this.ar, required this.category, required this.postings, required  List<String> careers, required  List<String> courses}): _careers = careers,_courses = courses,super._();
  factory _BelowThresholdSkill.fromJson(Map<String, dynamic> json) => _$BelowThresholdSkillFromJson(json);

@override final  String id;
@override final  String en;
@override final  String ar;
@override final  String category;
/// Postings in scope that name it, and the careers they belong to.
@override final  int postings;
 final  List<String> _careers;
@override List<String> get careers {
  if (_careers is EqualUnmodifiableListView) return _careers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_careers);
}

/// Catalog courses that teach it; empty when none does.
 final  List<String> _courses;
/// Catalog courses that teach it; empty when none does.
@override List<String> get courses {
  if (_courses is EqualUnmodifiableListView) return _courses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_courses);
}


/// Create a copy of BelowThresholdSkill
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BelowThresholdSkillCopyWith<_BelowThresholdSkill> get copyWith => __$BelowThresholdSkillCopyWithImpl<_BelowThresholdSkill>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BelowThresholdSkillToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BelowThresholdSkill&&(identical(other.id, id) || other.id == id)&&(identical(other.en, en) || other.en == en)&&(identical(other.ar, ar) || other.ar == ar)&&(identical(other.category, category) || other.category == category)&&(identical(other.postings, postings) || other.postings == postings)&&const DeepCollectionEquality().equals(other.careers, _careers)&&const DeepCollectionEquality().equals(other.courses, _courses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,en,ar,category,postings,const DeepCollectionEquality().hash(_careers),const DeepCollectionEquality().hash(_courses));
}

@override
String toString() {
    return 'BelowThresholdSkill(id: $id, en: $en, ar: $ar, category: $category, postings: $postings, careers: $careers, courses: $courses)';
}


}

/// @nodoc
abstract mixin class _$BelowThresholdSkillCopyWith<$Res> implements $BelowThresholdSkillCopyWith<$Res> {
  factory _$BelowThresholdSkillCopyWith(_BelowThresholdSkill value, $Res Function(_BelowThresholdSkill) _then) = __$BelowThresholdSkillCopyWithImpl;
@override @useResult
$Res call({
 String id, String en, String ar, String category, int postings, List<String> careers, List<String> courses
});




}
/// @nodoc
class __$BelowThresholdSkillCopyWithImpl<$Res>
    implements _$BelowThresholdSkillCopyWith<$Res> {
  __$BelowThresholdSkillCopyWithImpl(this._self, this._then);

  final _BelowThresholdSkill _self;
  final $Res Function(_BelowThresholdSkill) _then;

/// Create a copy of BelowThresholdSkill
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? en = null,Object? ar = null,Object? category = null,Object? postings = null,Object? careers = null,Object? courses = null,}) {
  return _then(_BelowThresholdSkill(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as String,ar: null == ar ? _self.ar : ar // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,postings: null == postings ? _self.postings : postings // ignore: cast_nullable_to_non_nullable
as int,careers: null == careers ? _self._careers : careers // ignore: cast_nullable_to_non_nullable
as List<String>,courses: null == courses ? _self._courses : courses // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$CareerCoverage {

 String get career; int get postingCount;/// Skills the career's postings ask for, and how many some course teaches.
 int get demanded; int get taught; double get coverage; int get coveragePercent;/// Postings of this career a skill needs to count as demanded. min_demand
/// is a share, so this grows with the career's posting count.
 int get minPostings;
/// Create a copy of CareerCoverage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CareerCoverageCopyWith<CareerCoverage> get copyWith => _$CareerCoverageCopyWithImpl<CareerCoverage>(this as CareerCoverage, _$identity);

  /// Serializes this CareerCoverage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CareerCoverage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CareerCoverage&&(identical(other.career, _this.career) || other.career == _this.career)&&(identical(other.postingCount, _this.postingCount) || other.postingCount == _this.postingCount)&&(identical(other.demanded, _this.demanded) || other.demanded == _this.demanded)&&(identical(other.taught, _this.taught) || other.taught == _this.taught)&&(identical(other.coverage, _this.coverage) || other.coverage == _this.coverage)&&(identical(other.coveragePercent, _this.coveragePercent) || other.coveragePercent == _this.coveragePercent)&&(identical(other.minPostings, _this.minPostings) || other.minPostings == _this.minPostings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CareerCoverage;
  return Object.hash(runtimeType,_this.career,_this.postingCount,_this.demanded,_this.taught,_this.coverage,_this.coveragePercent,_this.minPostings);
}

@override
String toString() {
  final _this = this as CareerCoverage;
  return 'CareerCoverage(career: ${_this.career}, postingCount: ${_this.postingCount}, demanded: ${_this.demanded}, taught: ${_this.taught}, coverage: ${_this.coverage}, coveragePercent: ${_this.coveragePercent}, minPostings: ${_this.minPostings})';
}


}

/// @nodoc
abstract mixin class $CareerCoverageCopyWith<$Res>  {
  factory $CareerCoverageCopyWith(CareerCoverage value, $Res Function(CareerCoverage) _then) = _$CareerCoverageCopyWithImpl;
@useResult
$Res call({
 String career, int postingCount, int demanded, int taught, double coverage, int coveragePercent, int minPostings
});




}
/// @nodoc
class _$CareerCoverageCopyWithImpl<$Res>
    implements $CareerCoverageCopyWith<$Res> {
  _$CareerCoverageCopyWithImpl(this._self, this._then);

  final CareerCoverage _self;
  final $Res Function(CareerCoverage) _then;

/// Create a copy of CareerCoverage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? career = null,Object? postingCount = null,Object? demanded = null,Object? taught = null,Object? coverage = null,Object? coveragePercent = null,Object? minPostings = null,}) {
  return _then(CareerCoverage(
career: null == career ? _self.career : career // ignore: cast_nullable_to_non_nullable
as String,postingCount: null == postingCount ? _self.postingCount : postingCount // ignore: cast_nullable_to_non_nullable
as int,demanded: null == demanded ? _self.demanded : demanded // ignore: cast_nullable_to_non_nullable
as int,taught: null == taught ? _self.taught : taught // ignore: cast_nullable_to_non_nullable
as int,coverage: null == coverage ? _self.coverage : coverage // ignore: cast_nullable_to_non_nullable
as double,coveragePercent: null == coveragePercent ? _self.coveragePercent : coveragePercent // ignore: cast_nullable_to_non_nullable
as int,minPostings: null == minPostings ? _self.minPostings : minPostings // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CareerCoverage].
extension CareerCoveragePatterns on CareerCoverage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CareerCoverage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CareerCoverage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CareerCoverage value)  $default,){
final _that = this;
switch (_that) {
case _CareerCoverage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CareerCoverage value)?  $default,){
final _that = this;
switch (_that) {
case _CareerCoverage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String career,  int postingCount,  int demanded,  int taught,  double coverage,  int coveragePercent,  int minPostings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CareerCoverage() when $default != null:
return $default(_that.career,_that.postingCount,_that.demanded,_that.taught,_that.coverage,_that.coveragePercent,_that.minPostings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String career,  int postingCount,  int demanded,  int taught,  double coverage,  int coveragePercent,  int minPostings)  $default,) {final _that = this;
switch (_that) {
case _CareerCoverage():
return $default(_that.career,_that.postingCount,_that.demanded,_that.taught,_that.coverage,_that.coveragePercent,_that.minPostings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String career,  int postingCount,  int demanded,  int taught,  double coverage,  int coveragePercent,  int minPostings)?  $default,) {final _that = this;
switch (_that) {
case _CareerCoverage() when $default != null:
return $default(_that.career,_that.postingCount,_that.demanded,_that.taught,_that.coverage,_that.coveragePercent,_that.minPostings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CareerCoverage implements CareerCoverage {
  const _CareerCoverage({required this.career, required this.postingCount, required this.demanded, required this.taught, required this.coverage, required this.coveragePercent, required this.minPostings});
  factory _CareerCoverage.fromJson(Map<String, dynamic> json) => _$CareerCoverageFromJson(json);

@override final  String career;
@override final  int postingCount;
/// Skills the career's postings ask for, and how many some course teaches.
@override final  int demanded;
@override final  int taught;
@override final  double coverage;
@override final  int coveragePercent;
/// Postings of this career a skill needs to count as demanded. min_demand
/// is a share, so this grows with the career's posting count.
@override final  int minPostings;

/// Create a copy of CareerCoverage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CareerCoverageCopyWith<_CareerCoverage> get copyWith => __$CareerCoverageCopyWithImpl<_CareerCoverage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CareerCoverageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CareerCoverage&&(identical(other.career, career) || other.career == career)&&(identical(other.postingCount, postingCount) || other.postingCount == postingCount)&&(identical(other.demanded, demanded) || other.demanded == demanded)&&(identical(other.taught, taught) || other.taught == taught)&&(identical(other.coverage, coverage) || other.coverage == coverage)&&(identical(other.coveragePercent, coveragePercent) || other.coveragePercent == coveragePercent)&&(identical(other.minPostings, minPostings) || other.minPostings == minPostings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,career,postingCount,demanded,taught,coverage,coveragePercent,minPostings);
}

@override
String toString() {
    return 'CareerCoverage(career: $career, postingCount: $postingCount, demanded: $demanded, taught: $taught, coverage: $coverage, coveragePercent: $coveragePercent, minPostings: $minPostings)';
}


}

/// @nodoc
abstract mixin class _$CareerCoverageCopyWith<$Res> implements $CareerCoverageCopyWith<$Res> {
  factory _$CareerCoverageCopyWith(_CareerCoverage value, $Res Function(_CareerCoverage) _then) = __$CareerCoverageCopyWithImpl;
@override @useResult
$Res call({
 String career, int postingCount, int demanded, int taught, double coverage, int coveragePercent, int minPostings
});




}
/// @nodoc
class __$CareerCoverageCopyWithImpl<$Res>
    implements _$CareerCoverageCopyWith<$Res> {
  __$CareerCoverageCopyWithImpl(this._self, this._then);

  final _CareerCoverage _self;
  final $Res Function(_CareerCoverage) _then;

/// Create a copy of CareerCoverage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? career = null,Object? postingCount = null,Object? demanded = null,Object? taught = null,Object? coverage = null,Object? coveragePercent = null,Object? minPostings = null,}) {
  return _then(_CareerCoverage(
career: null == career ? _self.career : career // ignore: cast_nullable_to_non_nullable
as String,postingCount: null == postingCount ? _self.postingCount : postingCount // ignore: cast_nullable_to_non_nullable
as int,demanded: null == demanded ? _self.demanded : demanded // ignore: cast_nullable_to_non_nullable
as int,taught: null == taught ? _self.taught : taught // ignore: cast_nullable_to_non_nullable
as int,coverage: null == coverage ? _self.coverage : coverage // ignore: cast_nullable_to_non_nullable
as double,coveragePercent: null == coveragePercent ? _self.coveragePercent : coveragePercent // ignore: cast_nullable_to_non_nullable
as int,minPostings: null == minPostings ? _self.minPostings : minPostings // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
