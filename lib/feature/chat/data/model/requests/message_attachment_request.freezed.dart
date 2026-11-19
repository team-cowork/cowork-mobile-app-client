// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_attachment_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MessageAttachmentRequest {

/// 업로드 확인(`files/confirm`)이 돌려준 확정 키.
 String get objectKey;
/// Create a copy of MessageAttachmentRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageAttachmentRequestCopyWith<MessageAttachmentRequest> get copyWith => _$MessageAttachmentRequestCopyWithImpl<MessageAttachmentRequest>(this as MessageAttachmentRequest, _$identity);

  /// Serializes this MessageAttachmentRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageAttachmentRequest&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,objectKey);

@override
String toString() {
  return 'MessageAttachmentRequest(objectKey: $objectKey)';
}


}

/// @nodoc
abstract mixin class $MessageAttachmentRequestCopyWith<$Res>  {
  factory $MessageAttachmentRequestCopyWith(MessageAttachmentRequest value, $Res Function(MessageAttachmentRequest) _then) = _$MessageAttachmentRequestCopyWithImpl;
@useResult
$Res call({
 String objectKey
});




}
/// @nodoc
class _$MessageAttachmentRequestCopyWithImpl<$Res>
    implements $MessageAttachmentRequestCopyWith<$Res> {
  _$MessageAttachmentRequestCopyWithImpl(this._self, this._then);

  final MessageAttachmentRequest _self;
  final $Res Function(MessageAttachmentRequest) _then;

/// Create a copy of MessageAttachmentRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? objectKey = null,}) {
  return _then(_self.copyWith(
objectKey: null == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageAttachmentRequest].
extension MessageAttachmentRequestPatterns on MessageAttachmentRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageAttachmentRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageAttachmentRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageAttachmentRequest value)  $default,){
final _that = this;
switch (_that) {
case _MessageAttachmentRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageAttachmentRequest value)?  $default,){
final _that = this;
switch (_that) {
case _MessageAttachmentRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String objectKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageAttachmentRequest() when $default != null:
return $default(_that.objectKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String objectKey)  $default,) {final _that = this;
switch (_that) {
case _MessageAttachmentRequest():
return $default(_that.objectKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String objectKey)?  $default,) {final _that = this;
switch (_that) {
case _MessageAttachmentRequest() when $default != null:
return $default(_that.objectKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createFactory: false)

class _MessageAttachmentRequest implements MessageAttachmentRequest {
  const _MessageAttachmentRequest({required this.objectKey});
  

/// 업로드 확인(`files/confirm`)이 돌려준 확정 키.
@override final  String objectKey;

/// Create a copy of MessageAttachmentRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageAttachmentRequestCopyWith<_MessageAttachmentRequest> get copyWith => __$MessageAttachmentRequestCopyWithImpl<_MessageAttachmentRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageAttachmentRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageAttachmentRequest&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,objectKey);

@override
String toString() {
  return 'MessageAttachmentRequest(objectKey: $objectKey)';
}


}

/// @nodoc
abstract mixin class _$MessageAttachmentRequestCopyWith<$Res> implements $MessageAttachmentRequestCopyWith<$Res> {
  factory _$MessageAttachmentRequestCopyWith(_MessageAttachmentRequest value, $Res Function(_MessageAttachmentRequest) _then) = __$MessageAttachmentRequestCopyWithImpl;
@override @useResult
$Res call({
 String objectKey
});




}
/// @nodoc
class __$MessageAttachmentRequestCopyWithImpl<$Res>
    implements _$MessageAttachmentRequestCopyWith<$Res> {
  __$MessageAttachmentRequestCopyWithImpl(this._self, this._then);

  final _MessageAttachmentRequest _self;
  final $Res Function(_MessageAttachmentRequest) _then;

/// Create a copy of MessageAttachmentRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? objectKey = null,}) {
  return _then(_MessageAttachmentRequest(
objectKey: null == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
