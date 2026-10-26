// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_channel_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreateChannelRequest {

 int get teamId; String get name;/// 서버 채널 종류. 음성만 VOICE, 나머지는 TEXT.
 String get type;/// 화면 종류. (예: TEXT, WEBHOOK, MEETING_NOTE)
 String get viewType; bool get isPrivate;
/// Create a copy of CreateChannelRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateChannelRequestCopyWith<CreateChannelRequest> get copyWith => _$CreateChannelRequestCopyWithImpl<CreateChannelRequest>(this as CreateChannelRequest, _$identity);

  /// Serializes this CreateChannelRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateChannelRequest&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.viewType, viewType) || other.viewType == viewType)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamId,name,type,viewType,isPrivate);

@override
String toString() {
  return 'CreateChannelRequest(teamId: $teamId, name: $name, type: $type, viewType: $viewType, isPrivate: $isPrivate)';
}


}

/// @nodoc
abstract mixin class $CreateChannelRequestCopyWith<$Res>  {
  factory $CreateChannelRequestCopyWith(CreateChannelRequest value, $Res Function(CreateChannelRequest) _then) = _$CreateChannelRequestCopyWithImpl;
@useResult
$Res call({
 int teamId, String name, String type, String viewType, bool isPrivate
});




}
/// @nodoc
class _$CreateChannelRequestCopyWithImpl<$Res>
    implements $CreateChannelRequestCopyWith<$Res> {
  _$CreateChannelRequestCopyWithImpl(this._self, this._then);

  final CreateChannelRequest _self;
  final $Res Function(CreateChannelRequest) _then;

/// Create a copy of CreateChannelRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? teamId = null,Object? name = null,Object? type = null,Object? viewType = null,Object? isPrivate = null,}) {
  return _then(_self.copyWith(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,viewType: null == viewType ? _self.viewType : viewType // ignore: cast_nullable_to_non_nullable
as String,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateChannelRequest].
extension CreateChannelRequestPatterns on CreateChannelRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateChannelRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateChannelRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateChannelRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateChannelRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateChannelRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateChannelRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int teamId,  String name,  String type,  String viewType,  bool isPrivate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateChannelRequest() when $default != null:
return $default(_that.teamId,_that.name,_that.type,_that.viewType,_that.isPrivate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int teamId,  String name,  String type,  String viewType,  bool isPrivate)  $default,) {final _that = this;
switch (_that) {
case _CreateChannelRequest():
return $default(_that.teamId,_that.name,_that.type,_that.viewType,_that.isPrivate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int teamId,  String name,  String type,  String viewType,  bool isPrivate)?  $default,) {final _that = this;
switch (_that) {
case _CreateChannelRequest() when $default != null:
return $default(_that.teamId,_that.name,_that.type,_that.viewType,_that.isPrivate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createFactory: false)

class _CreateChannelRequest implements CreateChannelRequest {
  const _CreateChannelRequest({required this.teamId, required this.name, required this.type, required this.viewType, required this.isPrivate});
  

@override final  int teamId;
@override final  String name;
/// 서버 채널 종류. 음성만 VOICE, 나머지는 TEXT.
@override final  String type;
/// 화면 종류. (예: TEXT, WEBHOOK, MEETING_NOTE)
@override final  String viewType;
@override final  bool isPrivate;

/// Create a copy of CreateChannelRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateChannelRequestCopyWith<_CreateChannelRequest> get copyWith => __$CreateChannelRequestCopyWithImpl<_CreateChannelRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateChannelRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateChannelRequest&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.viewType, viewType) || other.viewType == viewType)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamId,name,type,viewType,isPrivate);

@override
String toString() {
  return 'CreateChannelRequest(teamId: $teamId, name: $name, type: $type, viewType: $viewType, isPrivate: $isPrivate)';
}


}

/// @nodoc
abstract mixin class _$CreateChannelRequestCopyWith<$Res> implements $CreateChannelRequestCopyWith<$Res> {
  factory _$CreateChannelRequestCopyWith(_CreateChannelRequest value, $Res Function(_CreateChannelRequest) _then) = __$CreateChannelRequestCopyWithImpl;
@override @useResult
$Res call({
 int teamId, String name, String type, String viewType, bool isPrivate
});




}
/// @nodoc
class __$CreateChannelRequestCopyWithImpl<$Res>
    implements _$CreateChannelRequestCopyWith<$Res> {
  __$CreateChannelRequestCopyWithImpl(this._self, this._then);

  final _CreateChannelRequest _self;
  final $Res Function(_CreateChannelRequest) _then;

/// Create a copy of CreateChannelRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? teamId = null,Object? name = null,Object? type = null,Object? viewType = null,Object? isPrivate = null,}) {
  return _then(_CreateChannelRequest(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,viewType: null == viewType ? _self.viewType : viewType // ignore: cast_nullable_to_non_nullable
as String,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
