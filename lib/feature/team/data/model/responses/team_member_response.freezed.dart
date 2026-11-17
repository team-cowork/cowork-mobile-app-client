// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_member_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TeamMemberResponse {

/// 없으면 fromJson 이 던진다.
 int get userId;
/// Create a copy of TeamMemberResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamMemberResponseCopyWith<TeamMemberResponse> get copyWith => _$TeamMemberResponseCopyWithImpl<TeamMemberResponse>(this as TeamMemberResponse, _$identity);

  /// Serializes this TeamMemberResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamMemberResponse&&(identical(other.userId, userId) || other.userId == userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId);

@override
String toString() {
  return 'TeamMemberResponse(userId: $userId)';
}


}

/// @nodoc
abstract mixin class $TeamMemberResponseCopyWith<$Res>  {
  factory $TeamMemberResponseCopyWith(TeamMemberResponse value, $Res Function(TeamMemberResponse) _then) = _$TeamMemberResponseCopyWithImpl;
@useResult
$Res call({
 int userId
});




}
/// @nodoc
class _$TeamMemberResponseCopyWithImpl<$Res>
    implements $TeamMemberResponseCopyWith<$Res> {
  _$TeamMemberResponseCopyWithImpl(this._self, this._then);

  final TeamMemberResponse _self;
  final $Res Function(TeamMemberResponse) _then;

/// Create a copy of TeamMemberResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamMemberResponse].
extension TeamMemberResponsePatterns on TeamMemberResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamMemberResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamMemberResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamMemberResponse value)  $default,){
final _that = this;
switch (_that) {
case _TeamMemberResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamMemberResponse value)?  $default,){
final _that = this;
switch (_that) {
case _TeamMemberResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int userId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamMemberResponse() when $default != null:
return $default(_that.userId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int userId)  $default,) {final _that = this;
switch (_that) {
case _TeamMemberResponse():
return $default(_that.userId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int userId)?  $default,) {final _that = this;
switch (_that) {
case _TeamMemberResponse() when $default != null:
return $default(_that.userId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamMemberResponse implements TeamMemberResponse {
  const _TeamMemberResponse({required this.userId});
  factory _TeamMemberResponse.fromJson(Map<String, dynamic> json) => _$TeamMemberResponseFromJson(json);

/// 없으면 fromJson 이 던진다.
@override final  int userId;

/// Create a copy of TeamMemberResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamMemberResponseCopyWith<_TeamMemberResponse> get copyWith => __$TeamMemberResponseCopyWithImpl<_TeamMemberResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamMemberResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamMemberResponse&&(identical(other.userId, userId) || other.userId == userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId);

@override
String toString() {
  return 'TeamMemberResponse(userId: $userId)';
}


}

/// @nodoc
abstract mixin class _$TeamMemberResponseCopyWith<$Res> implements $TeamMemberResponseCopyWith<$Res> {
  factory _$TeamMemberResponseCopyWith(_TeamMemberResponse value, $Res Function(_TeamMemberResponse) _then) = __$TeamMemberResponseCopyWithImpl;
@override @useResult
$Res call({
 int userId
});




}
/// @nodoc
class __$TeamMemberResponseCopyWithImpl<$Res>
    implements _$TeamMemberResponseCopyWith<$Res> {
  __$TeamMemberResponseCopyWithImpl(this._self, this._then);

  final _TeamMemberResponse _self;
  final $Res Function(_TeamMemberResponse) _then;

/// Create a copy of TeamMemberResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,}) {
  return _then(_TeamMemberResponse(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
