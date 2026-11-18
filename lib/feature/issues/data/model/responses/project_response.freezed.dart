// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProjectResponse {

 int get id; String get name;
/// Create a copy of ProjectResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectResponseCopyWith<ProjectResponse> get copyWith => _$ProjectResponseCopyWithImpl<ProjectResponse>(this as ProjectResponse, _$identity);

  /// Serializes this ProjectResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'ProjectResponse(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $ProjectResponseCopyWith<$Res>  {
  factory $ProjectResponseCopyWith(ProjectResponse value, $Res Function(ProjectResponse) _then) = _$ProjectResponseCopyWithImpl;
@useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class _$ProjectResponseCopyWithImpl<$Res>
    implements $ProjectResponseCopyWith<$Res> {
  _$ProjectResponseCopyWithImpl(this._self, this._then);

  final ProjectResponse _self;
  final $Res Function(ProjectResponse) _then;

/// Create a copy of ProjectResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectResponse].
extension ProjectResponsePatterns on ProjectResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectResponse value)  $default,){
final _that = this;
switch (_that) {
case _ProjectResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectResponse() when $default != null:
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
case _ProjectResponse() when $default != null:
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
case _ProjectResponse():
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
case _ProjectResponse() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectResponse implements ProjectResponse {
  const _ProjectResponse({required this.id, this.name = ''});
  factory _ProjectResponse.fromJson(Map<String, dynamic> json) => _$ProjectResponseFromJson(json);

@override final  int id;
@override@JsonKey() final  String name;

/// Create a copy of ProjectResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectResponseCopyWith<_ProjectResponse> get copyWith => __$ProjectResponseCopyWithImpl<_ProjectResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'ProjectResponse(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$ProjectResponseCopyWith<$Res> implements $ProjectResponseCopyWith<$Res> {
  factory _$ProjectResponseCopyWith(_ProjectResponse value, $Res Function(_ProjectResponse) _then) = __$ProjectResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class __$ProjectResponseCopyWithImpl<$Res>
    implements _$ProjectResponseCopyWith<$Res> {
  __$ProjectResponseCopyWithImpl(this._self, this._then);

  final _ProjectResponse _self;
  final $Res Function(_ProjectResponse) _then;

/// Create a copy of ProjectResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_ProjectResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
