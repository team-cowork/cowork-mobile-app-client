// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'send_message_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SendMessageRequest {

 String get content; String get clientMessageId;
/// Create a copy of SendMessageRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SendMessageRequestCopyWith<SendMessageRequest> get copyWith => _$SendMessageRequestCopyWithImpl<SendMessageRequest>(this as SendMessageRequest, _$identity);

  /// Serializes this SendMessageRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendMessageRequest&&(identical(other.content, content) || other.content == content)&&(identical(other.clientMessageId, clientMessageId) || other.clientMessageId == clientMessageId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content,clientMessageId);

@override
String toString() {
  return 'SendMessageRequest(content: $content, clientMessageId: $clientMessageId)';
}


}

/// @nodoc
abstract mixin class $SendMessageRequestCopyWith<$Res>  {
  factory $SendMessageRequestCopyWith(SendMessageRequest value, $Res Function(SendMessageRequest) _then) = _$SendMessageRequestCopyWithImpl;
@useResult
$Res call({
 String content, String clientMessageId
});




}
/// @nodoc
class _$SendMessageRequestCopyWithImpl<$Res>
    implements $SendMessageRequestCopyWith<$Res> {
  _$SendMessageRequestCopyWithImpl(this._self, this._then);

  final SendMessageRequest _self;
  final $Res Function(SendMessageRequest) _then;

/// Create a copy of SendMessageRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? content = null,Object? clientMessageId = null,}) {
  return _then(_self.copyWith(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,clientMessageId: null == clientMessageId ? _self.clientMessageId : clientMessageId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SendMessageRequest].
extension SendMessageRequestPatterns on SendMessageRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SendMessageRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SendMessageRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SendMessageRequest value)  $default,){
final _that = this;
switch (_that) {
case _SendMessageRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SendMessageRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SendMessageRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String content,  String clientMessageId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SendMessageRequest() when $default != null:
return $default(_that.content,_that.clientMessageId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String content,  String clientMessageId)  $default,) {final _that = this;
switch (_that) {
case _SendMessageRequest():
return $default(_that.content,_that.clientMessageId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String content,  String clientMessageId)?  $default,) {final _that = this;
switch (_that) {
case _SendMessageRequest() when $default != null:
return $default(_that.content,_that.clientMessageId);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(createFactory: false)
class _SendMessageRequest implements SendMessageRequest {
  const _SendMessageRequest({required this.content, required this.clientMessageId});
  

@override final  String content;
@override final  String clientMessageId;

/// Create a copy of SendMessageRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SendMessageRequestCopyWith<_SendMessageRequest> get copyWith => __$SendMessageRequestCopyWithImpl<_SendMessageRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SendMessageRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SendMessageRequest&&(identical(other.content, content) || other.content == content)&&(identical(other.clientMessageId, clientMessageId) || other.clientMessageId == clientMessageId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content,clientMessageId);

@override
String toString() {
  return 'SendMessageRequest(content: $content, clientMessageId: $clientMessageId)';
}


}

/// @nodoc
abstract mixin class _$SendMessageRequestCopyWith<$Res> implements $SendMessageRequestCopyWith<$Res> {
  factory _$SendMessageRequestCopyWith(_SendMessageRequest value, $Res Function(_SendMessageRequest) _then) = __$SendMessageRequestCopyWithImpl;
@override @useResult
$Res call({
 String content, String clientMessageId
});




}
/// @nodoc
class __$SendMessageRequestCopyWithImpl<$Res>
    implements _$SendMessageRequestCopyWith<$Res> {
  __$SendMessageRequestCopyWithImpl(this._self, this._then);

  final _SendMessageRequest _self;
  final $Res Function(_SendMessageRequest) _then;

/// Create a copy of SendMessageRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? content = null,Object? clientMessageId = null,}) {
  return _then(_SendMessageRequest(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,clientMessageId: null == clientMessageId ? _self.clientMessageId : clientMessageId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
