// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'skill_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SkillEntry {

 String get id; String get en; String get ar; String get category;/// Share of this career's postings that ask for the skill, 0 to 1.
 double get demand; int get demandPercent;/// For a skill the student has: "courses" or "self_reported". A skill a
/// completed course teaches is "courses" even if also self-reported.
/// Absent for a missing skill.
 String? get source;
/// Create a copy of SkillEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SkillEntryCopyWith<SkillEntry> get copyWith => _$SkillEntryCopyWithImpl<SkillEntry>(this as SkillEntry, _$identity);

  /// Serializes this SkillEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SkillEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SkillEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.en, _this.en) || other.en == _this.en)&&(identical(other.ar, _this.ar) || other.ar == _this.ar)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.demand, _this.demand) || other.demand == _this.demand)&&(identical(other.demandPercent, _this.demandPercent) || other.demandPercent == _this.demandPercent)&&(identical(other.source, _this.source) || other.source == _this.source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SkillEntry;
  return Object.hash(runtimeType,_this.id,_this.en,_this.ar,_this.category,_this.demand,_this.demandPercent,_this.source);
}

@override
String toString() {
  final _this = this as SkillEntry;
  return 'SkillEntry(id: ${_this.id}, en: ${_this.en}, ar: ${_this.ar}, category: ${_this.category}, demand: ${_this.demand}, demandPercent: ${_this.demandPercent}, source: ${_this.source})';
}


}

/// @nodoc
abstract mixin class $SkillEntryCopyWith<$Res>  {
  factory $SkillEntryCopyWith(SkillEntry value, $Res Function(SkillEntry) _then) = _$SkillEntryCopyWithImpl;
@useResult
$Res call({
 String id, String en, String ar, String category, double demand, int demandPercent, String? source
});




}
/// @nodoc
class _$SkillEntryCopyWithImpl<$Res>
    implements $SkillEntryCopyWith<$Res> {
  _$SkillEntryCopyWithImpl(this._self, this._then);

  final SkillEntry _self;
  final $Res Function(SkillEntry) _then;

/// Create a copy of SkillEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? en = null,Object? ar = null,Object? category = null,Object? demand = null,Object? demandPercent = null,Object? source = freezed,}) {
  return _then(SkillEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as String,ar: null == ar ? _self.ar : ar // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,demand: null == demand ? _self.demand : demand // ignore: cast_nullable_to_non_nullable
as double,demandPercent: null == demandPercent ? _self.demandPercent : demandPercent // ignore: cast_nullable_to_non_nullable
as int,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SkillEntry].
extension SkillEntryPatterns on SkillEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SkillEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SkillEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SkillEntry value)  $default,){
final _that = this;
switch (_that) {
case _SkillEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SkillEntry value)?  $default,){
final _that = this;
switch (_that) {
case _SkillEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String en,  String ar,  String category,  double demand,  int demandPercent,  String? source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SkillEntry() when $default != null:
return $default(_that.id,_that.en,_that.ar,_that.category,_that.demand,_that.demandPercent,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String en,  String ar,  String category,  double demand,  int demandPercent,  String? source)  $default,) {final _that = this;
switch (_that) {
case _SkillEntry():
return $default(_that.id,_that.en,_that.ar,_that.category,_that.demand,_that.demandPercent,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String en,  String ar,  String category,  double demand,  int demandPercent,  String? source)?  $default,) {final _that = this;
switch (_that) {
case _SkillEntry() when $default != null:
return $default(_that.id,_that.en,_that.ar,_that.category,_that.demand,_that.demandPercent,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SkillEntry extends SkillEntry {
  const _SkillEntry({required this.id, required this.en, required this.ar, required this.category, required this.demand, required this.demandPercent, this.source}): super._();
  factory _SkillEntry.fromJson(Map<String, dynamic> json) => _$SkillEntryFromJson(json);

@override final  String id;
@override final  String en;
@override final  String ar;
@override final  String category;
/// Share of this career's postings that ask for the skill, 0 to 1.
@override final  double demand;
@override final  int demandPercent;
/// For a skill the student has: "courses" or "self_reported". A skill a
/// completed course teaches is "courses" even if also self-reported.
/// Absent for a missing skill.
@override final  String? source;

/// Create a copy of SkillEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SkillEntryCopyWith<_SkillEntry> get copyWith => __$SkillEntryCopyWithImpl<_SkillEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SkillEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SkillEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.en, en) || other.en == en)&&(identical(other.ar, ar) || other.ar == ar)&&(identical(other.category, category) || other.category == category)&&(identical(other.demand, demand) || other.demand == demand)&&(identical(other.demandPercent, demandPercent) || other.demandPercent == demandPercent)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,en,ar,category,demand,demandPercent,source);
}

@override
String toString() {
    return 'SkillEntry(id: $id, en: $en, ar: $ar, category: $category, demand: $demand, demandPercent: $demandPercent, source: $source)';
}


}

/// @nodoc
abstract mixin class _$SkillEntryCopyWith<$Res> implements $SkillEntryCopyWith<$Res> {
  factory _$SkillEntryCopyWith(_SkillEntry value, $Res Function(_SkillEntry) _then) = __$SkillEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String en, String ar, String category, double demand, int demandPercent, String? source
});




}
/// @nodoc
class __$SkillEntryCopyWithImpl<$Res>
    implements _$SkillEntryCopyWith<$Res> {
  __$SkillEntryCopyWithImpl(this._self, this._then);

  final _SkillEntry _self;
  final $Res Function(_SkillEntry) _then;

/// Create a copy of SkillEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? en = null,Object? ar = null,Object? category = null,Object? demand = null,Object? demandPercent = null,Object? source = freezed,}) {
  return _then(_SkillEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as String,ar: null == ar ? _self.ar : ar // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,demand: null == demand ? _self.demand : demand // ignore: cast_nullable_to_non_nullable
as double,demandPercent: null == demandPercent ? _self.demandPercent : demandPercent // ignore: cast_nullable_to_non_nullable
as int,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
