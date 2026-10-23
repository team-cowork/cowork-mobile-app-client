// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_team_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreateTeamRequest {

 String get name;/// 팀 소개. 없으면 보내지 않는다.
 String? get description;
/// Create a copy of CreateTeamRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateTeamRequestCopyWith<CreateTeamRequest> get copyWith => _$CreateTeamRequestCopyWithImpl<CreateTeamRequest>(this as CreateTeamRequest, _$identity);

  /// Serializes this CreateTeamRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateTeamRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description);

@override
String toString() {
  return 'CreateTeamRequest(name: $name, description: $description)';
}


}

/// @nodoc
abstract mixin class $CreateTeamRequestCopyWith<$Res>  {
  factory $CreateTeamRequestCopyWith(CreateTeamRequest value, $Res Function(CreateTeamRequest) _then) = _$CreateTeamRequestCopyWithImpl;
@useResult
$Res call({
 String name, String? description
});




}
/// @nodoc
class _$CreateTeamRequestCopyWithImpl<$Res>
    implements $CreateTeamRequestCopyWith<$Res> {
  _$CreateTeamRequestCopyWithImpl(this._self, this._then);

  final CreateTeamRequest _self;
  final $Res Function(CreateTeamRequest) _then;

/// Create a copy of CreateTeamRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateTeamRequest].
extension CreateTeamRequestPatterns on CreateTeamRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateTeamRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateTeamRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateTeamRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateTeamRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateTeamRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateTeamRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateTeamRequest() when $default != null:
return $default(_that.name,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? description)  $default,) {final _that = this;
switch (_that) {
case _CreateTeamRequest():
return $default(_that.name,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _CreateTeamRequest() when $default != null:
return $default(_that.name,_that.description);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false, createFactory: false)
class _CreateTeamRequest implements CreateTeamRequest {
  const _CreateTeamRequest({required this.name, this.description});
  

@override final  String name;
/// 팀 소개. 없으면 보내지 않는다.
@override final  String? description;

/// Create a copy of CreateTeamRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateTeamRequestCopyWith<_CreateTeamRequest> get copyWith => __$CreateTeamRequestCopyWithImpl<_CreateTeamRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateTeamRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateTeamRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description);

@override
String toString() {
  return 'CreateTeamRequest(name: $name, description: $description)';
}


}

/// @nodoc
abstract mixin class _$CreateTeamRequestCopyWith<$Res> implements $CreateTeamRequestCopyWith<$Res> {
  factory _$CreateTeamRequestCopyWith(_CreateTeamRequest value, $Res Function(_CreateTeamRequest) _then) = __$CreateTeamRequestCopyWithImpl;
@override @useResult
$Res call({
 String name, String? description
});




}
/// @nodoc
class __$CreateTeamRequestCopyWithImpl<$Res>
    implements _$CreateTeamRequestCopyWith<$Res> {
  __$CreateTeamRequestCopyWithImpl(this._self, this._then);

  final _CreateTeamRequest _self;
  final $Res Function(_CreateTeamRequest) _then;

/// Create a copy of CreateTeamRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = freezed,}) {
  return _then(_CreateTeamRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
