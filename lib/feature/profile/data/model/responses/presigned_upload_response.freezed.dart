// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'presigned_upload_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PresignedUploadResponse {

 String get objectKey; String get uploadUrl;
/// Create a copy of PresignedUploadResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresignedUploadResponseCopyWith<PresignedUploadResponse> get copyWith => _$PresignedUploadResponseCopyWithImpl<PresignedUploadResponse>(this as PresignedUploadResponse, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresignedUploadResponse&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey)&&(identical(other.uploadUrl, uploadUrl) || other.uploadUrl == uploadUrl));
}


@override
int get hashCode => Object.hash(runtimeType,objectKey,uploadUrl);

@override
String toString() {
  return 'PresignedUploadResponse(objectKey: $objectKey, uploadUrl: $uploadUrl)';
}


}

/// @nodoc
abstract mixin class $PresignedUploadResponseCopyWith<$Res>  {
  factory $PresignedUploadResponseCopyWith(PresignedUploadResponse value, $Res Function(PresignedUploadResponse) _then) = _$PresignedUploadResponseCopyWithImpl;
@useResult
$Res call({
 String objectKey, String uploadUrl
});




}
/// @nodoc
class _$PresignedUploadResponseCopyWithImpl<$Res>
    implements $PresignedUploadResponseCopyWith<$Res> {
  _$PresignedUploadResponseCopyWithImpl(this._self, this._then);

  final PresignedUploadResponse _self;
  final $Res Function(PresignedUploadResponse) _then;

/// Create a copy of PresignedUploadResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? objectKey = null,Object? uploadUrl = null,}) {
  return _then(_self.copyWith(
objectKey: null == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String,uploadUrl: null == uploadUrl ? _self.uploadUrl : uploadUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PresignedUploadResponse].
extension PresignedUploadResponsePatterns on PresignedUploadResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PresignedUploadResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PresignedUploadResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PresignedUploadResponse value)  $default,){
final _that = this;
switch (_that) {
case _PresignedUploadResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PresignedUploadResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PresignedUploadResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String objectKey,  String uploadUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PresignedUploadResponse() when $default != null:
return $default(_that.objectKey,_that.uploadUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String objectKey,  String uploadUrl)  $default,) {final _that = this;
switch (_that) {
case _PresignedUploadResponse():
return $default(_that.objectKey,_that.uploadUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String objectKey,  String uploadUrl)?  $default,) {final _that = this;
switch (_that) {
case _PresignedUploadResponse() when $default != null:
return $default(_that.objectKey,_that.uploadUrl);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _PresignedUploadResponse implements PresignedUploadResponse {
  const _PresignedUploadResponse({this.objectKey = '', this.uploadUrl = ''});
  

@override@JsonKey() final  String objectKey;
@override@JsonKey() final  String uploadUrl;

/// Create a copy of PresignedUploadResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresignedUploadResponseCopyWith<_PresignedUploadResponse> get copyWith => __$PresignedUploadResponseCopyWithImpl<_PresignedUploadResponse>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PresignedUploadResponse&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey)&&(identical(other.uploadUrl, uploadUrl) || other.uploadUrl == uploadUrl));
}


@override
int get hashCode => Object.hash(runtimeType,objectKey,uploadUrl);

@override
String toString() {
  return 'PresignedUploadResponse(objectKey: $objectKey, uploadUrl: $uploadUrl)';
}


}

/// @nodoc
abstract mixin class _$PresignedUploadResponseCopyWith<$Res> implements $PresignedUploadResponseCopyWith<$Res> {
  factory _$PresignedUploadResponseCopyWith(_PresignedUploadResponse value, $Res Function(_PresignedUploadResponse) _then) = __$PresignedUploadResponseCopyWithImpl;
@override @useResult
$Res call({
 String objectKey, String uploadUrl
});




}
/// @nodoc
class __$PresignedUploadResponseCopyWithImpl<$Res>
    implements _$PresignedUploadResponseCopyWith<$Res> {
  __$PresignedUploadResponseCopyWithImpl(this._self, this._then);

  final _PresignedUploadResponse _self;
  final $Res Function(_PresignedUploadResponse) _then;

/// Create a copy of PresignedUploadResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? objectKey = null,Object? uploadUrl = null,}) {
  return _then(_PresignedUploadResponse(
objectKey: null == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String,uploadUrl: null == uploadUrl ? _self.uploadUrl : uploadUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
