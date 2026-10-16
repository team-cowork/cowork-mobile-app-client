// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'confirm_profile_image_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConfirmProfileImageRequest {

/// presigned 발급 때 받은 값.
 String get objectKey;
/// Create a copy of ConfirmProfileImageRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfirmProfileImageRequestCopyWith<ConfirmProfileImageRequest> get copyWith => _$ConfirmProfileImageRequestCopyWithImpl<ConfirmProfileImageRequest>(this as ConfirmProfileImageRequest, _$identity);

  /// Serializes this ConfirmProfileImageRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfirmProfileImageRequest&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,objectKey);

@override
String toString() {
  return 'ConfirmProfileImageRequest(objectKey: $objectKey)';
}


}

/// @nodoc
abstract mixin class $ConfirmProfileImageRequestCopyWith<$Res>  {
  factory $ConfirmProfileImageRequestCopyWith(ConfirmProfileImageRequest value, $Res Function(ConfirmProfileImageRequest) _then) = _$ConfirmProfileImageRequestCopyWithImpl;
@useResult
$Res call({
 String objectKey
});




}
/// @nodoc
class _$ConfirmProfileImageRequestCopyWithImpl<$Res>
    implements $ConfirmProfileImageRequestCopyWith<$Res> {
  _$ConfirmProfileImageRequestCopyWithImpl(this._self, this._then);

  final ConfirmProfileImageRequest _self;
  final $Res Function(ConfirmProfileImageRequest) _then;

/// Create a copy of ConfirmProfileImageRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? objectKey = null,}) {
  return _then(_self.copyWith(
objectKey: null == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ConfirmProfileImageRequest].
extension ConfirmProfileImageRequestPatterns on ConfirmProfileImageRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConfirmProfileImageRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConfirmProfileImageRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConfirmProfileImageRequest value)  $default,){
final _that = this;
switch (_that) {
case _ConfirmProfileImageRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConfirmProfileImageRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ConfirmProfileImageRequest() when $default != null:
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
case _ConfirmProfileImageRequest() when $default != null:
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
case _ConfirmProfileImageRequest():
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
case _ConfirmProfileImageRequest() when $default != null:
return $default(_that.objectKey);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, createFactory: false)
class _ConfirmProfileImageRequest implements ConfirmProfileImageRequest {
  const _ConfirmProfileImageRequest({required this.objectKey});
  

/// presigned 발급 때 받은 값.
@override final  String objectKey;

/// Create a copy of ConfirmProfileImageRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfirmProfileImageRequestCopyWith<_ConfirmProfileImageRequest> get copyWith => __$ConfirmProfileImageRequestCopyWithImpl<_ConfirmProfileImageRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfirmProfileImageRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfirmProfileImageRequest&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,objectKey);

@override
String toString() {
  return 'ConfirmProfileImageRequest(objectKey: $objectKey)';
}


}

/// @nodoc
abstract mixin class _$ConfirmProfileImageRequestCopyWith<$Res> implements $ConfirmProfileImageRequestCopyWith<$Res> {
  factory _$ConfirmProfileImageRequestCopyWith(_ConfirmProfileImageRequest value, $Res Function(_ConfirmProfileImageRequest) _then) = __$ConfirmProfileImageRequestCopyWithImpl;
@override @useResult
$Res call({
 String objectKey
});




}
/// @nodoc
class __$ConfirmProfileImageRequestCopyWithImpl<$Res>
    implements _$ConfirmProfileImageRequestCopyWith<$Res> {
  __$ConfirmProfileImageRequestCopyWithImpl(this._self, this._then);

  final _ConfirmProfileImageRequest _self;
  final $Res Function(_ConfirmProfileImageRequest) _then;

/// Create a copy of ConfirmProfileImageRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? objectKey = null,}) {
  return _then(_ConfirmProfileImageRequest(
objectKey: null == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
