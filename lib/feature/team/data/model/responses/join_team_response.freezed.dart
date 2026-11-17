// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'join_team_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$JoinTeamResponse {

/// 가입 뒤 옮겨 갈 팀. 없으면 fromJson 이 던진다.
 int get teamId;
/// Create a copy of JoinTeamResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JoinTeamResponseCopyWith<JoinTeamResponse> get copyWith => _$JoinTeamResponseCopyWithImpl<JoinTeamResponse>(this as JoinTeamResponse, _$identity);

  /// Serializes this JoinTeamResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JoinTeamResponse&&(identical(other.teamId, teamId) || other.teamId == teamId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamId);

@override
String toString() {
  return 'JoinTeamResponse(teamId: $teamId)';
}


}

/// @nodoc
abstract mixin class $JoinTeamResponseCopyWith<$Res>  {
  factory $JoinTeamResponseCopyWith(JoinTeamResponse value, $Res Function(JoinTeamResponse) _then) = _$JoinTeamResponseCopyWithImpl;
@useResult
$Res call({
 int teamId
});




}
/// @nodoc
class _$JoinTeamResponseCopyWithImpl<$Res>
    implements $JoinTeamResponseCopyWith<$Res> {
  _$JoinTeamResponseCopyWithImpl(this._self, this._then);

  final JoinTeamResponse _self;
  final $Res Function(JoinTeamResponse) _then;

/// Create a copy of JoinTeamResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? teamId = null,}) {
  return _then(_self.copyWith(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [JoinTeamResponse].
extension JoinTeamResponsePatterns on JoinTeamResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JoinTeamResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JoinTeamResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JoinTeamResponse value)  $default,){
final _that = this;
switch (_that) {
case _JoinTeamResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JoinTeamResponse value)?  $default,){
final _that = this;
switch (_that) {
case _JoinTeamResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int teamId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JoinTeamResponse() when $default != null:
return $default(_that.teamId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int teamId)  $default,) {final _that = this;
switch (_that) {
case _JoinTeamResponse():
return $default(_that.teamId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int teamId)?  $default,) {final _that = this;
switch (_that) {
case _JoinTeamResponse() when $default != null:
return $default(_that.teamId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JoinTeamResponse implements JoinTeamResponse {
  const _JoinTeamResponse({required this.teamId});
  factory _JoinTeamResponse.fromJson(Map<String, dynamic> json) => _$JoinTeamResponseFromJson(json);

/// 가입 뒤 옮겨 갈 팀. 없으면 fromJson 이 던진다.
@override final  int teamId;

/// Create a copy of JoinTeamResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JoinTeamResponseCopyWith<_JoinTeamResponse> get copyWith => __$JoinTeamResponseCopyWithImpl<_JoinTeamResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JoinTeamResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JoinTeamResponse&&(identical(other.teamId, teamId) || other.teamId == teamId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamId);

@override
String toString() {
  return 'JoinTeamResponse(teamId: $teamId)';
}


}

/// @nodoc
abstract mixin class _$JoinTeamResponseCopyWith<$Res> implements $JoinTeamResponseCopyWith<$Res> {
  factory _$JoinTeamResponseCopyWith(_JoinTeamResponse value, $Res Function(_JoinTeamResponse) _then) = __$JoinTeamResponseCopyWithImpl;
@override @useResult
$Res call({
 int teamId
});




}
/// @nodoc
class __$JoinTeamResponseCopyWithImpl<$Res>
    implements _$JoinTeamResponseCopyWith<$Res> {
  __$JoinTeamResponseCopyWithImpl(this._self, this._then);

  final _JoinTeamResponse _self;
  final $Res Function(_JoinTeamResponse) _then;

/// Create a copy of JoinTeamResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? teamId = null,}) {
  return _then(_JoinTeamResponse(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
