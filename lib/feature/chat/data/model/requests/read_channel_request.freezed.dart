// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'read_channel_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReadChannelRequest {

 String get lastReadMessageId;
/// Create a copy of ReadChannelRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadChannelRequestCopyWith<ReadChannelRequest> get copyWith => _$ReadChannelRequestCopyWithImpl<ReadChannelRequest>(this as ReadChannelRequest, _$identity);

  /// Serializes this ReadChannelRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadChannelRequest&&(identical(other.lastReadMessageId, lastReadMessageId) || other.lastReadMessageId == lastReadMessageId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lastReadMessageId);

@override
String toString() {
  return 'ReadChannelRequest(lastReadMessageId: $lastReadMessageId)';
}


}

/// @nodoc
abstract mixin class $ReadChannelRequestCopyWith<$Res>  {
  factory $ReadChannelRequestCopyWith(ReadChannelRequest value, $Res Function(ReadChannelRequest) _then) = _$ReadChannelRequestCopyWithImpl;
@useResult
$Res call({
 String lastReadMessageId
});




}
/// @nodoc
class _$ReadChannelRequestCopyWithImpl<$Res>
    implements $ReadChannelRequestCopyWith<$Res> {
  _$ReadChannelRequestCopyWithImpl(this._self, this._then);

  final ReadChannelRequest _self;
  final $Res Function(ReadChannelRequest) _then;

/// Create a copy of ReadChannelRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lastReadMessageId = null,}) {
  return _then(_self.copyWith(
lastReadMessageId: null == lastReadMessageId ? _self.lastReadMessageId : lastReadMessageId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReadChannelRequest].
extension ReadChannelRequestPatterns on ReadChannelRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadChannelRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadChannelRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadChannelRequest value)  $default,){
final _that = this;
switch (_that) {
case _ReadChannelRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadChannelRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ReadChannelRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String lastReadMessageId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadChannelRequest() when $default != null:
return $default(_that.lastReadMessageId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String lastReadMessageId)  $default,) {final _that = this;
switch (_that) {
case _ReadChannelRequest():
return $default(_that.lastReadMessageId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String lastReadMessageId)?  $default,) {final _that = this;
switch (_that) {
case _ReadChannelRequest() when $default != null:
return $default(_that.lastReadMessageId);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(createFactory: false)
class _ReadChannelRequest implements ReadChannelRequest {
  const _ReadChannelRequest({required this.lastReadMessageId});
  

@override final  String lastReadMessageId;

/// Create a copy of ReadChannelRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadChannelRequestCopyWith<_ReadChannelRequest> get copyWith => __$ReadChannelRequestCopyWithImpl<_ReadChannelRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReadChannelRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadChannelRequest&&(identical(other.lastReadMessageId, lastReadMessageId) || other.lastReadMessageId == lastReadMessageId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lastReadMessageId);

@override
String toString() {
  return 'ReadChannelRequest(lastReadMessageId: $lastReadMessageId)';
}


}

/// @nodoc
abstract mixin class _$ReadChannelRequestCopyWith<$Res> implements $ReadChannelRequestCopyWith<$Res> {
  factory _$ReadChannelRequestCopyWith(_ReadChannelRequest value, $Res Function(_ReadChannelRequest) _then) = __$ReadChannelRequestCopyWithImpl;
@override @useResult
$Res call({
 String lastReadMessageId
});




}
/// @nodoc
class __$ReadChannelRequestCopyWithImpl<$Res>
    implements _$ReadChannelRequestCopyWith<$Res> {
  __$ReadChannelRequestCopyWithImpl(this._self, this._then);

  final _ReadChannelRequest _self;
  final $Res Function(_ReadChannelRequest) _then;

/// Create a copy of ReadChannelRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lastReadMessageId = null,}) {
  return _then(_ReadChannelRequest(
lastReadMessageId: null == lastReadMessageId ? _self.lastReadMessageId : lastReadMessageId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
