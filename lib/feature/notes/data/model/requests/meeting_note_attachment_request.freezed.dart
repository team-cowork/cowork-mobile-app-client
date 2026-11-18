// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meeting_note_attachment_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MeetingNoteAttachmentRequest {

/// 업로드 확인(`files/confirm`)이 돌려준 확정 키. 업로드 주소를 받을 때의 임시
/// 키(`chat-uploads/...`)를 보내면 서버가 거절한다.
 String get objectKey;/// 받을 때 보일 파일 이름.
 String get name;
/// Create a copy of MeetingNoteAttachmentRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeetingNoteAttachmentRequestCopyWith<MeetingNoteAttachmentRequest> get copyWith => _$MeetingNoteAttachmentRequestCopyWithImpl<MeetingNoteAttachmentRequest>(this as MeetingNoteAttachmentRequest, _$identity);

  /// Serializes this MeetingNoteAttachmentRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeetingNoteAttachmentRequest&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,objectKey,name);

@override
String toString() {
  return 'MeetingNoteAttachmentRequest(objectKey: $objectKey, name: $name)';
}


}

/// @nodoc
abstract mixin class $MeetingNoteAttachmentRequestCopyWith<$Res>  {
  factory $MeetingNoteAttachmentRequestCopyWith(MeetingNoteAttachmentRequest value, $Res Function(MeetingNoteAttachmentRequest) _then) = _$MeetingNoteAttachmentRequestCopyWithImpl;
@useResult
$Res call({
 String objectKey, String name
});




}
/// @nodoc
class _$MeetingNoteAttachmentRequestCopyWithImpl<$Res>
    implements $MeetingNoteAttachmentRequestCopyWith<$Res> {
  _$MeetingNoteAttachmentRequestCopyWithImpl(this._self, this._then);

  final MeetingNoteAttachmentRequest _self;
  final $Res Function(MeetingNoteAttachmentRequest) _then;

/// Create a copy of MeetingNoteAttachmentRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? objectKey = null,Object? name = null,}) {
  return _then(_self.copyWith(
objectKey: null == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MeetingNoteAttachmentRequest].
extension MeetingNoteAttachmentRequestPatterns on MeetingNoteAttachmentRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeetingNoteAttachmentRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeetingNoteAttachmentRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeetingNoteAttachmentRequest value)  $default,){
final _that = this;
switch (_that) {
case _MeetingNoteAttachmentRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeetingNoteAttachmentRequest value)?  $default,){
final _that = this;
switch (_that) {
case _MeetingNoteAttachmentRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String objectKey,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeetingNoteAttachmentRequest() when $default != null:
return $default(_that.objectKey,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String objectKey,  String name)  $default,) {final _that = this;
switch (_that) {
case _MeetingNoteAttachmentRequest():
return $default(_that.objectKey,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String objectKey,  String name)?  $default,) {final _that = this;
switch (_that) {
case _MeetingNoteAttachmentRequest() when $default != null:
return $default(_that.objectKey,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createFactory: false)

class _MeetingNoteAttachmentRequest implements MeetingNoteAttachmentRequest {
  const _MeetingNoteAttachmentRequest({required this.objectKey, required this.name});
  

/// 업로드 확인(`files/confirm`)이 돌려준 확정 키. 업로드 주소를 받을 때의 임시
/// 키(`chat-uploads/...`)를 보내면 서버가 거절한다.
@override final  String objectKey;
/// 받을 때 보일 파일 이름.
@override final  String name;

/// Create a copy of MeetingNoteAttachmentRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeetingNoteAttachmentRequestCopyWith<_MeetingNoteAttachmentRequest> get copyWith => __$MeetingNoteAttachmentRequestCopyWithImpl<_MeetingNoteAttachmentRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeetingNoteAttachmentRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeetingNoteAttachmentRequest&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,objectKey,name);

@override
String toString() {
  return 'MeetingNoteAttachmentRequest(objectKey: $objectKey, name: $name)';
}


}

/// @nodoc
abstract mixin class _$MeetingNoteAttachmentRequestCopyWith<$Res> implements $MeetingNoteAttachmentRequestCopyWith<$Res> {
  factory _$MeetingNoteAttachmentRequestCopyWith(_MeetingNoteAttachmentRequest value, $Res Function(_MeetingNoteAttachmentRequest) _then) = __$MeetingNoteAttachmentRequestCopyWithImpl;
@override @useResult
$Res call({
 String objectKey, String name
});




}
/// @nodoc
class __$MeetingNoteAttachmentRequestCopyWithImpl<$Res>
    implements _$MeetingNoteAttachmentRequestCopyWith<$Res> {
  __$MeetingNoteAttachmentRequestCopyWithImpl(this._self, this._then);

  final _MeetingNoteAttachmentRequest _self;
  final $Res Function(_MeetingNoteAttachmentRequest) _then;

/// Create a copy of MeetingNoteAttachmentRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? objectKey = null,Object? name = null,}) {
  return _then(_MeetingNoteAttachmentRequest(
objectKey: null == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
