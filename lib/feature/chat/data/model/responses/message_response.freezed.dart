// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageResponse {

/// MongoDB ObjectId.
@JsonKey(name: '_id') String get id; int get channelId; int get authorId; String get content;/// `TEXT` / `FILE` / `SYSTEM`. 시스템 메시지는 사람이 쓴 게 아니다.
 String get type;/// 붙은 파일. `FILE` 메시지는 [content] 가 비어 있을 수 있다.
 List<AttachmentResponse> get attachments; DateTime get createdAt;/// 스레드 답글이면 부모 메시지 id. 최상위 메시지는 null.
 String? get parentMessageId;/// 보낸 쪽이 붙인 멱등성 키. 내가 보낸 메시지를 맞춰 볼 때 쓴다.
 String? get clientMessageId;
/// Create a copy of MessageResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageResponseCopyWith<MessageResponse> get copyWith => _$MessageResponseCopyWithImpl<MessageResponse>(this as MessageResponse, _$identity);

  /// Serializes this MessageResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.content, content) || other.content == content)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.parentMessageId, parentMessageId) || other.parentMessageId == parentMessageId)&&(identical(other.clientMessageId, clientMessageId) || other.clientMessageId == clientMessageId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,authorId,content,type,const DeepCollectionEquality().hash(attachments),createdAt,parentMessageId,clientMessageId);

@override
String toString() {
  return 'MessageResponse(id: $id, channelId: $channelId, authorId: $authorId, content: $content, type: $type, attachments: $attachments, createdAt: $createdAt, parentMessageId: $parentMessageId, clientMessageId: $clientMessageId)';
}


}

/// @nodoc
abstract mixin class $MessageResponseCopyWith<$Res>  {
  factory $MessageResponseCopyWith(MessageResponse value, $Res Function(MessageResponse) _then) = _$MessageResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id, int channelId, int authorId, String content, String type, List<AttachmentResponse> attachments, DateTime createdAt, String? parentMessageId, String? clientMessageId
});




}
/// @nodoc
class _$MessageResponseCopyWithImpl<$Res>
    implements $MessageResponseCopyWith<$Res> {
  _$MessageResponseCopyWithImpl(this._self, this._then);

  final MessageResponse _self;
  final $Res Function(MessageResponse) _then;

/// Create a copy of MessageResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? channelId = null,Object? authorId = null,Object? content = null,Object? type = null,Object? attachments = null,Object? createdAt = null,Object? parentMessageId = freezed,Object? clientMessageId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as int,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as int,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<AttachmentResponse>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,parentMessageId: freezed == parentMessageId ? _self.parentMessageId : parentMessageId // ignore: cast_nullable_to_non_nullable
as String?,clientMessageId: freezed == clientMessageId ? _self.clientMessageId : clientMessageId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageResponse].
extension MessageResponsePatterns on MessageResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageResponse value)  $default,){
final _that = this;
switch (_that) {
case _MessageResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MessageResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  int channelId,  int authorId,  String content,  String type,  List<AttachmentResponse> attachments,  DateTime createdAt,  String? parentMessageId,  String? clientMessageId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageResponse() when $default != null:
return $default(_that.id,_that.channelId,_that.authorId,_that.content,_that.type,_that.attachments,_that.createdAt,_that.parentMessageId,_that.clientMessageId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  int channelId,  int authorId,  String content,  String type,  List<AttachmentResponse> attachments,  DateTime createdAt,  String? parentMessageId,  String? clientMessageId)  $default,) {final _that = this;
switch (_that) {
case _MessageResponse():
return $default(_that.id,_that.channelId,_that.authorId,_that.content,_that.type,_that.attachments,_that.createdAt,_that.parentMessageId,_that.clientMessageId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id,  int channelId,  int authorId,  String content,  String type,  List<AttachmentResponse> attachments,  DateTime createdAt,  String? parentMessageId,  String? clientMessageId)?  $default,) {final _that = this;
switch (_that) {
case _MessageResponse() when $default != null:
return $default(_that.id,_that.channelId,_that.authorId,_that.content,_that.type,_that.attachments,_that.createdAt,_that.parentMessageId,_that.clientMessageId);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _MessageResponse extends MessageResponse {
  const _MessageResponse({@JsonKey(name: '_id') required this.id, required this.channelId, required this.authorId, this.content = '', this.type = 'TEXT', final  List<AttachmentResponse> attachments = const [], required this.createdAt, this.parentMessageId, this.clientMessageId}): _attachments = attachments,super._();
  factory _MessageResponse.fromJson(Map<String, dynamic> json) => _$MessageResponseFromJson(json);

/// MongoDB ObjectId.
@override@JsonKey(name: '_id') final  String id;
@override final  int channelId;
@override final  int authorId;
@override@JsonKey() final  String content;
/// `TEXT` / `FILE` / `SYSTEM`. 시스템 메시지는 사람이 쓴 게 아니다.
@override@JsonKey() final  String type;
/// 붙은 파일. `FILE` 메시지는 [content] 가 비어 있을 수 있다.
 final  List<AttachmentResponse> _attachments;
/// 붙은 파일. `FILE` 메시지는 [content] 가 비어 있을 수 있다.
@override@JsonKey() List<AttachmentResponse> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

@override final  DateTime createdAt;
/// 스레드 답글이면 부모 메시지 id. 최상위 메시지는 null.
@override final  String? parentMessageId;
/// 보낸 쪽이 붙인 멱등성 키. 내가 보낸 메시지를 맞춰 볼 때 쓴다.
@override final  String? clientMessageId;

/// Create a copy of MessageResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageResponseCopyWith<_MessageResponse> get copyWith => __$MessageResponseCopyWithImpl<_MessageResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.content, content) || other.content == content)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.parentMessageId, parentMessageId) || other.parentMessageId == parentMessageId)&&(identical(other.clientMessageId, clientMessageId) || other.clientMessageId == clientMessageId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,authorId,content,type,const DeepCollectionEquality().hash(_attachments),createdAt,parentMessageId,clientMessageId);

@override
String toString() {
  return 'MessageResponse(id: $id, channelId: $channelId, authorId: $authorId, content: $content, type: $type, attachments: $attachments, createdAt: $createdAt, parentMessageId: $parentMessageId, clientMessageId: $clientMessageId)';
}


}

/// @nodoc
abstract mixin class _$MessageResponseCopyWith<$Res> implements $MessageResponseCopyWith<$Res> {
  factory _$MessageResponseCopyWith(_MessageResponse value, $Res Function(_MessageResponse) _then) = __$MessageResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id, int channelId, int authorId, String content, String type, List<AttachmentResponse> attachments, DateTime createdAt, String? parentMessageId, String? clientMessageId
});




}
/// @nodoc
class __$MessageResponseCopyWithImpl<$Res>
    implements _$MessageResponseCopyWith<$Res> {
  __$MessageResponseCopyWithImpl(this._self, this._then);

  final _MessageResponse _self;
  final $Res Function(_MessageResponse) _then;

/// Create a copy of MessageResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? channelId = null,Object? authorId = null,Object? content = null,Object? type = null,Object? attachments = null,Object? createdAt = null,Object? parentMessageId = freezed,Object? clientMessageId = freezed,}) {
  return _then(_MessageResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as int,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as int,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<AttachmentResponse>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,parentMessageId: freezed == parentMessageId ? _self.parentMessageId : parentMessageId // ignore: cast_nullable_to_non_nullable
as String?,clientMessageId: freezed == clientMessageId ? _self.clientMessageId : clientMessageId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
