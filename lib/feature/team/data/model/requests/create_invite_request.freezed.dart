// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_invite_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreateInviteRequest {

/// 서버에는 `1d` / `7d` / `30d` / `never` 문자열로 보낸다.
@JsonKey(toJson: _durationValueOf) InviteDuration get duration;
/// Create a copy of CreateInviteRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateInviteRequestCopyWith<CreateInviteRequest> get copyWith => _$CreateInviteRequestCopyWithImpl<CreateInviteRequest>(this as CreateInviteRequest, _$identity);

  /// Serializes this CreateInviteRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateInviteRequest&&(identical(other.duration, duration) || other.duration == duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,duration);

@override
String toString() {
  return 'CreateInviteRequest(duration: $duration)';
}


}

/// @nodoc
abstract mixin class $CreateInviteRequestCopyWith<$Res>  {
  factory $CreateInviteRequestCopyWith(CreateInviteRequest value, $Res Function(CreateInviteRequest) _then) = _$CreateInviteRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _durationValueOf) InviteDuration duration
});




}
/// @nodoc
class _$CreateInviteRequestCopyWithImpl<$Res>
    implements $CreateInviteRequestCopyWith<$Res> {
  _$CreateInviteRequestCopyWithImpl(this._self, this._then);

  final CreateInviteRequest _self;
  final $Res Function(CreateInviteRequest) _then;

/// Create a copy of CreateInviteRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? duration = null,}) {
  return _then(_self.copyWith(
duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as InviteDuration,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateInviteRequest].
extension CreateInviteRequestPatterns on CreateInviteRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateInviteRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateInviteRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateInviteRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateInviteRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateInviteRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateInviteRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(toJson: _durationValueOf)  InviteDuration duration)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateInviteRequest() when $default != null:
return $default(_that.duration);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(toJson: _durationValueOf)  InviteDuration duration)  $default,) {final _that = this;
switch (_that) {
case _CreateInviteRequest():
return $default(_that.duration);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(toJson: _durationValueOf)  InviteDuration duration)?  $default,) {final _that = this;
switch (_that) {
case _CreateInviteRequest() when $default != null:
return $default(_that.duration);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createFactory: false)

class _CreateInviteRequest implements CreateInviteRequest {
  const _CreateInviteRequest({@JsonKey(toJson: _durationValueOf) required this.duration});
  

/// 서버에는 `1d` / `7d` / `30d` / `never` 문자열로 보낸다.
@override@JsonKey(toJson: _durationValueOf) final  InviteDuration duration;

/// Create a copy of CreateInviteRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateInviteRequestCopyWith<_CreateInviteRequest> get copyWith => __$CreateInviteRequestCopyWithImpl<_CreateInviteRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateInviteRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateInviteRequest&&(identical(other.duration, duration) || other.duration == duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,duration);

@override
String toString() {
  return 'CreateInviteRequest(duration: $duration)';
}


}

/// @nodoc
abstract mixin class _$CreateInviteRequestCopyWith<$Res> implements $CreateInviteRequestCopyWith<$Res> {
  factory _$CreateInviteRequestCopyWith(_CreateInviteRequest value, $Res Function(_CreateInviteRequest) _then) = __$CreateInviteRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(toJson: _durationValueOf) InviteDuration duration
});




}
/// @nodoc
class __$CreateInviteRequestCopyWithImpl<$Res>
    implements _$CreateInviteRequestCopyWith<$Res> {
  __$CreateInviteRequestCopyWithImpl(this._self, this._then);

  final _CreateInviteRequest _self;
  final $Res Function(_CreateInviteRequest) _then;

/// Create a copy of CreateInviteRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? duration = null,}) {
  return _then(_CreateInviteRequest(
duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as InviteDuration,
  ));
}


}

// dart format on
