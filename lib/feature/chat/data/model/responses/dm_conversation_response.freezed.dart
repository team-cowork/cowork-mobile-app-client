// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dm_conversation_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DmConversationResponse {

/// 대화에 쓰는 DM 채널 id. 메시지는 채널 메시지 API 를 그대로 쓴다.
 int get channelId;/// 상대 사용자 id. 상대가 탈퇴하는 등 알 수 없으면 null.
 int? get otherUserId; int get unreadCount;/// 아직 메시지가 없으면 null.
 DmLastMessageResponse? get lastMessage;
/// Create a copy of DmConversationResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DmConversationResponseCopyWith<DmConversationResponse> get copyWith => _$DmConversationResponseCopyWithImpl<DmConversationResponse>(this as DmConversationResponse, _$identity);

  /// Serializes this DmConversationResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DmConversationResponse&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.otherUserId, otherUserId) || other.otherUserId == otherUserId)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,otherUserId,unreadCount,lastMessage);

@override
String toString() {
  return 'DmConversationResponse(channelId: $channelId, otherUserId: $otherUserId, unreadCount: $unreadCount, lastMessage: $lastMessage)';
}


}

/// @nodoc
abstract mixin class $DmConversationResponseCopyWith<$Res>  {
  factory $DmConversationResponseCopyWith(DmConversationResponse value, $Res Function(DmConversationResponse) _then) = _$DmConversationResponseCopyWithImpl;
@useResult
$Res call({
 int channelId, int? otherUserId, int unreadCount, DmLastMessageResponse? lastMessage
});


$DmLastMessageResponseCopyWith<$Res>? get lastMessage;

}
/// @nodoc
class _$DmConversationResponseCopyWithImpl<$Res>
    implements $DmConversationResponseCopyWith<$Res> {
  _$DmConversationResponseCopyWithImpl(this._self, this._then);

  final DmConversationResponse _self;
  final $Res Function(DmConversationResponse) _then;

/// Create a copy of DmConversationResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? channelId = null,Object? otherUserId = freezed,Object? unreadCount = null,Object? lastMessage = freezed,}) {
  return _then(_self.copyWith(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as int,otherUserId: freezed == otherUserId ? _self.otherUserId : otherUserId // ignore: cast_nullable_to_non_nullable
as int?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as DmLastMessageResponse?,
  ));
}
/// Create a copy of DmConversationResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DmLastMessageResponseCopyWith<$Res>? get lastMessage {
    if (_self.lastMessage == null) {
    return null;
  }

  return $DmLastMessageResponseCopyWith<$Res>(_self.lastMessage!, (value) {
    return _then(_self.copyWith(lastMessage: value));
  });
}
}


/// Adds pattern-matching-related methods to [DmConversationResponse].
extension DmConversationResponsePatterns on DmConversationResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DmConversationResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DmConversationResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DmConversationResponse value)  $default,){
final _that = this;
switch (_that) {
case _DmConversationResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DmConversationResponse value)?  $default,){
final _that = this;
switch (_that) {
case _DmConversationResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int channelId,  int? otherUserId,  int unreadCount,  DmLastMessageResponse? lastMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DmConversationResponse() when $default != null:
return $default(_that.channelId,_that.otherUserId,_that.unreadCount,_that.lastMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int channelId,  int? otherUserId,  int unreadCount,  DmLastMessageResponse? lastMessage)  $default,) {final _that = this;
switch (_that) {
case _DmConversationResponse():
return $default(_that.channelId,_that.otherUserId,_that.unreadCount,_that.lastMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int channelId,  int? otherUserId,  int unreadCount,  DmLastMessageResponse? lastMessage)?  $default,) {final _that = this;
switch (_that) {
case _DmConversationResponse() when $default != null:
return $default(_that.channelId,_that.otherUserId,_that.unreadCount,_that.lastMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DmConversationResponse implements DmConversationResponse {
  const _DmConversationResponse({required this.channelId, this.otherUserId, this.unreadCount = 0, this.lastMessage});
  factory _DmConversationResponse.fromJson(Map<String, dynamic> json) => _$DmConversationResponseFromJson(json);

/// 대화에 쓰는 DM 채널 id. 메시지는 채널 메시지 API 를 그대로 쓴다.
@override final  int channelId;
/// 상대 사용자 id. 상대가 탈퇴하는 등 알 수 없으면 null.
@override final  int? otherUserId;
@override@JsonKey() final  int unreadCount;
/// 아직 메시지가 없으면 null.
@override final  DmLastMessageResponse? lastMessage;

/// Create a copy of DmConversationResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DmConversationResponseCopyWith<_DmConversationResponse> get copyWith => __$DmConversationResponseCopyWithImpl<_DmConversationResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DmConversationResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DmConversationResponse&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.otherUserId, otherUserId) || other.otherUserId == otherUserId)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,otherUserId,unreadCount,lastMessage);

@override
String toString() {
  return 'DmConversationResponse(channelId: $channelId, otherUserId: $otherUserId, unreadCount: $unreadCount, lastMessage: $lastMessage)';
}


}

/// @nodoc
abstract mixin class _$DmConversationResponseCopyWith<$Res> implements $DmConversationResponseCopyWith<$Res> {
  factory _$DmConversationResponseCopyWith(_DmConversationResponse value, $Res Function(_DmConversationResponse) _then) = __$DmConversationResponseCopyWithImpl;
@override @useResult
$Res call({
 int channelId, int? otherUserId, int unreadCount, DmLastMessageResponse? lastMessage
});


@override $DmLastMessageResponseCopyWith<$Res>? get lastMessage;

}
/// @nodoc
class __$DmConversationResponseCopyWithImpl<$Res>
    implements _$DmConversationResponseCopyWith<$Res> {
  __$DmConversationResponseCopyWithImpl(this._self, this._then);

  final _DmConversationResponse _self;
  final $Res Function(_DmConversationResponse) _then;

/// Create a copy of DmConversationResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? channelId = null,Object? otherUserId = freezed,Object? unreadCount = null,Object? lastMessage = freezed,}) {
  return _then(_DmConversationResponse(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as int,otherUserId: freezed == otherUserId ? _self.otherUserId : otherUserId // ignore: cast_nullable_to_non_nullable
as int?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as DmLastMessageResponse?,
  ));
}

/// Create a copy of DmConversationResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DmLastMessageResponseCopyWith<$Res>? get lastMessage {
    if (_self.lastMessage == null) {
    return null;
  }

  return $DmLastMessageResponseCopyWith<$Res>(_self.lastMessage!, (value) {
    return _then(_self.copyWith(lastMessage: value));
  });
}
}

// dart format on
