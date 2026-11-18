// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invite_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InviteResponse {

/// 없으면 보여 줄 것도 무효화할 것도 없으므로 필수다. 없으면 fromJson 이 던진다.
 String get inviteCode;/// 모르는 기간이면 null.
@JsonKey(fromJson: InviteDuration.fromValue) InviteDuration? get duration;/// 만료 시각. 기간이 `never` 면 null.
@JsonKey(fromJson: _serverTimeOf) DateTime? get expiresAt;/// 만료됐거나 무효화된 코드. 목록에는 이런 코드도 섞여 온다.
 bool get expired;/// 목록을 최신순으로 늘어놓는 데 쓴다.
@JsonKey(fromJson: _serverTimeOf) DateTime? get createdAt;
/// Create a copy of InviteResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InviteResponseCopyWith<InviteResponse> get copyWith => _$InviteResponseCopyWithImpl<InviteResponse>(this as InviteResponse, _$identity);

  /// Serializes this InviteResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InviteResponse&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.expired, expired) || other.expired == expired)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,inviteCode,duration,expiresAt,expired,createdAt);

@override
String toString() {
  return 'InviteResponse(inviteCode: $inviteCode, duration: $duration, expiresAt: $expiresAt, expired: $expired, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $InviteResponseCopyWith<$Res>  {
  factory $InviteResponseCopyWith(InviteResponse value, $Res Function(InviteResponse) _then) = _$InviteResponseCopyWithImpl;
@useResult
$Res call({
 String inviteCode,@JsonKey(fromJson: InviteDuration.fromValue) InviteDuration? duration,@JsonKey(fromJson: _serverTimeOf) DateTime? expiresAt, bool expired,@JsonKey(fromJson: _serverTimeOf) DateTime? createdAt
});




}
/// @nodoc
class _$InviteResponseCopyWithImpl<$Res>
    implements $InviteResponseCopyWith<$Res> {
  _$InviteResponseCopyWithImpl(this._self, this._then);

  final InviteResponse _self;
  final $Res Function(InviteResponse) _then;

/// Create a copy of InviteResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? inviteCode = null,Object? duration = freezed,Object? expiresAt = freezed,Object? expired = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as InviteDuration?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expired: null == expired ? _self.expired : expired // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [InviteResponse].
extension InviteResponsePatterns on InviteResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InviteResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InviteResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InviteResponse value)  $default,){
final _that = this;
switch (_that) {
case _InviteResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InviteResponse value)?  $default,){
final _that = this;
switch (_that) {
case _InviteResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String inviteCode, @JsonKey(fromJson: InviteDuration.fromValue)  InviteDuration? duration, @JsonKey(fromJson: _serverTimeOf)  DateTime? expiresAt,  bool expired, @JsonKey(fromJson: _serverTimeOf)  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InviteResponse() when $default != null:
return $default(_that.inviteCode,_that.duration,_that.expiresAt,_that.expired,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String inviteCode, @JsonKey(fromJson: InviteDuration.fromValue)  InviteDuration? duration, @JsonKey(fromJson: _serverTimeOf)  DateTime? expiresAt,  bool expired, @JsonKey(fromJson: _serverTimeOf)  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _InviteResponse():
return $default(_that.inviteCode,_that.duration,_that.expiresAt,_that.expired,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String inviteCode, @JsonKey(fromJson: InviteDuration.fromValue)  InviteDuration? duration, @JsonKey(fromJson: _serverTimeOf)  DateTime? expiresAt,  bool expired, @JsonKey(fromJson: _serverTimeOf)  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _InviteResponse() when $default != null:
return $default(_that.inviteCode,_that.duration,_that.expiresAt,_that.expired,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InviteResponse implements InviteResponse {
  const _InviteResponse({required this.inviteCode, @JsonKey(fromJson: InviteDuration.fromValue) this.duration, @JsonKey(fromJson: _serverTimeOf) this.expiresAt, this.expired = false, @JsonKey(fromJson: _serverTimeOf) this.createdAt});
  factory _InviteResponse.fromJson(Map<String, dynamic> json) => _$InviteResponseFromJson(json);

/// 없으면 보여 줄 것도 무효화할 것도 없으므로 필수다. 없으면 fromJson 이 던진다.
@override final  String inviteCode;
/// 모르는 기간이면 null.
@override@JsonKey(fromJson: InviteDuration.fromValue) final  InviteDuration? duration;
/// 만료 시각. 기간이 `never` 면 null.
@override@JsonKey(fromJson: _serverTimeOf) final  DateTime? expiresAt;
/// 만료됐거나 무효화된 코드. 목록에는 이런 코드도 섞여 온다.
@override@JsonKey() final  bool expired;
/// 목록을 최신순으로 늘어놓는 데 쓴다.
@override@JsonKey(fromJson: _serverTimeOf) final  DateTime? createdAt;

/// Create a copy of InviteResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InviteResponseCopyWith<_InviteResponse> get copyWith => __$InviteResponseCopyWithImpl<_InviteResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InviteResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InviteResponse&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.expired, expired) || other.expired == expired)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,inviteCode,duration,expiresAt,expired,createdAt);

@override
String toString() {
  return 'InviteResponse(inviteCode: $inviteCode, duration: $duration, expiresAt: $expiresAt, expired: $expired, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$InviteResponseCopyWith<$Res> implements $InviteResponseCopyWith<$Res> {
  factory _$InviteResponseCopyWith(_InviteResponse value, $Res Function(_InviteResponse) _then) = __$InviteResponseCopyWithImpl;
@override @useResult
$Res call({
 String inviteCode,@JsonKey(fromJson: InviteDuration.fromValue) InviteDuration? duration,@JsonKey(fromJson: _serverTimeOf) DateTime? expiresAt, bool expired,@JsonKey(fromJson: _serverTimeOf) DateTime? createdAt
});




}
/// @nodoc
class __$InviteResponseCopyWithImpl<$Res>
    implements _$InviteResponseCopyWith<$Res> {
  __$InviteResponseCopyWithImpl(this._self, this._then);

  final _InviteResponse _self;
  final $Res Function(_InviteResponse) _then;

/// Create a copy of InviteResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? inviteCode = null,Object? duration = freezed,Object? expiresAt = freezed,Object? expired = null,Object? createdAt = freezed,}) {
  return _then(_InviteResponse(
inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as InviteDuration?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expired: null == expired ? _self.expired : expired // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
