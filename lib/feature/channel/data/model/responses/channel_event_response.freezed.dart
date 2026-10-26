// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'channel_event_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChannelEventResponse {

 int? get channelId; int? get teamId; String? get name;/// 화면 종류. (예: TEXT, WEBHOOK, MEETING_NOTE)
 String? get viewType;
/// Create a copy of ChannelEventResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelEventResponseCopyWith<ChannelEventResponse> get copyWith => _$ChannelEventResponseCopyWithImpl<ChannelEventResponse>(this as ChannelEventResponse, _$identity);

  /// Serializes this ChannelEventResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelEventResponse&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.name, name) || other.name == name)&&(identical(other.viewType, viewType) || other.viewType == viewType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,teamId,name,viewType);

@override
String toString() {
  return 'ChannelEventResponse(channelId: $channelId, teamId: $teamId, name: $name, viewType: $viewType)';
}


}

/// @nodoc
abstract mixin class $ChannelEventResponseCopyWith<$Res>  {
  factory $ChannelEventResponseCopyWith(ChannelEventResponse value, $Res Function(ChannelEventResponse) _then) = _$ChannelEventResponseCopyWithImpl;
@useResult
$Res call({
 int? channelId, int? teamId, String? name, String? viewType
});




}
/// @nodoc
class _$ChannelEventResponseCopyWithImpl<$Res>
    implements $ChannelEventResponseCopyWith<$Res> {
  _$ChannelEventResponseCopyWithImpl(this._self, this._then);

  final ChannelEventResponse _self;
  final $Res Function(ChannelEventResponse) _then;

/// Create a copy of ChannelEventResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? channelId = freezed,Object? teamId = freezed,Object? name = freezed,Object? viewType = freezed,}) {
  return _then(_self.copyWith(
channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as int?,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,viewType: freezed == viewType ? _self.viewType : viewType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChannelEventResponse].
extension ChannelEventResponsePatterns on ChannelEventResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChannelEventResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChannelEventResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChannelEventResponse value)  $default,){
final _that = this;
switch (_that) {
case _ChannelEventResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChannelEventResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ChannelEventResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? channelId,  int? teamId,  String? name,  String? viewType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChannelEventResponse() when $default != null:
return $default(_that.channelId,_that.teamId,_that.name,_that.viewType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? channelId,  int? teamId,  String? name,  String? viewType)  $default,) {final _that = this;
switch (_that) {
case _ChannelEventResponse():
return $default(_that.channelId,_that.teamId,_that.name,_that.viewType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? channelId,  int? teamId,  String? name,  String? viewType)?  $default,) {final _that = this;
switch (_that) {
case _ChannelEventResponse() when $default != null:
return $default(_that.channelId,_that.teamId,_that.name,_that.viewType);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _ChannelEventResponse implements ChannelEventResponse {
  const _ChannelEventResponse({this.channelId, this.teamId, this.name, this.viewType});
  factory _ChannelEventResponse.fromJson(Map<String, dynamic> json) => _$ChannelEventResponseFromJson(json);

@override final  int? channelId;
@override final  int? teamId;
@override final  String? name;
/// 화면 종류. (예: TEXT, WEBHOOK, MEETING_NOTE)
@override final  String? viewType;

/// Create a copy of ChannelEventResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChannelEventResponseCopyWith<_ChannelEventResponse> get copyWith => __$ChannelEventResponseCopyWithImpl<_ChannelEventResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChannelEventResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChannelEventResponse&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.name, name) || other.name == name)&&(identical(other.viewType, viewType) || other.viewType == viewType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,teamId,name,viewType);

@override
String toString() {
  return 'ChannelEventResponse(channelId: $channelId, teamId: $teamId, name: $name, viewType: $viewType)';
}


}

/// @nodoc
abstract mixin class _$ChannelEventResponseCopyWith<$Res> implements $ChannelEventResponseCopyWith<$Res> {
  factory _$ChannelEventResponseCopyWith(_ChannelEventResponse value, $Res Function(_ChannelEventResponse) _then) = __$ChannelEventResponseCopyWithImpl;
@override @useResult
$Res call({
 int? channelId, int? teamId, String? name, String? viewType
});




}
/// @nodoc
class __$ChannelEventResponseCopyWithImpl<$Res>
    implements _$ChannelEventResponseCopyWith<$Res> {
  __$ChannelEventResponseCopyWithImpl(this._self, this._then);

  final _ChannelEventResponse _self;
  final $Res Function(_ChannelEventResponse) _then;

/// Create a copy of ChannelEventResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? channelId = freezed,Object? teamId = freezed,Object? name = freezed,Object? viewType = freezed,}) {
  return _then(_ChannelEventResponse(
channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as int?,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,viewType: freezed == viewType ? _self.viewType : viewType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
