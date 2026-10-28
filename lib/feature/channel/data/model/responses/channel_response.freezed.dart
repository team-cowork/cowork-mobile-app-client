// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'channel_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChannelResponse {

/// 없으면 fromJson 이 던진다.
 int get id; String get name;/// 화면 종류. (예: TEXT, WEBHOOK, MEETING_NOTE)
 String? get viewType;/// 채널 설명. 채널 화면 머리에 보인다.
 String? get description;/// 채널이 속한 팀. DM 채널이면 없다.
 int? get teamId;
/// Create a copy of ChannelResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelResponseCopyWith<ChannelResponse> get copyWith => _$ChannelResponseCopyWithImpl<ChannelResponse>(this as ChannelResponse, _$identity);

  /// Serializes this ChannelResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.viewType, viewType) || other.viewType == viewType)&&(identical(other.description, description) || other.description == description)&&(identical(other.teamId, teamId) || other.teamId == teamId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,viewType,description,teamId);

@override
String toString() {
  return 'ChannelResponse(id: $id, name: $name, viewType: $viewType, description: $description, teamId: $teamId)';
}


}

/// @nodoc
abstract mixin class $ChannelResponseCopyWith<$Res>  {
  factory $ChannelResponseCopyWith(ChannelResponse value, $Res Function(ChannelResponse) _then) = _$ChannelResponseCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? viewType, String? description, int? teamId
});




}
/// @nodoc
class _$ChannelResponseCopyWithImpl<$Res>
    implements $ChannelResponseCopyWith<$Res> {
  _$ChannelResponseCopyWithImpl(this._self, this._then);

  final ChannelResponse _self;
  final $Res Function(ChannelResponse) _then;

/// Create a copy of ChannelResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? viewType = freezed,Object? description = freezed,Object? teamId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,viewType: freezed == viewType ? _self.viewType : viewType // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChannelResponse].
extension ChannelResponsePatterns on ChannelResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChannelResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChannelResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChannelResponse value)  $default,){
final _that = this;
switch (_that) {
case _ChannelResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChannelResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ChannelResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? viewType,  String? description,  int? teamId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChannelResponse() when $default != null:
return $default(_that.id,_that.name,_that.viewType,_that.description,_that.teamId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? viewType,  String? description,  int? teamId)  $default,) {final _that = this;
switch (_that) {
case _ChannelResponse():
return $default(_that.id,_that.name,_that.viewType,_that.description,_that.teamId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? viewType,  String? description,  int? teamId)?  $default,) {final _that = this;
switch (_that) {
case _ChannelResponse() when $default != null:
return $default(_that.id,_that.name,_that.viewType,_that.description,_that.teamId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChannelResponse extends ChannelResponse {
  const _ChannelResponse({required this.id, this.name = '', this.viewType, this.description, this.teamId}): super._();
  factory _ChannelResponse.fromJson(Map<String, dynamic> json) => _$ChannelResponseFromJson(json);

/// 없으면 fromJson 이 던진다.
@override final  int id;
@override@JsonKey() final  String name;
/// 화면 종류. (예: TEXT, WEBHOOK, MEETING_NOTE)
@override final  String? viewType;
/// 채널 설명. 채널 화면 머리에 보인다.
@override final  String? description;
/// 채널이 속한 팀. DM 채널이면 없다.
@override final  int? teamId;

/// Create a copy of ChannelResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChannelResponseCopyWith<_ChannelResponse> get copyWith => __$ChannelResponseCopyWithImpl<_ChannelResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChannelResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChannelResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.viewType, viewType) || other.viewType == viewType)&&(identical(other.description, description) || other.description == description)&&(identical(other.teamId, teamId) || other.teamId == teamId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,viewType,description,teamId);

@override
String toString() {
  return 'ChannelResponse(id: $id, name: $name, viewType: $viewType, description: $description, teamId: $teamId)';
}


}

/// @nodoc
abstract mixin class _$ChannelResponseCopyWith<$Res> implements $ChannelResponseCopyWith<$Res> {
  factory _$ChannelResponseCopyWith(_ChannelResponse value, $Res Function(_ChannelResponse) _then) = __$ChannelResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? viewType, String? description, int? teamId
});




}
/// @nodoc
class __$ChannelResponseCopyWithImpl<$Res>
    implements _$ChannelResponseCopyWith<$Res> {
  __$ChannelResponseCopyWithImpl(this._self, this._then);

  final _ChannelResponse _self;
  final $Res Function(_ChannelResponse) _then;

/// Create a copy of ChannelResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? viewType = freezed,Object? description = freezed,Object? teamId = freezed,}) {
  return _then(_ChannelResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,viewType: freezed == viewType ? _self.viewType : viewType // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
