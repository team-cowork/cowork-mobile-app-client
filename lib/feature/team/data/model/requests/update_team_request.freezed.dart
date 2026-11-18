// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_team_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdateTeamRequest {

 String? get name; String? get description;
/// Create a copy of UpdateTeamRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateTeamRequestCopyWith<UpdateTeamRequest> get copyWith => _$UpdateTeamRequestCopyWithImpl<UpdateTeamRequest>(this as UpdateTeamRequest, _$identity);

  /// Serializes this UpdateTeamRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateTeamRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description);

@override
String toString() {
  return 'UpdateTeamRequest(name: $name, description: $description)';
}


}

/// @nodoc
abstract mixin class $UpdateTeamRequestCopyWith<$Res>  {
  factory $UpdateTeamRequestCopyWith(UpdateTeamRequest value, $Res Function(UpdateTeamRequest) _then) = _$UpdateTeamRequestCopyWithImpl;
@useResult
$Res call({
 String? name, String? description
});




}
/// @nodoc
class _$UpdateTeamRequestCopyWithImpl<$Res>
    implements $UpdateTeamRequestCopyWith<$Res> {
  _$UpdateTeamRequestCopyWithImpl(this._self, this._then);

  final UpdateTeamRequest _self;
  final $Res Function(UpdateTeamRequest) _then;

/// Create a copy of UpdateTeamRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? description = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateTeamRequest].
extension UpdateTeamRequestPatterns on UpdateTeamRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateTeamRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateTeamRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateTeamRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateTeamRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateTeamRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateTeamRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateTeamRequest() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? description)  $default,) {final _that = this;
switch (_that) {
case _UpdateTeamRequest():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _UpdateTeamRequest() when $default != null:
return $default(_that.name,_that.description);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false, createFactory: false)
class _UpdateTeamRequest implements UpdateTeamRequest {
  const _UpdateTeamRequest({this.name, this.description});
  

@override final  String? name;
@override final  String? description;

/// Create a copy of UpdateTeamRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateTeamRequestCopyWith<_UpdateTeamRequest> get copyWith => __$UpdateTeamRequestCopyWithImpl<_UpdateTeamRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateTeamRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateTeamRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description);

@override
String toString() {
  return 'UpdateTeamRequest(name: $name, description: $description)';
}


}

/// @nodoc
abstract mixin class _$UpdateTeamRequestCopyWith<$Res> implements $UpdateTeamRequestCopyWith<$Res> {
  factory _$UpdateTeamRequestCopyWith(_UpdateTeamRequest value, $Res Function(_UpdateTeamRequest) _then) = __$UpdateTeamRequestCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? description
});




}
/// @nodoc
class __$UpdateTeamRequestCopyWithImpl<$Res>
    implements _$UpdateTeamRequestCopyWith<$Res> {
  __$UpdateTeamRequestCopyWithImpl(this._self, this._then);

  final _UpdateTeamRequest _self;
  final $Res Function(_UpdateTeamRequest) _then;

/// Create a copy of UpdateTeamRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? description = freezed,}) {
  return _then(_UpdateTeamRequest(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
