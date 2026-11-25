// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'channel_unread_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChannelUnreadResponse {

 int get channelId; int get unreadCount;
/// Create a copy of ChannelUnreadResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelUnreadResponseCopyWith<ChannelUnreadResponse> get copyWith => _$ChannelUnreadResponseCopyWithImpl<ChannelUnreadResponse>(this as ChannelUnreadResponse, _$identity);

  /// Serializes this ChannelUnreadResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelUnreadResponse&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,unreadCount);

@override
String toString() {
  return 'ChannelUnreadResponse(channelId: $channelId, unreadCount: $unreadCount)';
}


}

/// @nodoc
abstract mixin class $ChannelUnreadResponseCopyWith<$Res>  {
  factory $ChannelUnreadResponseCopyWith(ChannelUnreadResponse value, $Res Function(ChannelUnreadResponse) _then) = _$ChannelUnreadResponseCopyWithImpl;
@useResult
$Res call({
 int channelId, int unreadCount
});




}
/// @nodoc
class _$ChannelUnreadResponseCopyWithImpl<$Res>
    implements $ChannelUnreadResponseCopyWith<$Res> {
  _$ChannelUnreadResponseCopyWithImpl(this._self, this._then);

  final ChannelUnreadResponse _self;
  final $Res Function(ChannelUnreadResponse) _then;

/// Create a copy of ChannelUnreadResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? channelId = null,Object? unreadCount = null,}) {
  return _then(_self.copyWith(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as int,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChannelUnreadResponse].
extension ChannelUnreadResponsePatterns on ChannelUnreadResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChannelUnreadResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChannelUnreadResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChannelUnreadResponse value)  $default,){
final _that = this;
switch (_that) {
case _ChannelUnreadResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChannelUnreadResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ChannelUnreadResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int channelId,  int unreadCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChannelUnreadResponse() when $default != null:
return $default(_that.channelId,_that.unreadCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int channelId,  int unreadCount)  $default,) {final _that = this;
switch (_that) {
case _ChannelUnreadResponse():
return $default(_that.channelId,_that.unreadCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int channelId,  int unreadCount)?  $default,) {final _that = this;
switch (_that) {
case _ChannelUnreadResponse() when $default != null:
return $default(_that.channelId,_that.unreadCount);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _ChannelUnreadResponse implements ChannelUnreadResponse {
  const _ChannelUnreadResponse({required this.channelId, required this.unreadCount});
  factory _ChannelUnreadResponse.fromJson(Map<String, dynamic> json) => _$ChannelUnreadResponseFromJson(json);

@override final  int channelId;
@override final  int unreadCount;

/// Create a copy of ChannelUnreadResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChannelUnreadResponseCopyWith<_ChannelUnreadResponse> get copyWith => __$ChannelUnreadResponseCopyWithImpl<_ChannelUnreadResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChannelUnreadResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChannelUnreadResponse&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,unreadCount);

@override
String toString() {
  return 'ChannelUnreadResponse(channelId: $channelId, unreadCount: $unreadCount)';
}


}

/// @nodoc
abstract mixin class _$ChannelUnreadResponseCopyWith<$Res> implements $ChannelUnreadResponseCopyWith<$Res> {
  factory _$ChannelUnreadResponseCopyWith(_ChannelUnreadResponse value, $Res Function(_ChannelUnreadResponse) _then) = __$ChannelUnreadResponseCopyWithImpl;
@override @useResult
$Res call({
 int channelId, int unreadCount
});




}
/// @nodoc
class __$ChannelUnreadResponseCopyWithImpl<$Res>
    implements _$ChannelUnreadResponseCopyWith<$Res> {
  __$ChannelUnreadResponseCopyWithImpl(this._self, this._then);

  final _ChannelUnreadResponse _self;
  final $Res Function(_ChannelUnreadResponse) _then;

/// Create a copy of ChannelUnreadResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? channelId = null,Object? unreadCount = null,}) {
  return _then(_ChannelUnreadResponse(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as int,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
