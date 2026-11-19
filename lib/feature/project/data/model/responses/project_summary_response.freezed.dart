// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_summary_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProjectSummaryResponse {

/// 채널의 `projectId` 와 맞춰 묶으므로 필수다. 없으면 fromJson 이 던진다.
 int get id; String get name;
/// Create a copy of ProjectSummaryResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectSummaryResponseCopyWith<ProjectSummaryResponse> get copyWith => _$ProjectSummaryResponseCopyWithImpl<ProjectSummaryResponse>(this as ProjectSummaryResponse, _$identity);

  /// Serializes this ProjectSummaryResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectSummaryResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'ProjectSummaryResponse(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $ProjectSummaryResponseCopyWith<$Res>  {
  factory $ProjectSummaryResponseCopyWith(ProjectSummaryResponse value, $Res Function(ProjectSummaryResponse) _then) = _$ProjectSummaryResponseCopyWithImpl;
@useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class _$ProjectSummaryResponseCopyWithImpl<$Res>
    implements $ProjectSummaryResponseCopyWith<$Res> {
  _$ProjectSummaryResponseCopyWithImpl(this._self, this._then);

  final ProjectSummaryResponse _self;
  final $Res Function(ProjectSummaryResponse) _then;

/// Create a copy of ProjectSummaryResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectSummaryResponse].
extension ProjectSummaryResponsePatterns on ProjectSummaryResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectSummaryResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectSummaryResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectSummaryResponse value)  $default,){
final _that = this;
switch (_that) {
case _ProjectSummaryResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectSummaryResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectSummaryResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectSummaryResponse() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name)  $default,) {final _that = this;
switch (_that) {
case _ProjectSummaryResponse():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _ProjectSummaryResponse() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectSummaryResponse implements ProjectSummaryResponse {
  const _ProjectSummaryResponse({required this.id, this.name = ''});
  factory _ProjectSummaryResponse.fromJson(Map<String, dynamic> json) => _$ProjectSummaryResponseFromJson(json);

/// 채널의 `projectId` 와 맞춰 묶으므로 필수다. 없으면 fromJson 이 던진다.
@override final  int id;
@override@JsonKey() final  String name;

/// Create a copy of ProjectSummaryResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectSummaryResponseCopyWith<_ProjectSummaryResponse> get copyWith => __$ProjectSummaryResponseCopyWithImpl<_ProjectSummaryResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectSummaryResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectSummaryResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'ProjectSummaryResponse(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$ProjectSummaryResponseCopyWith<$Res> implements $ProjectSummaryResponseCopyWith<$Res> {
  factory _$ProjectSummaryResponseCopyWith(_ProjectSummaryResponse value, $Res Function(_ProjectSummaryResponse) _then) = __$ProjectSummaryResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class __$ProjectSummaryResponseCopyWithImpl<$Res>
    implements _$ProjectSummaryResponseCopyWith<$Res> {
  __$ProjectSummaryResponseCopyWithImpl(this._self, this._then);

  final _ProjectSummaryResponse _self;
  final $Res Function(_ProjectSummaryResponse) _then;

/// Create a copy of ProjectSummaryResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_ProjectSummaryResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
