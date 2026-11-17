// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'channel_member_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChannelMemberResponse {

/// 없으면 fromJson 이 던진다.
 int get userId;
/// Create a copy of ChannelMemberResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelMemberResponseCopyWith<ChannelMemberResponse> get copyWith => _$ChannelMemberResponseCopyWithImpl<ChannelMemberResponse>(this as ChannelMemberResponse, _$identity);

  /// Serializes this ChannelMemberResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelMemberResponse&&(identical(other.userId, userId) || other.userId == userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId);

@override
String toString() {
  return 'ChannelMemberResponse(userId: $userId)';
}


}

/// @nodoc
abstract mixin class $ChannelMemberResponseCopyWith<$Res>  {
  factory $ChannelMemberResponseCopyWith(ChannelMemberResponse value, $Res Function(ChannelMemberResponse) _then) = _$ChannelMemberResponseCopyWithImpl;
@useResult
$Res call({
 int userId
});




}
/// @nodoc
class _$ChannelMemberResponseCopyWithImpl<$Res>
    implements $ChannelMemberResponseCopyWith<$Res> {
  _$ChannelMemberResponseCopyWithImpl(this._self, this._then);

  final ChannelMemberResponse _self;
  final $Res Function(ChannelMemberResponse) _then;

/// Create a copy of ChannelMemberResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChannelMemberResponse].
extension ChannelMemberResponsePatterns on ChannelMemberResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChannelMemberResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChannelMemberResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChannelMemberResponse value)  $default,){
final _that = this;
switch (_that) {
case _ChannelMemberResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChannelMemberResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ChannelMemberResponse() when $default != null:
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
case _ChannelMemberResponse() when $default != null:
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
case _ChannelMemberResponse():
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
case _ChannelMemberResponse() when $default != null:
return $default(_that.userId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChannelMemberResponse implements ChannelMemberResponse {
  const _ChannelMemberResponse({required this.userId});
  factory _ChannelMemberResponse.fromJson(Map<String, dynamic> json) => _$ChannelMemberResponseFromJson(json);

/// 없으면 fromJson 이 던진다.
@override final  int userId;

/// Create a copy of ChannelMemberResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChannelMemberResponseCopyWith<_ChannelMemberResponse> get copyWith => __$ChannelMemberResponseCopyWithImpl<_ChannelMemberResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChannelMemberResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChannelMemberResponse&&(identical(other.userId, userId) || other.userId == userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId);

@override
String toString() {
  return 'ChannelMemberResponse(userId: $userId)';
}


}

/// @nodoc
abstract mixin class _$ChannelMemberResponseCopyWith<$Res> implements $ChannelMemberResponseCopyWith<$Res> {
  factory _$ChannelMemberResponseCopyWith(_ChannelMemberResponse value, $Res Function(_ChannelMemberResponse) _then) = __$ChannelMemberResponseCopyWithImpl;
@override @useResult
$Res call({
 int userId
});




}
/// @nodoc
class __$ChannelMemberResponseCopyWithImpl<$Res>
    implements _$ChannelMemberResponseCopyWith<$Res> {
  __$ChannelMemberResponseCopyWithImpl(this._self, this._then);

  final _ChannelMemberResponse _self;
  final $Res Function(_ChannelMemberResponse) _then;

/// Create a copy of ChannelMemberResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,}) {
  return _then(_ChannelMemberResponse(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
