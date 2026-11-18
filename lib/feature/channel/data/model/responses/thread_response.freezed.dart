// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'thread_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ThreadResponse {

 int get id; int get channelId; String get name;/// 스레드의 부모(맨 위) 메시지 id.
 String get parentMessageId; bool get isArchived;
/// Create a copy of ThreadResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThreadResponseCopyWith<ThreadResponse> get copyWith => _$ThreadResponseCopyWithImpl<ThreadResponse>(this as ThreadResponse, _$identity);

  /// Serializes this ThreadResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThreadResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.name, name) || other.name == name)&&(identical(other.parentMessageId, parentMessageId) || other.parentMessageId == parentMessageId)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,name,parentMessageId,isArchived);

@override
String toString() {
  return 'ThreadResponse(id: $id, channelId: $channelId, name: $name, parentMessageId: $parentMessageId, isArchived: $isArchived)';
}


}

/// @nodoc
abstract mixin class $ThreadResponseCopyWith<$Res>  {
  factory $ThreadResponseCopyWith(ThreadResponse value, $Res Function(ThreadResponse) _then) = _$ThreadResponseCopyWithImpl;
@useResult
$Res call({
 int id, int channelId, String name, String parentMessageId, bool isArchived
});




}
/// @nodoc
class _$ThreadResponseCopyWithImpl<$Res>
    implements $ThreadResponseCopyWith<$Res> {
  _$ThreadResponseCopyWithImpl(this._self, this._then);

  final ThreadResponse _self;
  final $Res Function(ThreadResponse) _then;

/// Create a copy of ThreadResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? channelId = null,Object? name = null,Object? parentMessageId = null,Object? isArchived = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parentMessageId: null == parentMessageId ? _self.parentMessageId : parentMessageId // ignore: cast_nullable_to_non_nullable
as String,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ThreadResponse].
extension ThreadResponsePatterns on ThreadResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThreadResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThreadResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThreadResponse value)  $default,){
final _that = this;
switch (_that) {
case _ThreadResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThreadResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ThreadResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int channelId,  String name,  String parentMessageId,  bool isArchived)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThreadResponse() when $default != null:
return $default(_that.id,_that.channelId,_that.name,_that.parentMessageId,_that.isArchived);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int channelId,  String name,  String parentMessageId,  bool isArchived)  $default,) {final _that = this;
switch (_that) {
case _ThreadResponse():
return $default(_that.id,_that.channelId,_that.name,_that.parentMessageId,_that.isArchived);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int channelId,  String name,  String parentMessageId,  bool isArchived)?  $default,) {final _that = this;
switch (_that) {
case _ThreadResponse() when $default != null:
return $default(_that.id,_that.channelId,_that.name,_that.parentMessageId,_that.isArchived);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThreadResponse implements ThreadResponse {
  const _ThreadResponse({required this.id, required this.channelId, this.name = '', required this.parentMessageId, this.isArchived = false});
  factory _ThreadResponse.fromJson(Map<String, dynamic> json) => _$ThreadResponseFromJson(json);

@override final  int id;
@override final  int channelId;
@override@JsonKey() final  String name;
/// 스레드의 부모(맨 위) 메시지 id.
@override final  String parentMessageId;
@override@JsonKey() final  bool isArchived;

/// Create a copy of ThreadResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThreadResponseCopyWith<_ThreadResponse> get copyWith => __$ThreadResponseCopyWithImpl<_ThreadResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThreadResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThreadResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.name, name) || other.name == name)&&(identical(other.parentMessageId, parentMessageId) || other.parentMessageId == parentMessageId)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,name,parentMessageId,isArchived);

@override
String toString() {
  return 'ThreadResponse(id: $id, channelId: $channelId, name: $name, parentMessageId: $parentMessageId, isArchived: $isArchived)';
}


}

/// @nodoc
abstract mixin class _$ThreadResponseCopyWith<$Res> implements $ThreadResponseCopyWith<$Res> {
  factory _$ThreadResponseCopyWith(_ThreadResponse value, $Res Function(_ThreadResponse) _then) = __$ThreadResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, int channelId, String name, String parentMessageId, bool isArchived
});




}
/// @nodoc
class __$ThreadResponseCopyWithImpl<$Res>
    implements _$ThreadResponseCopyWith<$Res> {
  __$ThreadResponseCopyWithImpl(this._self, this._then);

  final _ThreadResponse _self;
  final $Res Function(_ThreadResponse) _then;

/// Create a copy of ThreadResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? channelId = null,Object? name = null,Object? parentMessageId = null,Object? isArchived = null,}) {
  return _then(_ThreadResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parentMessageId: null == parentMessageId ? _self.parentMessageId : parentMessageId // ignore: cast_nullable_to_non_nullable
as String,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
