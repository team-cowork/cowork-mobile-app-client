// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dm_last_message_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DmLastMessageResponse {

/// 시스템·웹훅 메시지면 null.
 int? get authorId; String get content;/// `TEXT` / `FILE` / `SYSTEM`. 파일만 있는 메시지는 [content] 가 비어 있을 수 있다.
 String get type; DateTime get createdAt;
/// Create a copy of DmLastMessageResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DmLastMessageResponseCopyWith<DmLastMessageResponse> get copyWith => _$DmLastMessageResponseCopyWithImpl<DmLastMessageResponse>(this as DmLastMessageResponse, _$identity);

  /// Serializes this DmLastMessageResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DmLastMessageResponse&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.content, content) || other.content == content)&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,authorId,content,type,createdAt);

@override
String toString() {
  return 'DmLastMessageResponse(authorId: $authorId, content: $content, type: $type, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DmLastMessageResponseCopyWith<$Res>  {
  factory $DmLastMessageResponseCopyWith(DmLastMessageResponse value, $Res Function(DmLastMessageResponse) _then) = _$DmLastMessageResponseCopyWithImpl;
@useResult
$Res call({
 int? authorId, String content, String type, DateTime createdAt
});




}
/// @nodoc
class _$DmLastMessageResponseCopyWithImpl<$Res>
    implements $DmLastMessageResponseCopyWith<$Res> {
  _$DmLastMessageResponseCopyWithImpl(this._self, this._then);

  final DmLastMessageResponse _self;
  final $Res Function(DmLastMessageResponse) _then;

/// Create a copy of DmLastMessageResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? authorId = freezed,Object? content = null,Object? type = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
authorId: freezed == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as int?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DmLastMessageResponse].
extension DmLastMessageResponsePatterns on DmLastMessageResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DmLastMessageResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DmLastMessageResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DmLastMessageResponse value)  $default,){
final _that = this;
switch (_that) {
case _DmLastMessageResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DmLastMessageResponse value)?  $default,){
final _that = this;
switch (_that) {
case _DmLastMessageResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? authorId,  String content,  String type,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DmLastMessageResponse() when $default != null:
return $default(_that.authorId,_that.content,_that.type,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? authorId,  String content,  String type,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _DmLastMessageResponse():
return $default(_that.authorId,_that.content,_that.type,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? authorId,  String content,  String type,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _DmLastMessageResponse() when $default != null:
return $default(_that.authorId,_that.content,_that.type,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DmLastMessageResponse implements DmLastMessageResponse {
  const _DmLastMessageResponse({this.authorId, this.content = '', this.type = 'TEXT', required this.createdAt});
  factory _DmLastMessageResponse.fromJson(Map<String, dynamic> json) => _$DmLastMessageResponseFromJson(json);

/// 시스템·웹훅 메시지면 null.
@override final  int? authorId;
@override@JsonKey() final  String content;
/// `TEXT` / `FILE` / `SYSTEM`. 파일만 있는 메시지는 [content] 가 비어 있을 수 있다.
@override@JsonKey() final  String type;
@override final  DateTime createdAt;

/// Create a copy of DmLastMessageResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DmLastMessageResponseCopyWith<_DmLastMessageResponse> get copyWith => __$DmLastMessageResponseCopyWithImpl<_DmLastMessageResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DmLastMessageResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DmLastMessageResponse&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.content, content) || other.content == content)&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,authorId,content,type,createdAt);

@override
String toString() {
  return 'DmLastMessageResponse(authorId: $authorId, content: $content, type: $type, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DmLastMessageResponseCopyWith<$Res> implements $DmLastMessageResponseCopyWith<$Res> {
  factory _$DmLastMessageResponseCopyWith(_DmLastMessageResponse value, $Res Function(_DmLastMessageResponse) _then) = __$DmLastMessageResponseCopyWithImpl;
@override @useResult
$Res call({
 int? authorId, String content, String type, DateTime createdAt
});




}
/// @nodoc
class __$DmLastMessageResponseCopyWithImpl<$Res>
    implements _$DmLastMessageResponseCopyWith<$Res> {
  __$DmLastMessageResponseCopyWithImpl(this._self, this._then);

  final _DmLastMessageResponse _self;
  final $Res Function(_DmLastMessageResponse) _then;

/// Create a copy of DmLastMessageResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? authorId = freezed,Object? content = null,Object? type = null,Object? createdAt = null,}) {
  return _then(_DmLastMessageResponse(
authorId: freezed == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as int?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
