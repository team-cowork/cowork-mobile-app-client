// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_event_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationEventResponse {

/// `CHAT_MESSAGE` / `MEMBER_INVITED` / `MEMBER_REMOVED` /
/// `PROJECT_TASK_ASSIGNED` / `GITHUB_COMMENT_CREATED` 등.
 String get type; String get title; String get body; int get channelId; int get teamId;
/// Create a copy of NotificationEventResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationEventResponseCopyWith<NotificationEventResponse> get copyWith => _$NotificationEventResponseCopyWithImpl<NotificationEventResponse>(this as NotificationEventResponse, _$identity);

  /// Serializes this NotificationEventResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationEventResponse&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.teamId, teamId) || other.teamId == teamId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,title,body,channelId,teamId);

@override
String toString() {
  return 'NotificationEventResponse(type: $type, title: $title, body: $body, channelId: $channelId, teamId: $teamId)';
}


}

/// @nodoc
abstract mixin class $NotificationEventResponseCopyWith<$Res>  {
  factory $NotificationEventResponseCopyWith(NotificationEventResponse value, $Res Function(NotificationEventResponse) _then) = _$NotificationEventResponseCopyWithImpl;
@useResult
$Res call({
 String type, String title, String body, int channelId, int teamId
});




}
/// @nodoc
class _$NotificationEventResponseCopyWithImpl<$Res>
    implements $NotificationEventResponseCopyWith<$Res> {
  _$NotificationEventResponseCopyWithImpl(this._self, this._then);

  final NotificationEventResponse _self;
  final $Res Function(NotificationEventResponse) _then;

/// Create a copy of NotificationEventResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? title = null,Object? body = null,Object? channelId = null,Object? teamId = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as int,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationEventResponse].
extension NotificationEventResponsePatterns on NotificationEventResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationEventResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationEventResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationEventResponse value)  $default,){
final _that = this;
switch (_that) {
case _NotificationEventResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationEventResponse value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationEventResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String title,  String body,  int channelId,  int teamId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationEventResponse() when $default != null:
return $default(_that.type,_that.title,_that.body,_that.channelId,_that.teamId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String title,  String body,  int channelId,  int teamId)  $default,) {final _that = this;
switch (_that) {
case _NotificationEventResponse():
return $default(_that.type,_that.title,_that.body,_that.channelId,_that.teamId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String title,  String body,  int channelId,  int teamId)?  $default,) {final _that = this;
switch (_that) {
case _NotificationEventResponse() when $default != null:
return $default(_that.type,_that.title,_that.body,_that.channelId,_that.teamId);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _NotificationEventResponse implements NotificationEventResponse {
  const _NotificationEventResponse({this.type = '', this.title = '', this.body = '', this.channelId = 0, this.teamId = 0});
  factory _NotificationEventResponse.fromJson(Map<String, dynamic> json) => _$NotificationEventResponseFromJson(json);

/// `CHAT_MESSAGE` / `MEMBER_INVITED` / `MEMBER_REMOVED` /
/// `PROJECT_TASK_ASSIGNED` / `GITHUB_COMMENT_CREATED` 등.
@override@JsonKey() final  String type;
@override@JsonKey() final  String title;
@override@JsonKey() final  String body;
@override@JsonKey() final  int channelId;
@override@JsonKey() final  int teamId;

/// Create a copy of NotificationEventResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationEventResponseCopyWith<_NotificationEventResponse> get copyWith => __$NotificationEventResponseCopyWithImpl<_NotificationEventResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationEventResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationEventResponse&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.teamId, teamId) || other.teamId == teamId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,title,body,channelId,teamId);

@override
String toString() {
  return 'NotificationEventResponse(type: $type, title: $title, body: $body, channelId: $channelId, teamId: $teamId)';
}


}

/// @nodoc
abstract mixin class _$NotificationEventResponseCopyWith<$Res> implements $NotificationEventResponseCopyWith<$Res> {
  factory _$NotificationEventResponseCopyWith(_NotificationEventResponse value, $Res Function(_NotificationEventResponse) _then) = __$NotificationEventResponseCopyWithImpl;
@override @useResult
$Res call({
 String type, String title, String body, int channelId, int teamId
});




}
/// @nodoc
class __$NotificationEventResponseCopyWithImpl<$Res>
    implements _$NotificationEventResponseCopyWith<$Res> {
  __$NotificationEventResponseCopyWithImpl(this._self, this._then);

  final _NotificationEventResponse _self;
  final $Res Function(_NotificationEventResponse) _then;

/// Create a copy of NotificationEventResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? title = null,Object? body = null,Object? channelId = null,Object? teamId = null,}) {
  return _then(_NotificationEventResponse(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as int,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
